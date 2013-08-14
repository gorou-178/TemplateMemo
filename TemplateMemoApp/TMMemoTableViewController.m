//
//  TMMemoTableViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "AppDelegate.h"
#import "TMMemoTableViewController.h"
#import "MemoDao.h"
#import "TagDao.h"

#import "TemplateMemo.h"
#import "TemplateMemoSettingInfo.h"

#import "UserDefaultsWrapper.h"

#define DISP_AD_BOTTOM

@interface TMMemoTableViewController ()
{
    NSMutableArray *memoCache;
    id<MemoDao> memoDao;
    id<TagDao> tagDao;
    Tag *activeFilterTag;
    NSMutableArray *filterdMemoArray;
}
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
    NSLog(@"memo: awakeFromNib");
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    
    activeFilterTag = nil;
    memoDao = [MemoDaoImpl new];
    tagDao = [TagDaoImpl new];
    filterdMemoArray = [[NSMutableArray alloc] init];
    
    fastViewFlag = YES;
	bannerIsVisible = NO;
    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    NSLog(@"memo: viewDidLoad");
    [super viewDidLoad];
    
    // AppデリゲートのwindowからSplitViewを取得
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.memoTableViewController = self;
    
    self.memoSearchBar.delegate = self;
    self.memoSearchBarController.delegate = self;
    
    CGRect insetSize;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        adView = [[ADBannerView alloc] init];
        insetSize = adView.bounds;
        adView.delegate = self;
        adView.autoresizesSubviews = YES;
        adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        adView.alpha = 0.0;
        [self.view addSubview:adView];
    } else {
        insetSize = CGRectMake(0, 0, 0, 50);
    }
    
    // UITableView のコンテンツに余白を付ける（下50px）
    self.tableView.contentInset = UIEdgeInsetsMake(0.f, 0.f, insetSize.size.height, 0.f);
    // UITableView のスクロール可能範囲に余白を付ける（下50px）
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.f, 0.f, insetSize.size.height, 0.f);
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"メモ一覧表示");
    [super viewWillAppear:animated];
    
    // 検索バーを隠す
    [self.tableView setContentOffset:CGPointMake(0.0f, self.searchDisplayController.searchBar.frame.size.height)];
    
    // 選択ハイライトをフェードアウトさせる
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    [self changeRotateForm];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // アクティブなViewとしてeditViewに通知
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.editMemoViewController setActiveSideView:self];
    
    // iPadにてアプリ起動時にランドスケープの場合、ボタン表示位置が左寄りになるのを防ぐために必要
    if(fastViewFlag == YES){
        fastViewFlag = NO;
        [self changeRotateForm];
    }
}

- (void)didReceiveMemoryWarning
{
    DDLogInfo(@"メモ一覧表示: メモリ警告");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// iPhoneの場合、セグエで画面遷移を行う前に、セルの追加・セル選択処理を行う
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"insertMemo"]) {
        if ([self insertNewObject]) {
            // セルを一番上に追加
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // 意図的に選択
            // didSelectRowAtIndexPathを実行しないのは、editMemoViewが初期化される前に実行されるため、
            // 次画面ロード後であるprepareForSegueで実施するようにした。
            TMEditMemoViewController *editMemoView = (TMEditMemoViewController *)[segue destinationViewController];
            [editMemoView setDetailItem:memoCache[indexPath.row]];
            
            // トップにスクロールさせる
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        }
    }
}

// iPadの場合、セルを追加し、セル選択時処理を実行する
- (IBAction)onPushAddButton:(id)sender {
    if ([self insertNewObject]) {
        // セルを一番上に追加
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // 意図的に選択
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        
        // トップにスクロールさせる
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    }
}

