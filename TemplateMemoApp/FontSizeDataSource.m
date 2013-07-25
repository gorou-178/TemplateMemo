//
//  FontSizeDataSource.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "FontSizeDataSource.h"
#import "FontSize.h"
#import "FontSizeSettingInfo.h"
#import "Font.h"
#import "FontSettingInfo.h"
#import "SettingInfo.h"
#import "UserDefaultsWrapper.h"

@implementation FontSizeDataSource

- (id)init
{
    self = [super init];
    
    NSLog(@"FontSizeDataSource: init");
    self.dataList = [[NSMutableArray alloc] init];
    
    FontSize *fontSize = [[FontSize alloc] init];
    fontSize.row = 0;
    fontSize.labelText = @"最小";
    fontSize.size = 14;
    [self.dataList addObject:fontSize];
    
    fontSize = [[FontSize alloc] init];
    fontSize.row = 1;
    fontSize.labelText = @"小";
    fontSize.size = 18;
    [self.dataList addObject:fontSize];
    
    fontSize = [[FontSize alloc] init];
    fontSize.row = 2;
    fontSize.labelText = @"中";
    fontSize.size = 24;
    [self.dataList addObject:fontSize];
    
    fontSize = [[FontSize alloc] init];
    fontSize.row = 3;
    fontSize.labelText = @"大";
    fontSize.size = 36;
    [self.dataList addObject:fontSize];
    
    fontSize = [[FontSize alloc] init];
    fontSize.row = 4;
    fontSize.labelText = @"最大";
    fontSize.size = 48;
    [self.dataList addObject:fontSize];
    
    return self;
}

- (void)updateCellData:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath tableViewCell:(UITableViewCell *)cell
{
    FontSizeSettingInfo *fontSizeSettingInfo = [[FontSizeSettingInfo alloc] init];
    FontSize *fontSize = [UserDefaultsWrapper loadToObject:fontSizeSettingInfo.key];
    
//    FontSettingInfo *fontSettingInfo = [[FontSettingInfo alloc] init];
//    Font *font = [UserDefaultsWrapper loadToObject:fontSettingInfo.key];
    
    // 現在の設定のセルにチェックをつける
    if (indexPath.row == fontSize.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = ((FontSize *)self.dataList[indexPath.row]).labelText;
//    cell.detailTextLabel.font = [UIFont fontWithName:font.uiFont.fontName size:((FontSize *)self.dataList[indexPath.row]).size];
//    cell.detailTextLabel.text = @"この大きさで表示されます";
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
