//
//  TagDao.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/10.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "Tag.h"
#import "TagDao.h"
#import "FMDatabase.h"
#import "DateUtil.h"

@implementation TagDaoImpl

// イニシャライザ
- (id)init
{
    NSLog(@"TagDaoImpl init");
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
    // TODO:参照渡しでわたすべき？
    NSMutableArray* tags = [[NSMutableArray alloc] init];
    
    FMResultSet* result = [db executeQuery:@"select id, name, posision, datetime(createDate, 'localtime') cDate, datetime(modifiedDate,'localtime') mDate from tag where deleteFlag = 0 order by posision;"];
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

- (int)count
{
    FMResultSet* result = [db executeQuery:@"select count(id) from tag where deleteFlag = 0;"];
    if ([db hadError]) {
        NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        [result close];
        return -1;
    }
    
    
}

- (BOOL)add:(Tag*)tag
{
    return NO;
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
    return NO;
}

@end
