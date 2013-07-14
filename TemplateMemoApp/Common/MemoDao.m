//
//  MemoDao.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/06/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

//TODO: FMDatabasePoolの導入
//TODO: キャッシュの導入(効果ある？)

#import "FMDatabase.h"
#import "DateUtil.h"
#import "MemoDao.h"
#import "Memo.h"
#import "Tag.h"
#import "TagLink.h"

@interface MemoDaoImpl () 

@end

@implementation MemoDaoImpl

// イニシャライザ
- (id)init
{
    NSLog(@"MemoDaoImpl init");
    self = [super init];
    [self createTable];
    return self;
}

// 指定イニシャライザ
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
    
    bResult = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS memo (id INTEGER PRIMARY KEY AUTOINCREMENT, body TEXT, createDate REAL, modifiedDate REAL, deleteFlag INTEGER);"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return bResult;
    }
    
    [db commit];
    
    return bResult;
}

// デストラクタ
- (void)dealloc
{
    NSLog(@"MemoDaoImpl dealloc");
}

//- (void)clearCache
//{
//    cache = nil;
//}

- (NSArray*)memos
{
//    if (cache != nil) {
//        return cache;
//    }
    
//    // デフォルトのタイムゾーンを変更
//    
//    [NSTimeZone setDefaultTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
//    
//    // 現在時刻を取得(GMTの現在時刻を取得。Systemのタイムゾーンではない？)
//    NSDate *now = [NSDate date];
//    NSLog(@"NSDate: %@", now);
//    
//    // 設定されているタイムゾーンでの時刻を取得(結果のdateはGMTだったけど、Systemのタイムゾーン？)
//    NSCalendar * cal = [NSCalendar currentCalendar];
//    NSDateComponents *comps = [cal components:
//                               NSYearCalendarUnit   |
//                               NSMonthCalendarUnit  |
//                               NSDayCalendarUnit    |
//                               NSHourCalendarUnit   |
//                               NSMinuteCalendarUnit |
//                               NSSecondCalendarUnit
//                                     fromDate:now];
//    [comps setCalendar:cal];
//    NSLog(@"DateComponents: %@",[comps date]);
//    
//    // GMT時刻を指定タイムゾーンでの時刻に変換
//    // NSTimeZone systemTimeZone: システムのタイムゾーン
//    // NSTimeZone localTimeZone: アプリ上の現在のタイムゾーン(NSTimeZone setDefaultTimeZoneを行うと変化する)
//    // NSTimeZone defaultTimeZone: アプリ起動時のシステムのタイムゾーン(起動中にタイムゾーンが変わってもそのまま)
//    NSDate *nowJST = [NSDate dateWithTimeIntervalSinceNow:[[NSTimeZone systemTimeZone] secondsFromGMTForDate:now]];
//    NSLog(@"%@: %@", [[NSTimeZone systemTimeZone] name], nowJST);
    
    // TODO:参照渡しでわたすべき？
    NSMutableArray* memos = [[NSMutableArray alloc] init];
    
    FMResultSet* result = [db executeQuery:@"select id, body, datetime(createDate, 'localtime') cDate, datetime(modifiedDate,'localtime') mDate, modifiedDate from memo where deleteFlag = 0 order by modifiedDate desc;"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [result close];
        return memos;
    }
    
    while ([result next]) {
        Memo* memo = [[Memo alloc] init];
        memo.memoid = [result intForColumn:@"id"];
        memo.body = [result stringForColumn:@"body"];
        
        NSString *cDate = [result stringForColumn:@"cDate"];
        NSString *mDate = [result stringForColumn:@"mDate"];
        NSLog(@"mDate: %@", mDate);
        
        memo.createDate = [DateUtil dateStringToDate:cDate atDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        memo.modifiedDate = [DateUtil dateStringToDate:mDate atDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        
        NSLog(@"modifiedDate: %@", memo.modifiedDate);
        
        memo.deleteFlag = 0;
        [memos addObject:memo];
    }
    
    [result close];
    return memos;
}

- (TagLink*)tagMemos:(Tag*)tag
{
    TagLink *tagLink = [TagLink new];
    
    // タグに関連付けられた削除されていないメモを更新日付の降順で取得
    NSString *sql = [[NSString alloc] initWithFormat:@"select m.id, m.body, datetime(m.createDate, 'localtime') m_cDate, datetime(m.modifiedDate, 'localtime') m_mDate from tagLink tl, memo m, tag t where tl.tagId = %d and tl.tagId = t.id and tl.memoId = m.id and t.deleteFlag = 0 and m.deleteFlag = 0 order by m.modifiedDate desc;", tag.tagId];
    
    FMResultSet* result = [db executeQuery:sql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [result close];
        return nil;
    }
    
    NSMutableArray *memos = [NSMutableArray new];
    while ([result next]) {
        Memo* memo = [Memo new];
        memo.memoid = [result intForColumn:@"id"];
        memo.body = [result stringForColumn:@"body"];
        
        NSString *cDate = [result stringForColumn:@"m_cDate"];
        NSString *mDate = [result stringForColumn:@"m_mDate"];
        NSLog(@"mDate: %@", mDate);
        
        memo.createDate = [DateUtil dateStringToDate:cDate atDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        memo.modifiedDate = [DateUtil dateStringToDate:mDate atDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        
        NSLog(@"modifiedDate: %@", memo.modifiedDate);
        
        memo.deleteFlag = 0;
        [memos addObject:memo];
    }
    
    [result close];
    
    //    // キャッシュする
    //    cache = memos.mutableCopy;
    
    tagLink.tag = tag;
    tagLink.memos = memos;
    return tagLink;
}

- (int)count
{
    FMResultSet* result = [db executeQuery:@"select count(id) memoCount from memo where deleteFlag = 0;"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [result close];
        return 0;
    }
    int count = [result intForColumn:@"memoCount"];
    [result close];
    return count;
}

- (BOOL)add:(Memo*)memo
{
    // 現在時刻を文字列で取得
    NSDate *nowDateForGMT = [NSDate date];
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd hh:mm:ss" setTimeZone:timeZoneUTC];
    
    [db beginTransaction];
    
    NSString *sql = [[NSString alloc] initWithFormat:@"insert into memo(body, createDate, modifiedDate, deleteFlag) values('%@', julianday('%@'), julianday('%@'), 0)", memo.body, strDate, strDate];
    
    BOOL bResult = [db executeUpdate:sql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return NO;
    }
    
    [db commit];
    
//    // キャッシュをクリア
//    [self clearCache];
    return bResult;
}

- (BOOL)update:(Memo*)memo
{
    // 現在時刻を文字列で取得
    NSDate *nowDateForGMT = [NSDate date];
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd hh:mm:ss" setTimeZone:timeZoneUTC];
    
    [db beginTransaction];
    
    NSString *sql = [[NSString alloc] initWithFormat:@"update memo set body = '%@', modifiedDate = julianday('%@') where id = %d", memo.body, strDate, memo.memoid];
    
    // TODO: プレースホルダーだと文字列の場合エラーになる？
    //  →正しくsqlが作られない
    BOOL bResult = [db executeUpdate:sql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return NO;
    }
    
    [db commit];
    
    //    // キャッシュをクリア
    //    [self clearCache];
    return bResult;
}

- (BOOL)remove:(Memo*)memo
{
    // 現在時刻を文字列で取得
    NSDate *nowDateForGMT = [NSDate date];
    NSTimeZone *timeZoneUTC = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSString *strDate = [DateUtil dateToString:nowDateForGMT atDateFormat:@"yyyy-MM-dd hh:mm:ss" setTimeZone:timeZoneUTC];

    [db beginTransaction];
    
    // メモの削除は削除フラグを1にすることで実現(modifiedDateは削除した日付で更新)
    NSString *sql = [[NSString alloc] initWithFormat:@"update memo set deleteFlag = 1, modifiedDate = julianday('%@') where id = %d", strDate, memo.memoid];
    
    // TODO: プレースホルダーだと文字列の場合エラーになる？
    //  →正しくsqlが作られない
    BOOL bResult = [db executeUpdate:sql];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [db rollback];
        return NO;
    }
    
    [db commit];
    
    //    // キャッシュをクリア
    //    [self clearCache];
    return bResult;
}

- (int)maxRefCount
{
    NSMutableArray* results = [[NSMutableArray alloc] init];
    FMResultSet* rs = [db executeQuery:@"select MAX(id) as MAX_KEY_VALUE from memo"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        return 0;
    }
    
    while ([rs next]) {
        [results addObject:[rs resultDictionary]];
    }
    
    NSString* maxKeyValue = @"0";
    if([results count]>0){
        maxKeyValue = [[results objectAtIndex:0] objectForKey:@"MAX_KEY_VALUE"];
    }
    
    return [maxKeyValue intValue];
}

@end
