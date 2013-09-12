//
//  TagLinkTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/09.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TagLinkTests.h"
#import "TagLink.h"
#import "Memo.h"
#import "Tag.h"
#import "DateUtil.h"

@implementation TagLinkTests

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
    tag1.deleteFlag = NO;
    
    Tag *tag2 = [[Tag alloc] init];
    tag2.tagId = 2;
    tag2.name = [tagName2 mutableCopy];
    tag2.posision = 2;
    tag2.createDate = createDate;
    tag2.modifiedDate = modifiedDate;
    tag2.deleteFlag = YES;
    
    
    NSString *body1 = @"memo bod";
    NSString *body2 = @"メモ本文";
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
    
    TagLink *tagLink1 = [[TagLink alloc] init];
    tagLink1.tag = tag1;
    tagLink1.memos = @[memo1, memo2];
    
    TagLink *tagLink2 = [[TagLink alloc] init];
    tagLink2.tag = tag2;
    tagLink2.memos = @[memo2];
    
    STAssertEqualObjects(tagLink1.tag, tag1, @"タグリンク1のtagが異なります");
    STAssertEqualObjects(tagLink1.memos[0], memo1, @"タグリンク1のmemo[0]が異なります");
    STAssertEqualObjects(tagLink1.memos[1], memo2, @"タグリンク1のmemo[1]が異なります");
    
    STAssertEqualObjects(tagLink2.tag, tag2, @"タグリンク2のtagが異なります");
    STAssertEqualObjects(tagLink2.memos[0], memo2, @"タグリンク2のmemo[0]が異なります");
}

@end
