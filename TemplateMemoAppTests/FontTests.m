//
//  FontTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/11.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "FontTests.h"
#import "Font.h"
#import "FontSize.h"

@implementation FontTests

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
    FontSize *fontSize = [[FontSize alloc] init];
    fontSize.size = 10.0;
    
    // ヒラギノ角ゴ ProN W3
    Font *hiraginoKakuGothic = [[Font alloc] init];
    hiraginoKakuGothic.uiFont = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize.size];
    hiraginoKakuGothic.row = 1;
    hiraginoKakuGothic.name = [hiraginoKakuGothic.uiFont fontName];
    hiraginoKakuGothic.labelText = @"ヒラギノ角ゴ ProN W3";
    STAssertEqualObjects(hiraginoKakuGothic.uiFont, [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize.size], @"ヒラギノ角ゴ ProN W3 - UIFontが異なる");
    STAssertEquals([hiraginoKakuGothic.uiFont pointSize], fontSize.size, @"ヒラギノ角ゴ ProN W3 - UIFontのフォントサイズが指定値と異なる");
    STAssertEquals(hiraginoKakuGothic.row, 1, @"ヒラギノ角ゴ ProN W3 - rowの値が異なる");
    STAssertEqualObjects(hiraginoKakuGothic.name, [[UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize.size] fontName], @"ヒラギノ角ゴ ProN W3 - fontNameの値が異なる");
    STAssertEqualObjects(hiraginoKakuGothic.labelText, @"ヒラギノ角ゴ ProN W3", @"ヒラギノ角ゴ ProN W3 - labelTextの値が異なる");
    
    Font *bokutachinoGothic = [[Font alloc] init];
    bokutachinoGothic.uiFont = [UIFont fontWithName:@"BokutachinoGothic" size:fontSize.size];
    bokutachinoGothic.row = 2;
    bokutachinoGothic.name = [bokutachinoGothic.uiFont fontName];
    bokutachinoGothic.labelText = @"ぼくたちのゴシック";
    STAssertNotNil(bokutachinoGothic.uiFont, @"ぼくたちのゴシックがnil");
    
    Font *hannariMincho = [[Font alloc] init];
    hannariMincho.uiFont = [UIFont fontWithName:@"HannariMincho" size:fontSize.size];
    hannariMincho.row = 3;
    hannariMincho.name = [hannariMincho.uiFont fontName];
    hannariMincho.labelText = @"はんなり明朝";
    STAssertNotNil(hannariMincho.uiFont, @"はんなり明朝がnil");
    
    Font *huiFontP = [[Font alloc] init];
    huiFontP.uiFont = [UIFont fontWithName:@"HuiFontP" size:fontSize.size];
    huiFontP.row = 4;
    huiFontP.name = [huiFontP.uiFont fontName];
    huiFontP.labelText = @"ふい字Ｐ";
    STAssertNotNil(huiFontP.uiFont, @"ふい字Ｐがnil");

    // Times New Roman
    Font *timesNewRoma = [[Font alloc] init];
    timesNewRoma.uiFont = [UIFont fontWithName:@"TimesNewRomanPSMT" size:fontSize.size];
    timesNewRoma.row = 1;
    timesNewRoma.name = [timesNewRoma.uiFont fontName];
    timesNewRoma.labelText = [timesNewRoma.uiFont familyName];
    STAssertNotNil(timesNewRoma.uiFont, @"Times New Romanがnil");
    
    // Gill Sans
    Font *gillSans = [[Font alloc] init];
    gillSans.uiFont = [UIFont fontWithName:@"GillSans" size:fontSize.size];
    gillSans.row = 2;
    gillSans.name = [gillSans.uiFont fontName];
    gillSans.labelText = [gillSans.uiFont familyName];
    STAssertNotNil(gillSans.uiFont, @"Gill Sansがnil");
    
    // Chalkboard SE Light
    Font *chalkboard = [[Font alloc] init];
    chalkboard.uiFont = [UIFont fontWithName:@"ChalkboardSE-Light" size:fontSize.size];
    chalkboard.row = 3;
    chalkboard.name = [chalkboard.uiFont fontName];
    chalkboard.labelText = [chalkboard.uiFont familyName];
    STAssertNotNil(chalkboard.uiFont, @"Chalkboard SE Lightがnil");
    
    // Avenir-Book
    Font *avenir = [[Font alloc] init];
    avenir.uiFont = [UIFont fontWithName:@"Avenir-Book" size:fontSize.size];
    avenir.row = 4;
    avenir.name = [avenir.uiFont fontName];
    avenir.labelText = [avenir.uiFont familyName];
    STAssertNotNil(avenir.uiFont, @"Avenir-Bookがnil");
    
}

@end
