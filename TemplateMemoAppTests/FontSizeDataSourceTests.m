//
//  FontSizeDataSourceTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/09.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "FontSizeDataSourceTests.h"
#import "UserDefaultsWrapper.h"
#import "FontSizeSettingInfo.h"
#import "FontSizeDataSource.h"
#import "FontSize.h"

@implementation FontSizeDataSourceTests

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

- (void)testInit
{
    FontSizeDataSource *fontSizeDataSource = [[FontSizeDataSource alloc] init];
    NSArray *dataList = fontSizeDataSource.dataList;
    
    STAssertEquals(((FontSize*)dataList[0]).row, 0, @"フォントサイズ設定データ0 - rowが異常");
    STAssertEquals(((FontSize*)dataList[0]).size, 12.0f, @"フォントサイズ設定データ0 - sizeが異常");
    STAssertEquals(((FontSize*)dataList[1]).row, 1, @"フォントサイズ設定データ1 - rowが異常");
    STAssertEquals(((FontSize*)dataList[1]).size, 14.0f, @"フォントサイズ設定データ1 - sizeが異常");
    STAssertEquals(((FontSize*)dataList[2]).row, 2, @"フォントサイズ設定データ2 - rowが異常");
    STAssertEquals(((FontSize*)dataList[2]).size, 18.0f, @"フォントサイズ設定データ2 - sizeが異常");
    STAssertEquals(((FontSize*)dataList[3]).row, 3, @"フォントサイズ設定データ3 - rowが異常");
    STAssertEquals(((FontSize*)dataList[3]).size, 24.0f, @"フォントサイズ設定データ3 - sizeが異常");
    STAssertEquals(((FontSize*)dataList[4]).row, 4, @"フォントサイズ設定データ4 - rowが異常");
    STAssertEquals(((FontSize*)dataList[4]).size, 36.0f, @"フォントサイズ設定データ4 - sizeが異常");
}

- (void)testUpdateCellData
{
    FontSizeDataSource *fontSizeDataSource = [[FontSizeDataSource alloc] init];
    NSArray *dataList = fontSizeDataSource.dataList;
    FontSize *fontSize = dataList[4];
    
    FontSizeSettingInfo *fontSizeSettingInfo = [[FontSizeSettingInfo alloc] init];
    [UserDefaultsWrapper save:fontSizeSettingInfo.key toObject:fontSize];
}

@end
