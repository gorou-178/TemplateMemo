//
//  TemplateMemoTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/07.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TemplateMemoTests.h"
#import "TemplateMemo.h"
#import "DateUtil.h"

@implementation TemplateMemoTests

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
    NSString *name = @"temple name";
    NSString *name2 = @"てんぷれ名";
    NSString *body = @"temple body";
    NSString *body2 = @"てんぷれ本文";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *createDate2 = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate2 = [DateUtil nowDateForLocalTimeZone];
    
    TemplateMemo *templateMemo = [[TemplateMemo alloc] init];
    templateMemo.templateId = 1;
    templateMemo.name = [name mutableCopy];
    templateMemo.body = [body mutableCopy];
    templateMemo.createDate = createDate;
    templateMemo.modifiedDate = modifiedDate;
    templateMemo.deleteFlag = 0;
    
    TemplateMemo *templateMemo2 = [[TemplateMemo alloc] init];
    templateMemo2.templateId = 2;
    templateMemo2.name = [name2 mutableCopy];
    templateMemo2.body = [body2 mutableCopy];
    templateMemo2.createDate = createDate2;
    templateMemo2.modifiedDate = modifiedDate2;
    templateMemo2.deleteFlag = 1;
    
    STAssertNotNil(templateMemo, @"てんぷれ1がnil");
    STAssertEquals(templateMemo.templateId, 1, @"てんぷれ1ID異常");
    STAssertEqualObjects(templateMemo.name, name, @"てんぷれ1name異常");
    STAssertEqualObjects(templateMemo.body, body, @"てんぷれ1body異常");
    STAssertEqualObjects(templateMemo.createDate, createDate, @"てんぷれ1createDate異常");
    STAssertEqualObjects(templateMemo.modifiedDate, modifiedDate, @"てんぷれ1modifiedDate異常");
    STAssertFalse(templateMemo.deleteFlag, @"てんぷれ1deleteFlag異常");
    
    STAssertNotNil(templateMemo2, @"てんぷれ2がnil");
    STAssertEquals(templateMemo2.templateId, 2, @"てんぷれ2ID異常");
    STAssertEqualObjects(templateMemo2.name, name2, @"てんぷれ2name異常");
    STAssertEqualObjects(templateMemo2.body, body2, @"てんぷれ2body異常");
    STAssertEqualObjects(templateMemo2.createDate, createDate2, @"てんぷれ2createDate異常");
    STAssertEqualObjects(templateMemo2.modifiedDate, modifiedDate2, @"てんぷれ2modifiedDate異常");
    STAssertTrue(templateMemo2.deleteFlag, @"てんぷれ2deleteFlag異常");
}

- (void)testEquals
{
    NSString *name = @"てんぷれ名";
    NSString *body = @"てんぷれ本文";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];

    TemplateMemo *templateMemo = [[TemplateMemo alloc] init];
    templateMemo.templateId = 1;
    templateMemo.name = [name mutableCopy];
    templateMemo.body = [body mutableCopy];
    templateMemo.createDate = createDate;
    templateMemo.modifiedDate = modifiedDate;
    templateMemo.deleteFlag = 0;

    TemplateMemo *templateMemo2 = [[TemplateMemo alloc] init];
    templateMemo2.templateId = 1;
    templateMemo2.name = [name mutableCopy];
    templateMemo2.body = [body mutableCopy];
    templateMemo2.createDate = createDate;
    templateMemo2.modifiedDate = modifiedDate;
    templateMemo2.deleteFlag = 0;

    STAssertEqualObjects(templateMemo, templateMemo, @"templateMemo templateMemo isEquals 同一インスタンス異常");
    STAssertEqualObjects(templateMemo, templateMemo2, @"templateMemo templateMemo2 isEquals 同値異常");
}

- (void)testHash
{
    NSString *name = @"tag name";
    NSString *body = @"てんぷれ本文";
    NSString *labelText = @"てんぷれラベル";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];

    TemplateMemo *templateMemo = [[TemplateMemo alloc] init];
    templateMemo.templateId = 1;
    templateMemo.name = [name mutableCopy];
    templateMemo.body = [body mutableCopy];
    templateMemo.createDate = createDate;
    templateMemo.modifiedDate = modifiedDate;
    templateMemo.deleteFlag = 0;
    templateMemo.row = 1;
    templateMemo.labelText = [labelText mutableCopy];
    
    TemplateMemo *templateMemo2 = [[TemplateMemo alloc] init];
    templateMemo2.templateId = 1;
    templateMemo2.name = [name mutableCopy];
    templateMemo2.body = [body mutableCopy];
    templateMemo2.createDate = createDate;
    templateMemo2.modifiedDate = modifiedDate;
    templateMemo2.deleteFlag = 0;
    templateMemo2.row = 1;
    templateMemo2.labelText = [labelText mutableCopy];

    STAssertEquals(templateMemo.hash, templateMemo.hash, @"てんぷれ同一インスタンスのハッシュ値異常");
    STAssertEquals(templateMemo.hash, templateMemo2.hash, @"てんぷれ同値インスタンスのハッシュ値異常");
}

- (void)testArchive
{
    NSString *name = @"tag name";
    NSString *body = @"てんぷれ本文";
    NSString *labelText = @"てんぷれラベル";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    TemplateMemo *templateMemo = [[TemplateMemo alloc] init];
    templateMemo.templateId = 1;
    templateMemo.name = [name mutableCopy];
    templateMemo.body = [body mutableCopy];
    templateMemo.createDate = createDate;
    templateMemo.modifiedDate = modifiedDate;
    templateMemo.deleteFlag = 0;
    templateMemo.row = 1;
    templateMemo.labelText = [labelText mutableCopy];
    
    NSData *binary = [NSKeyedArchiver archivedDataWithRootObject:templateMemo];
    TemplateMemo *archiveTemplateMemo = [NSKeyedUnarchiver unarchiveObjectWithData:binary];
    
    STAssertNotNil(binary, @"アーカイブオブジェクト異常");
    STAssertNotNil(archiveTemplateMemo, @"アンアーカイブオブジェクト異常");
    STAssertEquals(templateMemo.hash, archiveTemplateMemo.hash, @"アーカイブ前後オブジェクトのEqual異常");
}

- (void)testMutableCopy
{
    NSString *name = @"tag name";
    NSString *body = @"てんぷれ本文";
    NSString *labelText = @"てんぷれラベル";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    TemplateMemo *templateMemo = [[TemplateMemo alloc] init];
    templateMemo.templateId = 1;
    templateMemo.name = [name mutableCopy];
    templateMemo.body = [body mutableCopy];
    templateMemo.createDate = createDate;
    templateMemo.modifiedDate = modifiedDate;
    templateMemo.deleteFlag = 0;
    templateMemo.row = 1;
    templateMemo.labelText = [labelText mutableCopy];
    
    TemplateMemo *copyTemplate = [templateMemo mutableCopy];
    
    STAssertNotNil(copyTemplate, @"templateMemo mutableCopy インスタンス異常");
    STAssertEquals(templateMemo.hash, copyTemplate.hash, @"templateMemo mutableCopy hash異常");
}


@end
