//
//  TMTagTableViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMTagTableViewController.h"
#import "TMMemoTableViewController.h"
#import "Common/Tag.h"
#import "Common/TagDao.h"

@interface TMTagTableViewController ()
{
    id<TagDao> tagDao;
    NSMutableArray *tagCache;
}

@end

@implementation TMTagTableViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    
    // タグ一覧を取得
    tagDao = [TagDaoImpl new];
    tagCache = [tagDao.tags mutableCopy];
    
    [super awakeFromNib];
}

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
    
    // 編集ボタン
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // タイトル
    self.navigationItem.title = @"タグ";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tagCache.count + 1;
}

- (void)updateCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    // 想定外のセクションは無視
    if (indexPath.section != 0) {
        return;
    }
    
    if (indexPath.row == 0) {
        // 一番最初は「All Memo」
        cell.textLabel.text = @"All Memo";
        // TODO: セルを使いまわした場合問題になりそう
        if (cell.imageView.image == nil) {
            cell.imageView.image = [UIImage imageNamed:@"home.png"];
        }
    } else {
        Tag *tag = tagCache[indexPath.row - 1];
        cell.textLabel.text = tag.name;
        // TODO: セルを使いまわした場合問題になりそう
        if (cell.imageView.image == nil) {
            cell.imageView.image = [UIImage imageNamed:@"tag.png"];
        }
    }
}

// 画面上に見えているセルの表示更新
- (void)updateVisibleCells {
    for (UITableViewCell *cell in [self.tableView visibleCells]){
        [self updateCell:cell forTableView:self.tableView atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self updateCell:cell forTableView:tableView atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (indexPath.row == 0) {
            NSLog(@"All Memo not Delete");
            return;
        }
        
        // タグを削除
        // TODO: タグリンクも削除する必要がある
        BOOL bResult = [tagDao remove:tagCache[indexPath.row - 1]];
        if (bResult) {
            [tagCache removeObjectAtIndex:indexPath.row - 1];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    // 選択ハイライトをフェードアウトさせる
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTagMemo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TMMemoTableViewController *memoTableViewController = [segue destinationViewController];
        // 「All Memo」の場合
        if (indexPath.row == 0) {
            [memoTableViewController showTagMemo:nil];
        } else {
            [memoTableViewController showTagMemo:tagCache[indexPath.row - 1]];
        }
    
    }
}

@end
