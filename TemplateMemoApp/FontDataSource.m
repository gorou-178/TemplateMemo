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
    systemFont.labelText = [systemFont.uiFont fontName];
    [self.dataList addObject:systemFont];

    // ヒラギノ角ゴ ProN W3
    Font *hiraginoKakuGothic = [[Font alloc] init];
    hiraginoKakuGothic.uiFont = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize.size];
    hiraginoKakuGothic.row = 1;
    hiraginoKakuGothic.name = [hiraginoKakuGothic.uiFont fontName];
    hiraginoKakuGothic.labelText = [hiraginoKakuGothic.uiFont fontName];
    [self.dataList addObject:hiraginoKakuGothic];
    
    // Helvetica NeueUI
    Font *helvetica = [[Font alloc] init];
    helvetica.uiFont = [UIFont fontWithName:@".HelveticaNeueUI" size:fontSize.size];
    helvetica.row = 2;
    helvetica.name = [helvetica.uiFont fontName];
    helvetica.labelText = [helvetica.uiFont fontName];
    [self.dataList addObject:helvetica];
    
    Font *bokutachinoGothic = [[Font alloc] init];
    bokutachinoGothic.uiFont = [UIFont fontWithName:@"BokutachinoGothic" size:fontSize.size];
    bokutachinoGothic.row = 3;
    bokutachinoGothic.name = [bokutachinoGothic.uiFont fontName];
    bokutachinoGothic.labelText = [bokutachinoGothic.uiFont fontName];
    [self.dataList addObject:bokutachinoGothic];
    
    Font *hannariMincho = [[Font alloc] init];
    hannariMincho.uiFont = [UIFont fontWithName:@"HannariMincho" size:fontSize.size];
    hannariMincho.row = 4;
    hannariMincho.name = [hannariMincho.uiFont fontName];
    hannariMincho.labelText = [hannariMincho.uiFont fontName];
    [self.dataList addObject:hannariMincho];
    
    Font *huiFontP = [[Font alloc] init];
    huiFontP.uiFont = [UIFont fontWithName:@"HuiFontP" size:fontSize.size];
    huiFontP.row = 5;
    huiFontP.name = [huiFontP.uiFont fontName];
    huiFontP.labelText = [huiFontP.uiFont fontName];
    [self.dataList addObject:huiFontP];

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
