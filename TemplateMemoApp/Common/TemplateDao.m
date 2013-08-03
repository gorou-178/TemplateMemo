//
//  TemplateDao.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/25.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TemplateDao.h"
#import "DateUtil.h"

@implementation TemplateDaoImpl

- (id)init
{
    NSLog(@"TemplateDaoImpl init");
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
    
    bResult = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS templateMemo (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, body TEXT, createDate REAL, modifiedDate REAL, deleteFlag INTEGER);"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return bResult;
    }
    
    [db commit];
    return bResult;
}

- (NSArray *)templates
{
    NSMutableArray* templates = [[NSMutableArray alloc] init];
    
    FMResultSet* result = [db executeQuery:@"select id, name, body, datetime(createDate, 'localtime') cDate, datetime(modifiedDate,'localtime') mDate from templateMemo where deleteFlag = 0 order by modifiedDate desc;"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
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
        
        templateMemo.createDate = [DateUtil dateStringToDate:cDate atDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        templateMemo.modifiedDate = [DateUtil dateStringToDate:mDate atDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        
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
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd hh:mm:ss" setTimeZone:timeZoneUTC];
    
    [db beginTransaction];
    
    NSString *sql = [[NSString alloc] initWithFormat:@"insert into templateMemo(name, body, createDate, modifiedDate, deleteFlag) values('%@', '%@', julianday('%@'), julianday('%@'), 0)", templateMemo.name, templateMemo.body, strDate, strDate];
    
    BOOL bResult = [db executeUpdate:sql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return NO;
    }
    
    [db commit];
    return bResult;
}

- (BOOL)update:(TemplateMemo *)templateMemo
{
    // 現在時刻を文字列で取得
    NSDate *nowDateForGMT = [NSDate date];
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd hh:mm:ss" setTimeZone:timeZoneUTC];
    
    [db beginTransaction];
    
    NSString *sql = [[NSString alloc] initWithFormat:@"update templateMemo set name = '%@', body = '%@', modifiedDate = julianday('%@') where id = %d", templateMemo.name, templateMemo.body, strDate, templateMemo.templateId];
    BOOL bResult = [db executeUpdate:sql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return NO;
    }
    
    [db commit];
    return bResult;
}

- (BOOL)remove:(TemplateMemo *)templateMemo
{
    // 現在時刻を文字列で取得
    NSDate *nowDateForGMT = [NSDate date];
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd hh:mm:ss" setTimeZone:timeZoneUTC];
    
    [db beginTransaction];
    
    // メモの削除は削除フラグを1にすることで実現(modifiedDateは削除した日付で更新)
    NSString *sql = [[NSString alloc] initWithFormat:@"update templateMemo set deleteFlag = 1, modifiedDate = julianday('%@') where id = %d", strDate, templateMemo.templateId];
    
    BOOL bResult = [db executeUpdate:sql];
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
    FMResultSet *result = [db executeQuery:@"select MAX(id) as maxRefCount from templateMemo"];
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
