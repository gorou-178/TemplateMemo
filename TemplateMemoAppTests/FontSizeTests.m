//
//  FontSizeTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/09.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "FontSizeTests.h"
#import "FontSize.h"

@implementation FontSizeTests

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
    FontSize *fontSize1 = [[FontSize alloc] init];
    fontSize1.size = 10.0;
    
    FontSize *fontSize2 = [[FontSize alloc] init];
    fontSize2.size = 13.0;
    
    STAssertEquals(fontSize1.size, 10.0f, @"fontSize1のsizeが異常");
    STAssertEquals(fontSize2.size, 13.0f, @"fontSize2のsizeが異常");
}

- (void)testArchive
{
    FontSize *fontSize1 = [[FontSize alloc] init];
    fontSize1.size = 10.0f;
    
    NSData *binary = [NSKeyedArchiver archivedDataWithRootObject:fontSize1];
    FontSize *archiveFontSize = [NSKeyedUnarchiver unarchiveObjectWithData:binary];
    
    STAssertEquals(fontSize1.size, archiveFontSize.size, @"archive後のfontSize1とarchiveFontSizeのsizeが異なる");
}

- (void)testMutableCopy
{
    FontSize *fontSize1 = [[FontSize alloc] init];
    fontSize1.size = 10.0f;
    
    FontSize *copyFontSize = [fontSize1 mutableCopy];
    
    STAssertEquals(fontSize1.size, copyFontSize.size, @"mutableCopy後のfontSize1とcopyFontSizeのsizeが異なる");
}

@end
