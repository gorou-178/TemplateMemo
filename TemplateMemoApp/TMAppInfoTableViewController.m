//
//  TMAppInfoTableViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/04.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMAppInfoTableViewController.h"
#import "UIDevice-Hardware.h"

@interface TMAppInfoTableViewController ()

@end

@implementation TMAppInfoTableViewController

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
    DDLogInfo(@"アプリケーション情報表示");
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            // アプリのバージョン情報を設定
            cell.detailTextLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [[UIDevice currentDevice] platformString];
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion]];
        } else if (indexPath.row == 2) {
            cell.detailTextLabel.text = [[UIDevice currentDevice] model];
        }
    }
    return cell;
}

@end
