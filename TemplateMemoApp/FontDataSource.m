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
    systemFont.labelText = [systemFont.uiFont familyName];
    [self.dataList addObject:systemFont];

    // ヒラギノ角ゴ ProN W3
    Font *hiraginoKakuGothic = [[Font alloc] init];
    hiraginoKakuGothic.uiFont = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize.size];
    hiraginoKakuGothic.row = 1;
    hiraginoKakuGothic.name = [hiraginoKakuGothic.uiFont fontName];
    hiraginoKakuGothic.labelText = [hiraginoKakuGothic.uiFont familyName];
    [self.dataList addObject:hiraginoKakuGothic];
    
    // Helvetica NeueUI
    Font *helvetica = [[Font alloc] init];
    helvetica.uiFont = [UIFont fontWithName:@".HelveticaNeueUI" size:fontSize.size];
    helvetica.row = 2;
    helvetica.name = [helvetica.uiFont fontName];
    helvetica.labelText = [helvetica.uiFont familyName];
    [self.dataList addObject:helvetica];
    
/*
    NSEnumerator *familyNames = [[UIFont familyNames] objectEnumerator];
    NSString *familyName;
    int index = 0;
    while(familyName = [familyNames nextObject]) {
        for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
            Font *font = [[Font alloc] init];
            font.row = index;
            font.labelText = fontName;
            font.uiFont = [UIFont fontWithName:fontName size:fontSize.size];
            [self.dataList addObject:font];
            ++index;
        }
    }
*/
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
//    cell.detailTextLabel.font = ((Font *)self.dataList[indexPath.row]).uiFont;
//    cell.detailTextLabel.text = [((Font *)self.dataList[indexPath.row]).uiFont familyName];
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *identifer = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
//    }
//    [self updateCellData:tableView cellForRowAtIndexPath:indexPath tableViewCell:cell];
//    return cell;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return self.dataList.count;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}

@end