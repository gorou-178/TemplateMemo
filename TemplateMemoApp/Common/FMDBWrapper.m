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
    DDLogVerbose(@"FMDBWrapper: init");
    self = [super init];
    [self createDBFilePath:@"database.sqlite"];
    [self createDB];
    return self;
}

- (id)initWithDataBaseFileName:(NSString *)fileName
{
    self = [super init];
    [self createDBFilePath:fileName];
    [self createDB];
    return self;
}

- (void)createDB
{
    self.db = [FMDatabase databaseWithPath:strDBFilePath];
    [self.db open];
}

- (void)createDBFilePath:(NSString *)fileName
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString* dir = [paths objectAtIndex:0];
    strDBFilePath = [[NSString alloc] initWithString:[dir stringByAppendingPathComponent:fileName]];
    DDLogVerbose(@"DBファイル: %@", strDBFilePath);
}

// デストラクタ
- (void)dealloc
{
    strDBFilePath = nil;
    if (self.db != nil) {
        [self.db close];
    }
}

- (BOOL)open
{
    return [self.db open];
}

// databaseファイルを最適化
- (BOOL)vacuum
{
//    [self.db beginTransaction];
    
    BOOL bResult = [self.db executeUpdate:@"vacuum"];
    if ([self.db hadError]) {
        DDLogError(@"DBエラー(ロールバック): %@ %@ code = %d >> %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [self.db lastErrorCode], [self.db lastErrorMessage]);
//        [self.db rollback];
        return NO;
    }
    
//    [self.db commit];
    return bResult;
}

@end
