//
//  MemoTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/06.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "MemoTests.h"
#import "Memo.h"
#import "DateUtil.h"

@implementation MemoTests

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

- (void)testMemoProperties
{
    NSString *body = @"memo body";
    NSString *body2 = @"メモ本文";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *createDate2 = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate2 = [DateUtil nowDateForLocalTimeZone];
    
    Memo *memo = [[Memo alloc] init];
    memo.memoid = 1;
    memo.body = [body mutableCopy];
    memo.createDate = createDate;
    memo.modifiedDate = modifiedDate;
    memo.deleteFlag = 0;
    
    Memo *memo2 = [[Memo alloc] init];
    memo2.memoid = 2;
    memo2.body = [body2 mutableCopy];
    memo2.createDate = createDate2;
    memo2.modifiedDate = modifiedDate2;
    memo2.deleteFlag = 1;
    
    STAssertNotNil(memo, @"メモ1がnil");
    STAssertEquals(memo.memoid, 1, @"メモID異常");
    STAssertEqualObjects(memo.body, body, @"メモbody異常");
    STAssertEqualObjects(memo.createDate, createDate, @"メモcreateDate異常");
    STAssertEqualObjects(memo.modifiedDate, modifiedDate, @"メモmodifiedDate異常");
    STAssertFalse(memo.deleteFlag, @"メモdeleteFlag異常");
    
    STAssertNotNil(memo2, @"メモ1がnil");
    STAssertEquals(memo2.memoid, 2, @"メモ2ID異常");
    STAssertEqualObjects(memo2.body, body2, @"メモ2body異常");
    STAssertEqualObjects(memo2.createDate, createDate2, @"メモ2createDate異常");
    STAssertEqualObjects(memo2.modifiedDate, modifiedDate2, @"メモ2modifiedDate異常");
    STAssertTrue(memo2.deleteFlag, @"メモ2deleteFlag異常");
}

- (void)testEquals
{
    NSString *body = @"memo body";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    Memo *memo = [[Memo alloc] init];
    memo.memoid = 1;
    memo.body = [body mutableCopy];
    memo.createDate = createDate;
    memo.modifiedDate = modifiedDate;
    memo.deleteFlag = 0;
    
    Memo *memo2 = [[Memo alloc] init];
    memo2.memoid = 1;
    memo2.body = [body mutableCopy];
    memo2.createDate = createDate;
    memo2.modifiedDate = modifiedDate;
    memo2.deleteFlag = 0;
    
    STAssertEqualObjects(memo, memo, @"memo memo isEquals 同一インスタンス異常");
    STAssertEqualObjects(memo, memo2, @"memo memo2 isEquals 同値異常");
}

- (void)testHash
{
    NSString *body = @"memo body";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    Memo *memo = [[Memo alloc] init];
    memo.memoid = 1;
    memo.body = [body mutableCopy];
    memo.createDate = createDate;
    memo.modifiedDate = modifiedDate;
    memo.deleteFlag = 0;
    
    Memo *memo2 = [[Memo alloc] init];
    memo2.memoid = 1;
    memo2.body = [body mutableCopy];
    memo2.createDate = createDate;
    memo2.modifiedDate = modifiedDate;
    memo2.deleteFlag = 0;
    
    STAssertEquals(memo.hash, memo.hash, @"同一インスタンスのハッシュ値異常");
    STAssertEquals(memo.hash, memo2.hash, @"同値インスタンスのハッシュ値異常");
}

@end
