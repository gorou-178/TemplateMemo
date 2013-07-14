//
//  MasterViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/06/02.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "MasterViewController.h"
#import "TMEditViewController.h"
#import "Common/MemoDao.h"

@interface MasterViewController () {
    
}
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // navigationBar UI作成
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    
//    // searchBar設定
//    self.memoSearchBar.showsCancelButton = YES;
    
    // splitViewの右側コントローラクラス取得
    self.tmEditViewController = (TMEditViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    // DAO作成
    self.memoDao = [MemoDaoImpl new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// メモの新規作成
- (void)insertNewObject:(id)sender
{
    // メモを仮登録
    // TODO: 何も入力せずに別のメモを選択 または 画面を戻った場合に、新規追加をなかったことにしたい
    Memo* memo = [[Memo alloc] init];
//    memo.title = @"default title";
    memo.body = @"default memo";
    [self.memoDao add:memo];
    
    // セルを一番上に追加
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.memoDao.memos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSArray *memos = self.memoDao.memos;
    Memo* memo = memos[indexPath.row];
    if (memo == nil) {
        return cell;
    }
    
    // 改行までをタイトルとして設定
    NSMutableArray *lines = [NSMutableArray array];
    [memo.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [lines addObject:line];
        *stop = YES;
    }];
    cell.textLabel.text = [lines objectAtIndex:0];
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
        
        //[_objects removeObjectAtIndex:indexPath.row];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSArray* memos = self.memoDao.memos;
        if (indexPath.row < memos.count) {
            Memo* memo = memos[indexPath.row];
            self.tmEditViewController.detailItem = memo;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSArray* memos = self.memoDao.memos;
        if (indexPath.row < memos.count) {
            Memo* memo = memos[indexPath.row];
            [[segue destinationViewController] setDetailItem:memo];
        }
    }
}

@end
