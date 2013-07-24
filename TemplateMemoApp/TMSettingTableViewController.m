//
//  TMSettingTableViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMSettingTableViewController.h"
#import "SettingInfo.h"
#import "Font.h"
#import "FontSize.h"
#import "FontDataSource.h"
#import "FontSizeDataSource.h"
#import "FontSettingInfo.h"
#import "FontSizeSettingInfo.h"
#import "SettingDetailTableViewController.h"
#import "UserDefaultsWrapper.h"

@interface TMSettingTableViewController ()

@end

@implementation TMSettingTableViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (void)updateCellData:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath tableViewCell:(UITableViewCell *)cell
{
    SettingInfo *settingInfo;
    if (indexPath.section == 0) {
        // switch文のcase内で変数宣言する場合、{}で括る必要がある
        // 「Switch case is in protected scope」というコンパイルエラーが発生する
        switch (indexPath.row) {
            case 0:
            {
                settingInfo = [[FontSettingInfo alloc] init];
                Font *font = [UserDefaultsWrapper loadToObject:settingInfo.key];
                cell.detailTextLabel.text = font.labelText;
                break;
            }
            case 1:
            {
                settingInfo = [[FontSizeSettingInfo alloc] init];
                FontSize *fontSize = [UserDefaultsWrapper loadToObject:settingInfo.key];
                cell.detailTextLabel.text = fontSize.labelText;
                break;
            }
            default:
                break;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [self updateCellData:tableView cellForRowAtIndexPath:indexPath tableViewCell:cell];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SettingDetailTableViewController *viewController = (SettingDetailTableViewController *)[segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"settingFont"]) {
        SettingInfo *settingInfo = [[FontSettingInfo alloc] init];
        settingInfo.dataSource = [[FontDataSource alloc] init];
        [viewController setSettingInfo:settingInfo withDataList:settingInfo.dataSource.dataList];
    } else if ([[segue identifier] isEqualToString:@"settingFontSize"]) {
        SettingInfo *settingInfo = [[FontSizeSettingInfo alloc] init];
        settingInfo.dataSource = [[FontSizeDataSource alloc] init];
        [viewController setSettingInfo:settingInfo withDataList:settingInfo.dataSource.dataList];
    }
}

@end
