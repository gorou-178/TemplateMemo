//
//  TemplateMemoTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/09.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TemplateMemoTests.h"
#import "TemplateMemo.h"
#import "DateUtil.h"

@implementation TemplateMemoTests

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
    NSString *templateName1 = @"template name";
    NSString *templateName2 = @"てんぷれ名";
    NSString *templateBody1 = @"template body";
    NSString *templateBody2 = @"てんぷれ本文";
    NSString *templateLabel1 = @"template label";
    NSString *templateLabel2 = @"てんぷれラベル";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    TemplateMemo *templateMemo1 = [[TemplateMemo alloc] init];
    templateMemo1.templateId = 1;
    templateMemo1.name = [templateMemo1 mutableCopy];
    templateMemo1.body = [templateBody1 mutableCopy];
    templateMemo1.createDate = createDate;
    templateMemo1.modifiedDate = modifiedDate;
    templateMemo1.deleteFlag = NO;
    templateMemo1.row = 1;
    templateMemo1.labelText = [templateLabel1 mutableCopy];
    
    TemplateMemo *templateMemo2 = [[TemplateMemo alloc] init];
    templateMemo2.templateId = 2;
    templateMemo2.name = [templateMemo2 mutableCopy];
    templateMemo2.body = [templateBody2 mutableCopy];
    templateMemo2.createDate = createDate;
    templateMemo2.modifiedDate = modifiedDate;
    templateMemo2.deleteFlag = YES;
    templateMemo2.row = 2;
    templateMemo2.labelText = [templateLabel2 mutableCopy];
    
    STAssertEquals(templateMemo1.templateId, 1, @"てんぷれ1のtemplateIdが異常");
    STAssertEqualObjects(templateMemo1.name, [templateName1 mutableCopy], @"てんぷれ1のnameが異常");
    STAssertEqualObjects(templateMemo1.body, [templateBody1 mutableCopy], @"てんぷれ1のbodyが異常");
    STAssertEqualObjects(templateMemo1.createDate, createDate, @"てんぷれ1のcreateDateが異常");
    STAssertEqualObjects(templateMemo1.modifiedDate, modifiedDate, @"てんぷれ1のmodifiedDateが異常");
    STAssertEquals(templateMemo1.deleteFlag, 0, @"てんぷれ1のdeleteFlagが異常");
    STAssertEquals(templateMemo1.row, 1, @"てんぷれ1のrowが異常");
    STAssertEqualObjects(templateMemo1.labelText, templateLabel1, @"てんぷれ1のlabelTextが異常");
    
    STAssertEquals(templateMemo2.templateId, 1, @"てんぷれ2のtemplateIdが異常");
    STAssertEqualObjects(templateMemo2.name, [templateName2 mutableCopy], @"てんぷれ2のnameが異常");
    STAssertEqualObjects(templateMemo2.body, [templateBody2 mutableCopy], @"てんぷれ2のbodyが異常");
    STAssertEqualObjects(templateMemo2.createDate, createDate, @"てんぷれ2のcreateDateが異常");
    STAssertEqualObjects(templateMemo2.modifiedDate, modifiedDate, @"てんぷれ2のmodifiedDateが異常");
    STAssertEquals(templateMemo2.deleteFlag, 1, @"てんぷれ2のdeleteFlagが異常");
    STAssertEquals(templateMemo2.row, 2, @"てんぷれ2のrowが異常");
    STAssertEqualObjects(templateMemo1.labelText, templateLabel2, @"てんぷれ2のlabelTextが異常");
}

- (void)testArchive
{
    NSString *templateName1 = @"template name";
    NSString *templateBody1 = @"template body";
    NSString *templateLabel1 = @"template label";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    TemplateMemo *templateMemo1 = [[TemplateMemo alloc] init];
    templateMemo1.templateId = 1;
    templateMemo1.name = [templateName1 mutableCopy];
    templateMemo1.body = [templateBody1 mutableCopy];
    templateMemo1.createDate = createDate;
    templateMemo1.modifiedDate = modifiedDate;
    templateMemo1.deleteFlag = NO;
    templateMemo1.row = 1;
    templateMemo1.labelText = [templateLabel1 mutableCopy];
    
    NSData *binary = [NSKeyedArchiver archivedDataWithRootObject:templateMemo1];
    TemplateMemo *archiveTemplateMemo = [NSKeyedUnarchiver unarchiveObjectWithData:binary];
    
    STAssertEqualObjects(templateMemo1, archiveTemplateMemo, @"てんぷれ1とアーカイブ後のオブジェクトが異なる");
}

