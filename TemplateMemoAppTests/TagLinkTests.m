//
//  LinkTagTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/07.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TagLinkTests.h"
#import "TagLink.h"
#import "Tag.h"
#import "Memo.h"
#import "DateUtil.h"

@implementation TagLinkTests

- (void)testProperties
{
    NSString *name = @"tag name";
    NSString *name2 = @"タグ名";
    NSString *body = @"メモ本文";
    NSString *body2 = @"memo body";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *createDate2 = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate2 = [DateUtil nowDateForLocalTimeZone];
    
    Tag *tag = [[Tag alloc] init];
    tag.tagId = 1;
    tag.posision = 1;
    tag.name = [name mutableCopy];
    tag.createDate = createDate;
    tag.modifiedDate = modifiedDate;
    tag.deleteFlag = 0;
    
    Tag *tag2 = [[Tag alloc] init];
    tag2.tagId = 2;
    tag2.posision = 2;
    tag2.name = [name2 mutableCopy];
    tag2.createDate = createDate2;
    tag2.modifiedDate = modifiedDate2;
    tag2.deleteFlag = 1;
    
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
    
    TagLink *tagLink = [[TagLink alloc] init];
    tagLink.tag = tag;
    tagLink.memos = @[memo, memo2];
    
    TagLink *tagLink2 = [[TagLink alloc] init];
    tagLink2.tag = tag2;
    tagLink2.memos = @[memo2];
    
    STAssertEqualObjects(tagLink.tag, tag, @"タグリンク1 tag equal異常");
    STAssertEqualObjects(tagLink.memos[0], memo, @"タグリンク1 memos[0] equal異常");
    STAssertEqualObjects(tagLink.memos[1], memo2, @"タグリンク1 memos[1] equal異常");
    
    STAssertEqualObjects(tagLink2.tag, tag2, @"タグリンク2 tag equal異常");
    STAssertEqualObjects(tagLink2.memos[0], memo2, @"タグリンク2 memos[0] equal異常");
}

@end
