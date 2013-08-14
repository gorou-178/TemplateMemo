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
#import "TemplateMemo.h"
#import "TagDao.h"
#import "MemoDao.h"
#import "DateUtil.h"

@interface TMMemoInfoTableViewController ()
{
    Memo *currentMemo;
    TemplateMemo *currentTemplateMemo;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"メモ情報表示");
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setActiveMemo:(TMEditMemoViewController *)editViewController
{
    if (editViewController.editTarget == TMEditTargetMemo) {
        currentMemo = [editViewController currentMemo];
        currentTemplateMemo = nil;
    } else if (editViewController.editTarget == TMEditTargetTemplate) {
        currentMemo = nil;
        currentTemplateMemo = [editViewController currentTemplateMemo];
    }
}

- (void)updateCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        NSString *body;
        if (currentMemo) {
            body = [currentMemo.body mutableCopy];
        } else if (currentTemplateMemo) {
            body = [currentTemplateMemo.name mutableCopy];
        }
        
        if (indexPath.row == 0) {
            
            // 改行までをタイトルとして設定
            NSMutableArray *lines = [NSMutableArray array];
            [body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                [lines addObject:line];
                *stop = YES;
            }];
            
            if (lines.count <= 0) {
                cell.detailTextLabel.text = @"(no title)";
                return;
            }
            
            // タイトルは本文の一行目
            cell.detailTextLabel.text = [lines objectAtIndex:0];
            
        } else if (indexPath.row == 1) {
            if (currentMemo) {
                NSMutableString *tagText = [[NSMutableString alloc] init];
                NSArray *tags = [tagDao tagForMemo:currentMemo];
                for (int i = 0; i < tags.count; i++) {
                    if (i != 0) {
                        [tagText appendString:@" "];
                    }
                    [tagText appendString:((Tag*)tags[i]).name];
                }
                
                if (tagText.length > 0) {
                    cell.detailTextLabel.text = tagText;
                } else {
                    cell.detailTextLabel.text = @"なし";
                }
                
            } else if (currentTemplateMemo) {
                cell.detailTextLabel.text = @"なし";
            }
        } else if (indexPath.row == 2) {
            cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", [body length]];
        }
    } else {
        
        NSDate *createDate;
        NSDate *modifiedDate;
        if (currentMemo) {
            createDate = currentMemo.createDate;
            modifiedDate = currentMemo.modifiedDate;
        } else if (currentTemplateMemo) {
            createDate = currentTemplateMemo.createDate;
            modifiedDate = currentTemplateMemo.modifiedDate;
        }
        
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = [DateUtil dateToString:createDate atDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        } else if (indexPath.row == 1) {
            cell.detailTextLabel.text = [DateUtil dateToString:modifiedDate atDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [self updateCell:cell forTableView:tableView atIndexPath:indexPath];
    return cell;
}

@end
