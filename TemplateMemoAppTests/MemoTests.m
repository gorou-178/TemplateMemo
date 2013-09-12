//
//  MemoTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/09.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "MemoTests.h"
#import "Memo.h"
#import "DateUtil.h"

@implementation MemoTests

#pragma mark - Clean up Method

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testProperties
{
    NSString *body1 = @"memo bod";
    NSString *body2 = @"メモ本文";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    Memo *memo1 = [[Memo alloc] init];
    memo1.memoid = 1;
    memo1.body = [body1 mutableCopy];
    memo1.createDate = createDate;
    memo1.modifiedDate = modifiedDate;
    memo1.deleteFlag = NO;
    
    Memo *memo2 = [[Memo alloc] init];
    memo2.memoid = 2;
    memo2.body = [body2 mutableCopy];
    memo2.createDate = createDate;
    memo2.modifiedDate = modifiedDate;
    memo2.deleteFlag = YES;
    
    STAssertEquals(memo1.memoid, 1, @"メモ1のmemoidが異常");
    STAssertEqualObjects(memo1.body, body1, @"メモ1のbodyが異常");
    STAssertEqualObjects(memo1.createDate, createDate, @"メモ1のcreateDateが異常");
    STAssertEqualObjects(memo1.modifiedDate, modifiedDate, @"メモ1のcreateDateが異常");
    STAssertEquals(memo1.deleteFlag, 0, @"メモ1のdeleteFlagが異常");
    
    STAssertEquals(memo2.memoid, 2, @"メモ2のmemoidが異常");
    STAssertEqualObjects(memo2.body, body2, @"メモ2のbodyが異常");
    STAssertEqualObjects(memo2.createDate, createDate, @"メモ2のcreateDateが異常");
    STAssertEqualObjects(memo2.modifiedDate, modifiedDate, @"メモ2のcreateDateが異常");
    STAssertEquals(memo2.deleteFlag, 1, @"メモ2のdeleteFlagが異常");
}

- (void)testHash
{
    NSString *body1 = @"メモ本文";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    Memo *memo1 = [[Memo alloc] init];
    memo1.memoid = 1;
    memo1.body = [body1 mutableCopy];
    memo1.createDate = createDate;
    memo1.modifiedDate = modifiedDate;
    memo1.deleteFlag = NO;
    
    Memo *memo2 = [[Memo alloc] init];
    memo2.memoid = 1;
    memo2.body = [body1 mutableCopy];
    memo2.createDate = createDate;
    memo2.modifiedDate = modifiedDate;
    memo2.deleteFlag = NO;
    
    STAssertEquals(memo1.hash, memo1.hash, @"メモ1のhashが同一インスタンスで異なります");
    STAssertEquals(memo1.hash, memo2.hash, @"メモ1とメモ2が同値であるのにhashが異なります");
}

- (void)testEquals
{
    NSString *body1 = @"メモ本文";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    Memo *memo1 = [[Memo alloc] init];
    memo1.memoid = 1;
    memo1.body = [body1 mutableCopy];
    memo1.createDate = createDate;
    memo1.modifiedDate = modifiedDate;
    memo1.deleteFlag = NO;
    
    Memo *memo2 = [[Memo alloc] init];
    memo2.memoid = 1;
    memo2.body = [body1 mutableCopy];
    memo2.createDate = createDate;
    memo2.modifiedDate = modifiedDate;
    memo2.deleteFlag = NO;
    
    STAssertEqualObjects(memo1, memo1, @"メモ1が同一インスタンスでequalではありません");
    STAssertEqualObjects(memo1, memo2, @"メモ1とメモ2が同値であるのにequalではありません");
}

@end
