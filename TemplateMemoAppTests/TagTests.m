//
//  TagTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/06.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TagTests.h"
#import "Tag.h"
#import "DateUtil.h"

@implementation TagTests

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
    NSString *name = @"tag name";
    NSString *name2 = @"タグ名";
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
    
    STAssertNotNil(tag, @"タグ1がnil");
    STAssertEquals(tag.tagId, 1, @"タグ1ID異常");
    STAssertEquals(tag.posision, 1, @"タグ1posision異常");
    STAssertEqualObjects(tag.name, name, @"タグ1name異常");
    STAssertEqualObjects(tag.createDate, createDate, @"タグ1createDate異常");
    STAssertEqualObjects(tag.modifiedDate, modifiedDate, @"タグ1modifiedDate異常");
    STAssertFalse(tag.deleteFlag, @"タグ1deleteFlag異常");
    
    STAssertNotNil(tag2, @"タグ2がnil");
    STAssertEquals(tag2.tagId, 2, @"タグ2ID異常");
    STAssertEquals(tag2.posision, 2, @"タグ2posision異常");
    STAssertEqualObjects(tag2.name, name2, @"タグ2name異常");
    STAssertEqualObjects(tag2.createDate, createDate2, @"タグ2createDate異常");
    STAssertEqualObjects(tag2.modifiedDate, modifiedDate2, @"タグ2modifiedDate異常");
    STAssertTrue(tag2.deleteFlag, @"タグ2deleteFlag異常");
}

//- (void)testEquals
//{
//    NSString *name = @"tag name";
//    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
//    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
//    
//    Tag *tag = [[Tag alloc] init];
//    tag.tagId = 1;
//    tag.name = [name mutableCopy];
//    tag.createDate = createDate;
//    tag.modifiedDate = modifiedDate;
//    tag.deleteFlag = 0;
//    
//    Tag *tag2 = [[Tag alloc] init];
//    tag2.tagId = 1;
//    tag2.name = [name mutableCopy];
//    tag2.createDate = createDate;
//    tag2.modifiedDate = modifiedDate;
//    tag2.deleteFlag = 0;
//    
//    STAssertEqualObjects(tag, tag, @"tag tag isEquals 同一インスタンス異常");
//    STAssertEqualObjects(tag, tag2, @"tag tag2 isEquals 同値異常");
//}
//
//- (void)testHash
//{
//    NSString *name = @"tag name";
//    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
//    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
//    
//    Tag *tag = [[Tag alloc] init];
//    tag.tagId = 1;
//    tag.name = [name mutableCopy];
//    tag.createDate = createDate;
//    tag.modifiedDate = modifiedDate;
//    tag.deleteFlag = 0;
//    
//    Tag *tag2 = [[Tag alloc] init];
//    tag2.tagId = 1;
//    tag2.name = [name mutableCopy];
//    tag2.createDate = createDate;
//    tag2.modifiedDate = modifiedDate;
//    tag2.deleteFlag = 0;
//    
//    STAssertEquals(tag.hash, tag.hash, @"同一インスタンスのハッシュ値異常");
//    STAssertEquals(tag.hash, tag2.hash, @"同値インスタンスのハッシュ値異常");
//}

@end
