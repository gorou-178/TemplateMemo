//
//  TagTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/09.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TagTests.h"
#import "Tag.h"
#import "DateUtil.h"

@implementation TagTests

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
    NSString *tagName1 = @"tag name";
    NSString *tagName2 = @"タグ名";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    Tag *tag1 = [[Tag alloc] init];
    tag1.tagId = 1;
    tag1.name = [tagName1 mutableCopy];
    tag1.posision = 1;
    tag1.createDate = createDate;
    tag1.modifiedDate = modifiedDate;
    tag1.deleteFlag = 0;
    
    Tag *tag2 = [[Tag alloc] init];
    tag2.tagId = 2;
    tag2.name = [tagName2 mutableCopy];
    tag2.posision = 2;
    tag2.createDate = createDate;
    tag2.modifiedDate = modifiedDate;
    tag2.deleteFlag = 1;
    
    STAssertEquals(tag1.tagId, 1, @"タグ1のtagIdが異なります");
    STAssertEquals(tag1.posision, 1, @"タグ1のposisionが異なります");
    STAssertEqualObjects(tag1.name, tagName1, @"タグ1のnameが異常です");
    STAssertEqualObjects(tag1.createDate, createDate, @"タグ1のcreateDateが異なります");
    STAssertEqualObjects(tag1.modifiedDate, modifiedDate, @"タグ1のmodifiedDateが異なります");
    STAssertEquals(tag1.deleteFlag, 0, @"タグ1のdeleteFlagが異なります");
    
    STAssertEquals(tag2.tagId, 2, @"タグ2のtagIdが異なります");
    STAssertEquals(tag2.posision, 2, @"タグ2のposisionが異なります");
    STAssertEqualObjects(tag2.name, tagName2, @"タグ2のnameが異常です");
    STAssertEqualObjects(tag2.createDate, createDate, @"タグ2のcreateDateが異なります");
    STAssertEqualObjects(tag2.modifiedDate, modifiedDate, @"タグ2のmodifiedDateが異なります");
    STAssertEquals(tag2.deleteFlag, 1, @"タグ2のdeleteFlagが異なります");
}

@end
