//
//  FMDBWrapper.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/10.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "FMDBWrapper.h"

@interface FMDBWrapper ()

@end

@implementation FMDBWrapper

- (id)init
{
    NSLog(@"FMDBWrapper: init");
    self = [super init];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString* dir = [paths objectAtIndex:0];
    strDBFilePath = [[NSString alloc] initWithString:[dir stringByAppendingPathComponent:@"database.sqlite"]];
    NSLog(@"FMDBWrapper: dbPath : %@", strDBFilePath);
    db = [FMDatabase databaseWithPath:strDBFilePath];
    [db open];
    return self;
}

- (id)initWithDataBaseFileName:(NSString *)fileName
{
    NSLog(@"FMDBWrapper: initWithDataBaseFileName");
    self = [super init];
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString* dir = [paths objectAtIndex:0];
    strDBFilePath = [[NSString alloc] initWithString:[dir stringByAppendingPathComponent:fileName]];
    NSLog(@"FMDBWrapper: dbPath : %@", strDBFilePath);
    return self;
}

// デストラクタ
- (void)dealloc
{
    NSLog(@"FMDBWrapper: dealloc");
    strDBFilePath = nil;
    if (db != nil) {
        [db close];
    }
}

- (BOOL)open
{
    db = [FMDatabase databaseWithPath:strDBFilePath];
    if (db == nil) {
        return NO;
    }
    return [db open];
}

@end
