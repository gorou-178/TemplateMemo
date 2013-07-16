//
//  TMMemoTableViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMMemoTableViewController.h"
#import "TMEditViewController.h"
#import "TMAppContext.h"
#import "Common/TagLink.h"
#import "Common/MemoDao.h"
#import "AppDelegate.h"
#import "Memo.h"
#import "TagDao.h"
#import "Tag.h"

@interface TMMemoTableViewController ()
{
    id<MemoDao> memoDao;
    id<TagDao> tagDao;
    Tag *activeFilterTag;
}
- (void)updateCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@implementation TMMemoTableViewController

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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    
    self.title = @"memoView";
    
    activeFilterTag = nil;
    memoDao = [MemoDaoImpl new];
    tagDao = [TagDaoImpl new];
    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    
    // AppデリゲートのwindowからSplitViewを取得
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    UISplitViewController *splitViewController = (UISplitViewController*)[appDelegate.window rootViewController];
    // 左ペインのナビゲーションコントローラを取得
    // TODO: 右→左の順番でviewControllerが登録されているためlastObject？
    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
    // 左ペインのトップのビューコントローラを取得(今回の場合はTMEditViewController)
    self.tmEditViewController = (TMEditViewController*)navigationController.topViewController;
    self.tmEditViewController.memoTableViewController = self;
    
    [self.tmEditViewController setActiveSideView:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    // アクティブなViewとしてeditViewに通知
    [self.tmEditViewController setActiveSideView:self];
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
    memo.body = @"default memo";
    
    // DBに登録
    BOOL bResult = [memoDao add:memo];
    if (bResult) {
        // 最新のmemoidを取得
        int maxRefCount = [memoDao maxRefCount];
        memo.memoid = maxRefCount;
        
        // キャッシュの一番上に追加
        [_memoCache insertObject:memo atIndex:0];
        if (activeFilterTag) {
            // メモにタグを関連付けする
            [tagDao addTagLink:memo forLinkTag:activeFilterTag];
            _memoCache = [[memoDao tagMemos:activeFilterTag].memos mutableCopy];
        } else {
            _memoCache = [memoDao.memos mutableCopy];
        }
        
        // セルを一番上に追加
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

// タグのメモ一覧を表示
- (void)showTagMemo:(Tag *)tag
{
    // タグが指定されていない場合は全メモを取得
    if (tag == nil) {
        activeFilterTag = nil;
        self.navigationItem.title = @"すべてのメモ";
        _memoCache = [memoDao.memos mutableCopy];
    } else {
        activeFilterTag = tag;
        self.navigationItem.title = [[NSString alloc] initWithFormat:@"%@のメモ", tag.name];
        
        // 指定タグがついたメモの一覧を取得
        TagLink *tagLink = [memoDao tagMemos:tag];
        
        // タグのメモ一覧でキャッシュを更新
        _memoCache = [tagLink.memos mutableCopy];
    }
    
    // テーブル全体をリロード
    // TODO: 全体リロードの必要性(部分更新でも良い気がする)
    [self.tableView reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_memoCache == nil) {
        return 0;
    }
    return _memoCache.count;
}

- (void)updateCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    // 想定外のセクションは無視
    if (indexPath.section != 0) {
        return;
    }
    
    if (_memoCache == nil) {
        return;
    }
    
    Memo* memo = _memoCache[indexPath.row];
    if (memo == nil) {
        NSLog(@"ERROR: updateCell to memo is nil");
        return;
    }
    
    // TODO: セルを使いまわした場合問題になりそう
    if (cell.imageView.image == nil) {
        cell.imageView.image = [UIImage imageNamed:@"memo.png"];
    }
    
    // 改行までをタイトルとして設定
    NSMutableArray *lines = [NSMutableArray array];
    [memo.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [lines addObject:line];
//        *stop = YES;
    }];
    
    // タイトルは本文の一行目
    cell.textLabel.text = [lines objectAtIndex:0];
    
    // プレビュー内容を作成(2行目以降で作成)
    if (lines.count > 1) {
        NSMutableString *previewMemo = [NSMutableString new];
        for (int i = 1; i < lines.count; i++) {
            if ([previewMemo length] > 30) {
                break;
            }
            [previewMemo appendString:lines[i]];
        }
        cell.detailTextLabel.text = previewMemo.copy;
    } else {
        cell.detailTextLabel.text = @"(no preview)";
    }
    
}

// 画面上に見えているセルの表示更新
- (void)updateVisibleCells {
    
    // TODO: 更新のタイミングでキャッシュの更新がしたい
//    _memoCache = [memoDao.memos mutableCopy];
    
    for (UITableViewCell *cell in [self.tableView visibleCells]){
        [self updateCell:cell forTableView:self.tableView atIndexPath:[self.tableView indexPathForCell:cell]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    // セル情報の更新
    [self updateCell:cell forTableView:tableView atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BOOL bResult = [memoDao remove:self.memoCache[indexPath.row]];
        if (bResult) {
            [self.memoCache removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
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

- (void)viewWillAppear:(BOOL)animated
{
    // 選択ハイライトをフェードアウトさせる
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

// iPadの場合、セルの選択イベントで処理(iPhoneでもセグエイベント処理後にイベント発生するので注意)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.tmEditViewController setDetailItem:_memoCache[indexPath.row]];
    }
}

// iPhoneの場合、セル選択時のセグエイベントで処理
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showMemo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [[segue destinationViewController] setDetailItem:_memoCache[indexPath.row]];
    }
}
@end