- (void)testMutableCopy
{
    NSString *templateName1 = @"template name";
    NSString *templateBody1 = @"template body";
    NSString *templateLabel1 = @"template label";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    TemplateMemo *templateMemo1 = [[TemplateMemo alloc] init];
    templateMemo1.templateId = 1;
    templateMemo1.name = [templateName1 mutableCopy];
    templateMemo1.body = [templateBody1 mutableCopy];
    templateMemo1.createDate = createDate;
    templateMemo1.modifiedDate = modifiedDate;
    templateMemo1.deleteFlag = NO;
    templateMemo1.row = 1;
    templateMemo1.labelText = [templateLabel1 mutableCopy];
    
    TemplateMemo *copyTemplateMemo = [templateMemo1 mutableCopy];
    
    STAssertEqualObjects(templateMemo1, copyTemplateMemo, @"てんぷれ1のmutableCopyが異常");
}

- (void)testHash
{
    NSString *templateName1 = @"template name";
    NSString *templateBody1 = @"template body";
    NSString *templateLabel1 = @"template label";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    TemplateMemo *templateMemo1 = [[TemplateMemo alloc] init];
    templateMemo1.templateId = 1;
    templateMemo1.name = [templateName1 mutableCopy];
    templateMemo1.body = [templateBody1 mutableCopy];
    templateMemo1.createDate = createDate;
    templateMemo1.modifiedDate = modifiedDate;
    templateMemo1.deleteFlag = NO;
    templateMemo1.row = 1;
    templateMemo1.labelText = [templateLabel1 mutableCopy];
    
    TemplateMemo *templateMemo2 = [[TemplateMemo alloc] init];
    templateMemo2.templateId = 1;
    templateMemo2.name = [templateName1 mutableCopy];
    templateMemo2.body = [templateBody1 mutableCopy];
    templateMemo2.createDate = createDate;
    templateMemo2.modifiedDate = modifiedDate;
    templateMemo2.deleteFlag = NO;
    templateMemo2.row = 1;
    templateMemo2.labelText = [templateLabel1 mutableCopy];
    
    STAssertEquals(templateMemo1.hash, templateMemo1.hash, @"てんぷれ1の同一インスタンスのhashが異なる");
    STAssertEquals(templateMemo1.hash, templateMemo2.hash, @"てんぷれ1の同値インスタンスのhashが異なる");
}

- (void)testEquals
{
    NSString *templateName1 = @"template name";
    NSString *templateBody1 = @"template body";
    NSString *templateLabel1 = @"template label";
    NSDate *createDate = [DateUtil nowDateForLocalTimeZone];
    NSDate *modifiedDate = [DateUtil nowDateForLocalTimeZone];
    
    TemplateMemo *templateMemo1 = [[TemplateMemo alloc] init];
    templateMemo1.templateId = 1;
    templateMemo1.name = [templateName1 mutableCopy];
    templateMemo1.body = [templateBody1 mutableCopy];
    templateMemo1.createDate = createDate;
    templateMemo1.modifiedDate = modifiedDate;
    templateMemo1.deleteFlag = NO;
    templateMemo1.row = 1;
    templateMemo1.labelText = [templateLabel1 mutableCopy];
    
    TemplateMemo *templateMemo2 = [[TemplateMemo alloc] init];
    templateMemo2.templateId = 1;
    templateMemo2.name = [templateName1 mutableCopy];
    templateMemo2.body = [templateBody1 mutableCopy];
    templateMemo2.createDate = createDate;
    templateMemo2.modifiedDate = modifiedDate;
    templateMemo2.deleteFlag = NO;
    templateMemo2.row = 1;
    templateMemo2.labelText = [templateLabel1 mutableCopy];
    
    STAssertEqualObjects(templateMemo1, templateMemo1, @"てんぷれ1の同一インスタンスがequalではない");
    STAssertEqualObjects(templateMemo1, templateMemo2, @"てんぷれ1の同値インスタンスがequalではない");
}

@end
