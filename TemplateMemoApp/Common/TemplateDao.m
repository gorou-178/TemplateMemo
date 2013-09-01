//
//  TemplateDao.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/25.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TemplateDao.h"
#import "DateUtil.h"

@interface TemplateDaoImpl ()
{
    FMDBWrapper *_fmdb;
}
@end

@implementation TemplateDaoImpl

- (id)init
{
    self = [super init];
    if (self) {
        _fmdb = [[FMDBWrapper alloc] init];
        [self createTable];
    }
    return self;
}

- (id)initWithFMDBWrapper:(FMDBWrapper*)fmdb
{
    self = [super init];
    if (self) {
        _fmdb = fmdb;
        [self createTable];
    }
    return self;
}

- (BOOL)createTable
{
    BOOL bResult = [_fmdb open];
    if ([_fmdb.db hadError]) {
        DDLogError(@"DBエラー: %@ %@ code = %d >> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [_fmdb.db lastErrorCode], [_fmdb.db lastErrorMessage]);
        return bResult;
    }
    
    [_fmdb.db beginTransaction];
    
    bResult = [_fmdb.db executeUpdate:@"CREATE TABLE IF NOT EXISTS templateMemo (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, body TEXT, createDate REAL, modifiedDate REAL, deleteFlag INTEGER);"];
    if ([_fmdb.db hadError]) {
        DDLogError(@"DBエラー(ロールバック): %@ %@ code = %d >> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [_fmdb.db lastErrorCode], [_fmdb.db lastErrorMessage]);
        [_fmdb.db rollback];
        return bResult;
    }
    
    [_fmdb.db commit];
    return bResult;
}

- (NSArray *)templates
{
    NSMutableArray* templates = [[NSMutableArray alloc] init];
    
    FMResultSet* result = [_fmdb.db executeQuery:@"select id, name, body, datetime(createDate, 'localtime') cDate, datetime(modifiedDate,'localtime') mDate from templateMemo where deleteFlag = 0 order by modifiedDate desc;"];
    if ([_fmdb.db hadError]) {
        DDLogError(@"DBエラー: %@ %@ code = %d >> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [_fmdb.db lastErrorCode], [_fmdb.db lastErrorMessage]);
        [result close];
        return templates;
    }
    
    while ([result next]) {
        TemplateMemo *templateMemo = [TemplateMemo new];
        templateMemo.templateId = [result intForColumn:@"id"];
        templateMemo.name = [result stringForColumn:@"name"];
        templateMemo.body = [result stringForColumn:@"body"];
        
        NSString *cDate = [result stringForColumn:@"cDate"];
        NSString *mDate = [result stringForColumn:@"mDate"];
        
        templateMemo.createDate = [DateUtil dateStringToDate:cDate atDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        templateMemo.modifiedDate = [DateUtil dateStringToDate:mDate atDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        templateMemo.deleteFlag = 0;
        [templates addObject:templateMemo];
    }
    
    [result close];
    return templates;
}

- (BOOL)add:(TemplateMemo *)templateMemo
{
    // 現在時刻を文字列で取得
    NSDate *nowDateForGMT = [NSDate date];
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd HH:mm:ss" setTimeZone:timeZoneUTC];
    
    [_fmdb.db beginTransaction];
    
    NSString *sql = [[NSString alloc] initWithFormat:@"insert into templateMemo(name, body, createDate, modifiedDate, deleteFlag) values('%@', '%@', julianday('%@'), julianday('%@'), 0)", templateMemo.name, templateMemo.body, strDate, strDate];
    
    BOOL bResult = [_fmdb.db executeUpdate:sql];
    if ([_fmdb.db hadError]) {
        NSLog(@"Err %d: %@", [_fmdb.db lastErrorCode], [_fmdb.db lastErrorMessage]);
        [_fmdb.db rollback];
        return NO;
    }
    
    [_fmdb.db commit];
    return bResult;
}

- (BOOL)update:(TemplateMemo *)templateMemo
{
    // 現在時刻を文字列で取得
    NSDate *nowDateForGMT = [NSDate date];
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd HH:mm:ss" setTimeZone:timeZoneUTC];
    
    [_fmdb.db beginTransaction];
    
    NSString *sql = [[NSString alloc] initWithFormat:@"update templateMemo set name = '%@', body = '%@', modifiedDate = julianday('%@') where id = %d", templateMemo.name, templateMemo.body, strDate, templateMemo.templateId];
    BOOL bResult = [_fmdb.db executeUpdate:sql];
    if ([_fmdb.db hadError]) {
        DDLogError(@"DBエラー(ロールバック): %@ %@ code = %d >> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [_fmdb.db lastErrorCode], [_fmdb.db lastErrorMessage]);
        [_fmdb.db rollback];
        return NO;
    }
    
    [_fmdb.db commit];
    return bResult;
}

- (BOOL)remove:(TemplateMemo *)templateMemo
{
    // 現在時刻を文字列で取得
    NSDate *nowDateForGMT = [NSDate date];
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd HH:mm:ss" setTimeZone:timeZoneUTC];
    
    [_fmdb.db beginTransaction];
    
    // メモの削除は削除フラグを1にすることで実現(modifiedDateは削除した日付で更新)
    NSString *sql = [[NSString alloc] initWithFormat:@"update templateMemo set deleteFlag = 1, modifiedDate = julianday('%@') where id = %d", strDate, templateMemo.templateId];
    
    BOOL bResult = [_fmdb.db executeUpdate:sql];
    if ([_fmdb.db hadError]) {
        DDLogError(@"DBエラー(ロールバック): %@ %@ code = %d >> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [_fmdb.db lastErrorCode], [_fmdb.db lastErrorMessage]);
        [_fmdb.db rollback];
        return NO;
    }
    
    [_fmdb.db commit];
    return bResult;
}

// 自動インクリメントキーの現在の最大値を取得
- (int)maxRefCount
{
    FMResultSet *result = [_fmdb.db executeQuery:@"select MAX(id) as maxRefCount from templateMemo"];
    if ([_fmdb.db hadError]) {
        DDLogError(@"DBエラー: %@ %@ code = %d >> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [_fmdb.db lastErrorCode], [_fmdb.db lastErrorMessage]);
        [result close];
        return 0;
    }
    
    [result next];
    int maxRefCount = [result intForColumn:@"maxRefCount"];
    [result close];
    return maxRefCount;
}

@end