// メモの新規作成
- (BOOL)insertNewObject
{
    // テンプレートを取得
    // TODO: テンプレート内に置換予約後を入れたい
    TemplateMemoSettingInfo *templateMemoSettingInfo = [[TemplateMemoSettingInfo alloc] init];
    TemplateMemo *templateMemo = [UserDefaultsWrapper loadToObject:templateMemoSettingInfo.key];
    
    // TODO: 何も入力せずに別のメモを選択 または 画面を戻った場合に、新規追加をなかったことにしたい
    Memo* memo = [[Memo alloc] init];
    if (templateMemo) {
        if (templateMemo.body) {
            memo.body = [templateMemo.body mutableCopy];
        } else {
            memo.body = @"";
        }
    } else {
        DDLogInfo(@"メモ一覧表示: メモ追加");
        memo.body = @"";
    }
    
    // DBに登録
    BOOL bResult = [memoDao add:memo];
    if (bResult) {
        if (activeFilterTag) {
            // メモにタグを関連付けする
            [tagDao addTagLink:memo forLinkTag:activeFilterTag];
            memoCache = [[memoDao tagMemos:activeFilterTag].memos mutableCopy];
            if (templateMemo) {
                DDLogInfo(@"メモ一覧表示: メモ追加(テンプレート使用:%@, タグ:%@)", templateMemo.name, activeFilterTag.name);
            } else {
                DDLogInfo(@"メモ一覧表示: メモ追加(タグ:%@)", activeFilterTag.name);
            }
        } else {
            memoCache = [memoDao.memos mutableCopy];
            if (templateMemo) {
                DDLogInfo(@"メモ一覧表示: メモ追加(テンプレート使用:%@)", templateMemo.name);
            } else {
                DDLogInfo(@"メモ一覧表示: メモ追加");
            }
        }
    }
    
    return bResult;
}

// タグのメモ一覧を表示
- (void)showTagMemo:(Tag *)tag
{
    // タグが指定されていない場合は全メモを取得
    if (tag == nil) {
        DDLogInfo(@"メモ一覧表示: すべてのメモ");
        activeFilterTag = nil;
        self.navigationItem.title = @"すべてのメモ";
        memoCache = [memoDao.memos mutableCopy];
    } else {
        DDLogInfo(@"メモ一覧表示: %@のメモ", tag.name);
        activeFilterTag = tag;
        self.navigationItem.title = [[NSString alloc] initWithFormat:@"%@のメモ", tag.name];
        
        // 指定タグがついたメモの一覧を取得
        TagLink *tagLink = [memoDao tagMemos:tag];
        
        // タグのメモ一覧でキャッシュを更新
        memoCache = [tagLink.memos mutableCopy];
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
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return filterdMemoArray.count;
    } else {
        if (memoCache == nil) {
            return 0;
        }
        return memoCache.count;
    }
}

// 画面上に見えているセルの表示更新
- (void)updateVisibleCells {
    if (activeFilterTag) {
        memoCache = [[memoDao tagMemos:activeFilterTag].memos mutableCopy];
    } else {
        memoCache = [memoDao.memos mutableCopy];
    }
    [self.tableView reloadData];
}

// セルの内容を設定する
- (void)setCellInfo:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath atCell:(UITableViewCell *)cell forMemo:(Memo *)memo
{
    cell.imageView.image = [UIImage imageNamed:@"document_text_32.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // 改行までをタイトルとして設定
    NSMutableArray *lines = [NSMutableArray array];
    [memo.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [lines addObject:line];
    }];
    
    // 内容が空の場合
    if (lines.count <= 0) {
        cell.textLabel.text = @"(no title)";
        cell.detailTextLabel.text = @"(no preview)";
        return;
    }
    
    // タイトルは本文の一行目
    cell.textLabel.text = [lines objectAtIndex:0];
    if ([cell.textLabel.text length] <= 0) {
        cell.textLabel.text = @"(no title)";
    }
    
    // プレビュー内容を作成(2行目以降で作成)
    if (lines.count > 1) {
        NSMutableString *previewMemo = [NSMutableString new];
        for (int i = 1; i < lines.count; i++) {
            if ([previewMemo length] > 30) {
                break;
            }
            [previewMemo appendString:lines[i]];
        }
        if ([previewMemo length] <= 0) {
            cell.detailTextLabel.text = @"(no preview)";
        } else {
            cell.detailTextLabel.text = previewMemo.copy;
        }
    } else {
        cell.detailTextLabel.text = @"(no preview)";
    }
}

// 検索時のtableViewの更新処理
- (UITableViewCell *)updateFilterdTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    [self setCellInfo:tableView cellForRowAtIndexPath:indexPath atCell:cell forMemo:filterdMemoArray[indexPath.row]];
    return cell;
}


// 通常時のtableViewの更新処理
- (UITableViewCell *)updateTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    [self setCellInfo:tableView cellForRowAtIndexPath:indexPath atCell:cell forMemo:memoCache[indexPath.row]];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell = [self updateFilterdTableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        cell = [self updateTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BOOL bResult = [memoDao remove:memoCache[indexPath.row]];
        if (bResult) {
            Memo *memo = memoCache[indexPath.row];
            NSMutableArray *lines = [NSMutableArray array];
            [memo.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                [lines addObject:line];
                *stop = YES;
            }];
            
            NSString *title;
            if (lines.count <= 0) {
                title = @"(no title)";
            } else {
                title = [lines objectAtIndex:0];
            }
            DDLogInfo(@"メモ一覧表示: メモ削除 >> %@", title);
            [memoCache removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

// tableViewCellの色を変える場合はこのタイミングで行う
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    } else {
        cell.backgroundColor = [UIColor colorWithHue:0.61 saturation:0.09 brightness:0.99 alpha:1.0];
    }
}

// iPadの場合、セルの選択イベントで処理(iPhoneでもセグエイベント処理後にイベント発生するので注意)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        [appDelegate.editMemoViewController setDetailItem:filterdMemoArray[indexPath.row]];
    } else {
        [appDelegate.editMemoViewController setDetailItem:memoCache[indexPath.row]];
    }
}

