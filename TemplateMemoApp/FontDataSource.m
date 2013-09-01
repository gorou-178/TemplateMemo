//
//  FontDataSource.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "FontDataSource.h"
#import "Font.h"
#import "FontSettingInfo.h"
#import "FontSize.h"
#import "FontSizeSettingInfo.h"
#import "UserDefaultsWrapper.h"
#import "UIDeviceHelper.h"

@implementation FontDataSource

- (id)init
{
    self = [super init];
    
    NSLog(@"FontDataSource: init");
    self.dataList = [[NSMutableArray alloc] init];
    
    FontSizeSettingInfo *fontSizeSettingInfo = [[FontSizeSettingInfo alloc] init];
    FontSize *fontSize = [UserDefaultsWrapper loadToObject:fontSizeSettingInfo.key];

    // システムフォント(Helvetica)
    Font *systemFont = [[Font alloc] init];
    systemFont.uiFont = [UIFont systemFontOfSize:fontSize.size];
    systemFont.row = 0;
    systemFont.name = [systemFont.uiFont fontName];
    systemFont.labelText = [systemFont.uiFont familyName];
    [self.dataList addObject:systemFont];
    
    if ([UIDeviceHelper isJapaneseLanguage]) {
        // ヒラギノ角ゴ ProN W3
        Font *hiraginoKakuGothic = [[Font alloc] init];
        hiraginoKakuGothic.uiFont = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize.size];
        hiraginoKakuGothic.row = 1;
        hiraginoKakuGothic.name = [hiraginoKakuGothic.uiFont fontName];
        //    hiraginoKakuGothic.labelText = [hiraginoKakuGothic.uiFont familyName];
        hiraginoKakuGothic.labelText = @"ヒラギノ角ゴ ProN W3";
        [self.dataList addObject:hiraginoKakuGothic];
        
        Font *bokutachinoGothic = [[Font alloc] init];
        bokutachinoGothic.uiFont = [UIFont fontWithName:@"BokutachinoGothic" size:fontSize.size];
        bokutachinoGothic.row = 2;
        bokutachinoGothic.name = [bokutachinoGothic.uiFont fontName];
        //    bokutachinoGothic.labelText = [bokutachinoGothic.uiFont familyName];
        bokutachinoGothic.labelText = @"ぼくたちのゴシック";
        [self.dataList addObject:bokutachinoGothic];
        
        Font *hannariMincho = [[Font alloc] init];
        hannariMincho.uiFont = [UIFont fontWithName:@"HannariMincho" size:fontSize.size];
        hannariMincho.row = 3;
        hannariMincho.name = [hannariMincho.uiFont fontName];
        //    hannariMincho.labelText = [hannariMincho.uiFont familyName];
        hannariMincho.labelText = @"はんなり明朝";
        [self.dataList addObject:hannariMincho];
        
        Font *huiFontP = [[Font alloc] init];
        huiFontP.uiFont = [UIFont fontWithName:@"HuiFontP" size:fontSize.size];
        huiFontP.row = 4;
        huiFontP.name = [huiFontP.uiFont fontName];
        //    huiFontP.labelText = [huiFontP.uiFont familyName];
        huiFontP.labelText = @"ふい字Ｐ";
        [self.dataList addObject:huiFontP];
    }
    else {
        // Times New Roman
        Font *timesNewRoma = [[Font alloc] init];
        timesNewRoma.uiFont = [UIFont fontWithName:@"TimesNewRomanPSMT" size:fontSize.size];
        timesNewRoma.row = 1;
        timesNewRoma.name = [timesNewRoma.uiFont fontName];
        timesNewRoma.labelText = [timesNewRoma.uiFont familyName];
        [self.dataList addObject:timesNewRoma];
        
        // Gill Sans
        Font *gillSans = [[Font alloc] init];
        gillSans.uiFont = [UIFont fontWithName:@"GillSans" size:fontSize.size];
        gillSans.row = 2;
        gillSans.name = [gillSans.uiFont fontName];
        gillSans.labelText = [gillSans.uiFont familyName];
        [self.dataList addObject:gillSans];
        
        // Chalkboard SE Light
        Font *chalkboard = [[Font alloc] init];
        chalkboard.uiFont = [UIFont fontWithName:@"ChalkboardSE-Light" size:fontSize.size];
        chalkboard.row = 3;
        chalkboard.name = [chalkboard.uiFont fontName];
        chalkboard.labelText = [chalkboard.uiFont familyName];
        [self.dataList addObject:chalkboard];
        
        // Avenir-Book
        Font *avenir = [[Font alloc] init];
        avenir.uiFont = [UIFont fontWithName:@"Avenir-Book" size:fontSize.size];
        avenir.row = 4;
        avenir.name = [avenir.uiFont fontName];
        avenir.labelText = [avenir.uiFont familyName];
        [self.dataList addObject:avenir];
    }

    return self;
}

- (void)updateCellData:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath tableViewCell:(UITableViewCell *)cell
{
    FontSettingInfo *fontSettingInfo = [[FontSettingInfo alloc] init];
    Font *font = [UserDefaultsWrapper loadToObject:fontSettingInfo.key];
    
    // 現在の設定のセルにチェックをつける
    if (indexPath.row == font.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = ((Font *)self.dataList[indexPath.row]).labelText;
}

@end
