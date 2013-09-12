//
//  UserDefaultsWrapperTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/09.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "UserDefaultsWrapperTests.h"
#import "UserDefaultsWrapper.h"
#import "FontSizeSettingInfo.h"
#import "FontSize.h"

@implementation UserDefaultsWrapperTests

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

- (void)testSaveAndLoadToObjectForString
{
    NSString *value1 = @"てすと1";
    NSString *value2 = @"てすと2";
    [UserDefaultsWrapper save:@"test1" toObject:value1];
    [UserDefaultsWrapper save:@"test2" toObject:value2];
    
    NSString *result1 = [UserDefaultsWrapper loadToObject:@"test1"];
    NSString *result2 = [UserDefaultsWrapper loadToObject:@"test2"];
    
    STAssertEqualObjects(value1, result1, @"値1とロードデータが異なる");
    STAssertEqualObjects(value2, result2, @"値2とロードデータが異なる");
}

- (void)testSaveAndLoadToObjectForObject
{
    FontSize *fontSize1 = [[FontSize alloc] init];
    fontSize1.size = 10.0;
    FontSize *fontSize2= [[FontSize alloc] init];
    fontSize1.size = 10.5;
    
    [UserDefaultsWrapper save:@"fontSize1" toObject:fontSize1];
    [UserDefaultsWrapper save:@"fontSize2" toObject:fontSize2];
    
    FontSize *result1 = [UserDefaultsWrapper loadToObject:@"fontSize1"];
    FontSize *result2 = [UserDefaultsWrapper loadToObject:@"fontSize2"];
    
    STAssertEqualObjects(fontSize1, result1, @"fontSize1とロードデータが異なる");
    STAssertEqualObjects(fontSize2, result2, @"fontSize2とロードデータが異なる");
}

@end