#pragma mark UISearchBarDelegate

//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
//{
//    [TMAppContext sharedManager].activeTextField = self.memoSearchBar;
//    return YES;
//}
//
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    [TMAppContext sharedManager].activeTextField = nil;
//}

#pragma mark Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [filterdMemoArray removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.body contains[c] %@",searchText];
    filterdMemoArray = [NSMutableArray arrayWithArray:[memoCache filteredArrayUsingPredicate:predicate]];
}

#pragma mark - UISearchDisplayController Delegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

// 回転処理 -----------------------------------------------

// 回転時の各ビューのサイズ・表示位置の調整を行う
- (void)changeRotateForm
{
    CGFloat height = self.view.bounds.size.height + self.memoSearchBar.bounds.size.height;
    
#ifdef DISP_AD_BOTTOM
    adView.frame = CGRectMake(0, height, adView.frame.size.width, adView.frame.size.height);
	if (bannerIsVisible) {
		adView.frame = CGRectOffset(adView.frame, 0, -CGRectGetHeight(adView.frame));
    }
#else
	if (bannerIsVisible) {
		adView.frame = CGRectMake(0, 0, adView.frame.size.width, adView.frame.size.height);
    }
    else{
        adView.frame = CGRectMake(0, -adView.frame.size.height, adView.frame.size.width, adView.frame.size.height);
    }
#endif
}

// 回転アニメーション直前にコール
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    DDLogInfo(@"メモ一覧表示: ローテーション %d", interfaceOrientation);
    [self changeRotateForm];
}

// スクロールされる度に呼ばれる
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect frame = self.view.frame;
    float viewHeight = frame.size.height;
    float adViewWidth = adView.frame.size.width;
    float adViewHeight = adView.frame.size.height;
    adView.center = CGPointMake(adViewWidth / 2, self.tableView.contentOffset.y + viewHeight - adViewHeight / 2);
    [self.view bringSubviewToFront:adView];
}

#pragma mark - iAd Delegate

// iAD ------------------------------------------------

// 新しい広告がロードされた後に呼ばれる
// 非表示中のバナービューを表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	if (!bannerIsVisible) {
		[UIView beginAnimations:@"animateAdBannerOn" context:NULL];
		[UIView setAnimationDuration:1.0];
        
#ifdef DISP_AD_BOTTOM
		banner.frame = CGRectOffset(banner.frame, 0, -CGRectGetHeight(banner.frame));
#else
		banner.frame = CGRectOffset(banner.frame, 0, CGRectGetHeight(banner.frame));
#endif
        banner.alpha = 1.0;
        
		[UIView commitAnimations];
		bannerIsVisible = YES;
        DDLogInfo(@"メモ一覧表示: iAd表示");
	}
}

// 広告バナータップ後に広告画面切り替わる前に呼ばれる
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	BOOL shoudExecuteAction = YES; // 広告画面に切り替える場合はYES（通常はYESを指定する）
	if (!willLeave && shoudExecuteAction) {
		// 必要ならココに、広告と競合する可能性のある処理を一時停止する処理を記述する。
        DDLogInfo(@"メモ一覧表示: iAdタップ");
	}
	return shoudExecuteAction;
}

// 広告画面からの復帰時に呼ばれる
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    // 必要ならココに、一時停止していた処理を再開する処理を記述する。
}

// 表示中の広告が無効になった場合に呼ばれる
// 表示中のバナービューを非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		[UIView setAnimationDuration:1.0];
        
#ifdef DISP_AD_BOTTOM
        banner.frame = CGRectOffset(banner.frame, 0, CGRectGetHeight(banner.frame));
#else
        banner.frame = CGRectOffset(banner.frame, 0, -CGRectGetHeight(banner.frame));
#endif
        banner.alpha = 0.0;
        
        [UIView commitAnimations];
        bannerIsVisible = NO;
        DDLogInfo(@"メモ一覧表示: iAd非表示 >> %@", [error localizedDescription]);
    }
}

@end
