//
//  TMMemoInfoTableViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/01.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMMemoInfoTableViewController.h"
#import "TMEditMemoViewController.h"
#import "Tag.h"
#import "Memo.h"
#import "TagDao.h"
#import "MemoDao.h"
#import "DateUtil.h"

@interface TMMemoInfoTableViewController ()
{
    Memo *currentMemo;
    id<TagDao> tagDao;
}
@end

@implementation TMMemoInfoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    tagDao = [[TagDaoImpl alloc] init];
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

- (void)setActiveMemo:(TMEditMemoViewController *)editViewController
{
    // TODO: テンプレート編集時の対応
    currentMemo = [editViewController currentMemo];
}

- (void)updateCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            // 改行までをタイトルとして設定
            NSMutableArray *lines = [NSMutableArray array];
            [currentMemo.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                [lines addObject:line];
                *stop = YES;
            }];
            
            // タイトルは本文の一行目
            cell.detailTextLabel.text = [lines objectAtIndex:0];
            
        } else if (indexPath.row == 1) {
            NSMutableString *tagText = [[NSMutableString alloc] init];
            NSArray *tags = [tagDao tagForMemo:currentMemo];
            for (int i = 0; i < tags.count; i++) {
                if (i != 0) {
                    [tagText appendString:@" "];
                }
                [tagText appendString:((Tag*)tags[i]).name];
            }
            cell.detailTextLabel.text = tagText;
        }
    } else {
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [DateUtil dateToString:currentMemo.createDate atDateFormat:@"yyyy/MM/dd hh:mm:ss"];
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = [DateUtil dateToString:currentMemo.modifiedDate atDateFormat:@"yyyy/MM/dd hh:mm:ss"];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [self updateCell:cell forTableView:tableView atIndexPath:indexPath];
    return cell;
}

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

@end
