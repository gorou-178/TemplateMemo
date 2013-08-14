//
//  TMTagSettingTableViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/31.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "AppDelegate.h"
#import "TMTagSettingTableViewController.h"
#import "TMEditMemoViewController.h"
#import "TagDao.h"
#import "Memo.h"

@interface TMTagSettingTableViewController ()
{
    NSMutableArray *tagData;
    id<TagDao> tagDao;
    Memo *currentMemo;
}

@end

@implementation TMTagSettingTableViewController

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
    DDLogInfo(@"タグ設定表示");
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setActiveMemo:(TMEditMemoViewController *)editMemoView
{
    currentMemo = [editMemoView currentMemo];
    NSMutableArray *tags = [[tagDao tags] mutableCopy];
    NSMutableArray *selectedList = [[tagDao tagForMemo:currentMemo] mutableCopy];
    
    tagData = [[NSMutableArray alloc] init];
    [tagData addObject:selectedList];
    [tagData addObject:tags];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return tagData.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"メモのタグ";
    }
    return  @"タグ一覧\n以下タグ一覧からタグを選択してください";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 二行でヘッダ文章を表示するため
    if (section == 1) {
        UITableViewHeaderFooterView *view = (UITableViewHeaderFooterView *)[super tableView:tableView viewForHeaderInSection:section];
        view.textLabel.numberOfLines = 2;
        return view;
    }
    return [super tableView:tableView viewForHeaderInSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((NSArray*)tagData[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // セクションデータを取得
    NSMutableArray *selectedTags = tagData[0];
    NSMutableArray *tags = tagData[1];
    
    // 選択中タグは常にチェックマーク
    if (indexPath.section == 0) {
        cell.textLabel.text = ((Tag *)selectedTags[indexPath.row]).name;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        Tag *currentTag = tags[indexPath.row];
        cell.textLabel.text = currentTag.name;
        for (Tag *selectedTag in selectedTags) {
            if ([selectedTag.name isEqual:currentTag.name]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *selectedTags = tagData[0];
    NSMutableArray *tags = tagData[1];
    BOOL isUpdateTable = NO;
    
    if (indexPath.section == 1) {
        // 選択したセルにチェックをつける
        for (int i = 0; i < [tableView numberOfRowsInSection:1]; i++) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
            if (indexPath.row == i) {
                // トグル
                if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    
                    // タグリンクを削除
                    Tag *tag = tags[indexPath.row];
                    if ([tagDao removeTagLink:currentMemo forLinkTag:tag]) {
                        // 選択中のタグセルから対象のタグセルを削除
                        for (int j = 0; j < selectedTags.count; j++) {
                            Tag *selectedTag = selectedTags[j];
                            if ([selectedTag.name isEqualToString:tag.name]) {
                                DDLogInfo(@"タグ設定表示: タグ削除 >> %@", selectedTag.name);
                                [selectedTags removeObjectAtIndex:j];
                                NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:j inSection:0];
                                [self.tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                isUpdateTable = YES;
                                break;
                            }
                        }
                    }
                } else {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    
                    // タグリンクを作成
                    Tag *tag = tags[indexPath.row];
                    if ([tagDao addTagLink:currentMemo forLinkTag:tag]) {
                        [selectedTags insertObject:tag atIndex:0];
                        // セルを一番上に追加
                        NSIndexPath *insertIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        [self.tableView insertRowsAtIndexPaths:@[insertIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                        isUpdateTable = YES;
                        DDLogInfo(@"タグ設定表示: タグ追加 >> %@", tag.name);
                    }
                }
                
                break;
            }
        }
    } else {
        // タグリンクを削除
        Tag *selectedTag = selectedTags[indexPath.row];
        if ([tagDao removeTagLink:currentMemo forLinkTag:selectedTag]) {
            
            DDLogInfo(@"タグ設定表示: タグ削除 >> %@", selectedTag.name);
            [selectedTags removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            isUpdateTable = YES;
            
            // 選択中のタグセルから対象のタグセルを削除
            for (int i = 0; i < tags.count; i++) {
                Tag *tag = tags[i];
                if ([tag.name isEqualToString:selectedTag.name]) {
                    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
                    UITableViewCell *tagCell = [self.tableView cellForRowAtIndexPath:selectIndexPath];
                    tagCell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                }
            }
        }
    }
    
    // タグビューを更新
    if (isUpdateTable) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [[appDelegate.tagTableViewController tableView] reloadData];
        [[appDelegate.memoTableViewController tableView] reloadData];
    }
    
    // 選択ハイライトをフェードアウトさせる
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

@end
