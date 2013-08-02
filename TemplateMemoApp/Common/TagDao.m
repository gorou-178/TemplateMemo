//
//  TagDao.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/10.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TagDao.h"
#import "FMDatabase.h"
#import "DateUtil.h"

@implementation TagDaoImpl

- (id)init
{
    NSLog(@"TagDaoImpl init");
    self = [super init];
    [self createTable];
    return self;
}

- (id)initWithDataBaseFileName:(NSString *)fileName
{
    self = [super initWithDataBaseFileName:fileName];
    [self createTable];
    return self;
}

- (BOOL)createTable
{
    BOOL bResult = [self open];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return bResult;
    }
    
    [db beginTransaction];
    
    bResult = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS tag (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, posision INTEGER, createDate REAL, modifiedDate REAL, deleteFlag INTEGER);"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return bResult;
    }
    
    bResult = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS tagLink (id INTEGER PRIMARY KEY AUTOINCREMENT, tagId INTEGER, memoId INTEGER, createDate REAL, modifiedDate REAL);"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return bResult;
    }
    
    [db commit];
    return bResult;
}

- (NSArray*)tags
{
    NSMutableArray* tags = [[NSMutableArray alloc] init];
    NSString *sql = @"select id, name, posision, datetime(createDate, 'localtime') cDate, datetime(modifiedDate,'localtime') mDate from tag where deleteFlag = 0 order by posision desc;";
    FMResultSet* result = [db executeQuery:sql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [result close];
        return tags;
    }
    
    while ([result next]) {
        Tag *tag = [Tag new];
        tag.tagId = [result intForColumn:@"id"];
        tag.name = [result stringForColumn:@"name"];
        tag.posision = [result intForColumn:@"posision"];
        
        NSString *cDate = [result stringForColumn:@"cDate"];
        NSString *mDate = [result stringForColumn:@"mDate"];
        
        tag.createDate = [DateUtil dateStringToDate:cDate atDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        tag.modifiedDate = [DateUtil dateStringToDate:mDate atDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        
        tag.deleteFlag = 0;
        [tags addObject:tag];
    }
    
    [result close];
    return tags;
}

- (NSArray*)tagForMemo:(Memo*)memo
{
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    
    // メモに関連付けされているタグを取得
    NSString *tagIdsSql = [[NSString alloc] initWithFormat:@"select tagId from tagLink where memoId = %d;", memo.memoid];
    FMResultSet* result = [db executeQuery:tagIdsSql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [result close];
        return nil;
    }
    
    
    // タグIDでsqlを作成
    NSMutableString *sql = [[NSMutableString alloc] initWithString:@"select id, name, posision, datetime(createDate, 'localtime') cDate, datetime(modifiedDate,'localtime') mDate from tag where deleteFlag = 0 "];
    BOOL bFirst = YES;
    while ([result next]) {
        if (bFirst) {
            bFirst = NO;
            [sql appendString:@"and id in("];
        } else {
            [sql appendString:@","];
        }
        [sql appendFormat:@"%d", [result intForColumn:@"tagId"]];
    }
    
    // 対象のタグがtagLinkに無いため空リストを返す
    if (bFirst) {
        return tags;
    }
    
    [sql appendString:@") order by posision desc;"];
    [result close];
    
    NSLog(@"tagForMemo sql: %@", sql);
    
    // 対象のタグを全て取得
    result = [db executeQuery:sql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [result close];
        return nil;
    }
    
    while ([result next]) {
        Tag *tag = [Tag new];
        tag.tagId = [result intForColumn:@"id"];
        tag.name = [result stringForColumn:@"name"];
        tag.posision = [result intForColumn:@"posision"];
        
        NSString *cDate = [result stringForColumn:@"cDate"];
        NSString *mDate = [result stringForColumn:@"mDate"];
        
        tag.createDate = [DateUtil dateStringToDate:cDate atDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        tag.modifiedDate = [DateUtil dateStringToDate:mDate atDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        
        tag.deleteFlag = 0;
        [tags addObject:tag];
    }
    
    [result close];
    return tags;
}

- (int)count
{
    FMResultSet* result = [db executeQuery:@"select count(id) countId from tag where deleteFlag = 0;"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [result close];
        return 0;
    }

    [result next];
    int count = [result intForColumn:@"countId"];
    [result close];
    return count;
}

- (int)countOfMemo:(Tag*)tag
{
    NSString *sql = [[NSString alloc] initWithFormat:@"select count(id) countId from tagLink where tagId = %d;", tag.tagId];
    FMResultSet* result = [db executeQuery:sql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [result close];
        return 0;
    }
    
    [result next];
    int count = [result intForColumn:@"countId"];
    [result close];
    return count;
}

- (BOOL)add:(Tag*)tag
{
    // 現在時刻を文字列で取得
    NSDate *nowDateForGMT = [NSDate date];
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd hh:mm:ss" setTimeZone:timeZoneUTC];
    
    [db beginTransaction];
    
    NSString *selectSql = [[NSString alloc] initWithFormat:@"select max(posision) maxPosision from tag where deleteFlag = 0;"];
    FMResultSet *result = [db executeQuery:selectSql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [result close];
        [db rollback];
        return NO;
    }
    
    // posisionの最大値 + 1を取得
    [result next];
    int newPosision = [result intForColumn:@"maxPosision"] + 1;
    [result close];
    
    // posisionを更新してinsert
    tag.posision = newPosision;
    NSString *insertSql = [[NSString alloc] initWithFormat:@"insert into tag(name, posision, createDate, modifiedDate, deleteFlag) values('%@', %d, julianday('%@'), julianday('%@'), 0)", tag.name, tag.posision, strDate, strDate];
    BOOL bResult = [db executeUpdate:insertSql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return NO;
    }
    
    [db commit];
    return bResult;
}

- (BOOL)addTagLink:(Memo*)memo forLinkTag:(Tag*)tag
{
    // 現在時刻を文字列で取得
    NSDate *nowDateForGMT = [NSDate date];
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd hh:mm:ss" setTimeZone:timeZoneUTC];
    
    [db beginTransaction];
    
    NSString *insertSql = [[NSString alloc] initWithFormat:@"insert into tagLink(tagId, memoId, createDate, modifiedDate) values(%d, %d, julianday('%@'), julianday('%@'))", tag.tagId, memo.memoid, strDate, strDate];
    BOOL bResult = [db executeUpdate:insertSql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return NO;
    }
    
    [db commit];
    return bResult;
}

- (BOOL)update:(Tag*)tag
{
    return NO;
}

- (BOOL)allUpdate:(NSArray*)tags
{
    return NO;
}

- (BOOL)remove:(Tag*)tag
{
    // 現在時刻を文字列で取得
    NSDate *nowDateForGMT = [NSDate date];
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd hh:mm:ss" setTimeZone:timeZoneUTC];
    
    [db beginTransaction];
    
    // タグリンクを削除
    NSString *removeTagLinkSql = [[NSString alloc] initWithFormat:@"delete from tagLink where tagId = %d", tag.tagId];
    BOOL bResult = [db executeUpdate:removeTagLinkSql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return NO;
    }
    
    // タグを削除
    NSString *deleteTagSql = [[NSString alloc] initWithFormat:@"update tag set deleteFlag = 1, modifiedDate = julianday('%@') where id = %d", strDate, tag.tagId];
    bResult = [db executeUpdate:deleteTagSql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return NO;
    }
    
    [db commit];
    return bResult;
}

- (BOOL)removeTagLink:(Memo*)memo forLinkTag:(Tag*)tag
{
    [db beginTransaction];
    // タグリンクを削除
    NSString *removeTagLinkSql = [[NSString alloc] initWithFormat:@"delete from tagLink where tagId = %d and memoId = %d;", tag.tagId, memo.memoid];
    BOOL bResult = [db executeUpdate:removeTagLinkSql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return NO;
    }
    
    [db commit];
    return bResult;
}

// 自動インクリメントキーの現在の最大値を取得
- (int)maxRefCount
{
    FMResultSet *result = [db executeQuery:@"select MAX(id) as maxRefCount from tag"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [result close];
        return 0;
    }
    
    [result next];
    int maxRefCount = [result intForColumn:@"maxRefCount"];
    [result close];
    return maxRefCount;
}


@end
