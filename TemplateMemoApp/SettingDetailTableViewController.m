//
//  SettingDetailTableViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "SettingDetailTableViewController.h"
#import "SettingInfo.h"

@interface SettingDetailTableViewController ()

@end

@implementation SettingDetailTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"詳細設定表示: 設定 >> %@", settingInfo_.detailTitle);
    [super viewWillAppear:animated];
    self.navigationItem.title = settingInfo_.detailTitle;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateCellData:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath tableViewCell:(UITableViewCell *)cell
{
    SettingData *settingData = (SettingData *)dataList_[indexPath.row];
    cell.textLabel.text = settingData.labelText;
    if (indexPath.row == settingData.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self updateCellData:tableView cellForRowAtIndexPath:indexPath tableViewCell:cell];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選択したセルにチェックをつける
    for (int i = 0; i < [tableView numberOfRowsInSection:0]; i++) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == i) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            // データリストから選択したデータを取得して設定情報にセット
            settingInfo_.settingData = [dataList_[indexPath.row] mutableCopy];
            // 設定を更新
            id<SettingUpdater> updater = (id<SettingUpdater>)self.tableView.dataSource;
            [updater update:settingInfo_];
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    // 前画面に戻る
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setSettingInfo:(SettingInfo *)settingInfo withDataList:(NSArray *)dataList
{
    settingInfo_ = settingInfo;
    self.tableView.dataSource = (id<UITableViewDataSource>)settingInfo_.dataSource;
    dataList_ = [dataList mutableCopy];
}

@end
