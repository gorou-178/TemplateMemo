//
//  StackAdditionsTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/09.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "StackAdditionsTests.h"
#import "NSMutableArray+StackAdditions.h"

@interface StackAdditionsTests ()
{
    NSMutableArray *stack;
}
@end

@implementation StackAdditionsTests

#pragma mark - Clean up Method

- (void)setUp
{
    [super setUp];
    
    stack = [[NSMutableArray alloc] init];
    [stack push:@"111"];
    [stack push:@"222"];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testPush
{
    [stack push:@"333"];
    
    STAssertEqualObjects([stack pop], @"333", @"push firstエラー");
    STAssertEqualObjects([stack pop], @"222", @"push secondエラー");
    STAssertEqualObjects([stack pop], @"111", @"push theerdエラー");
}

- (void)testPop
{
    [stack pop];
    STAssertEqualObjects([stack pop], @"111", @"popエラー");
}

@end
