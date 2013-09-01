//
//  TMTagTableViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "AppDelegate.h"
#import "TMTagTableViewController.h"
#import "TagDao.h"
#import "MemoDao.h"

#define DISP_AD_BOTTOM

static const NSInteger ALERT_TAG_ADD = 1;
static const NSInteger ALERT_TAG_EDIT = 2;

@interface TMTagTableViewController ()
{
    id<TagDao> tagDao;
    id<MemoDao> memoDao;
    NSMutableArray *tagCache;
    NSMutableArray *filterdTagArray;
}

@end

@implementation TMTagTableViewController

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.tagTableViewController = self;
    [appDelegate.editMemoViewController setActiveSideView:self];
    
    memoDao = [[MemoDaoImpl alloc] initWithFMDBWrapper:appDelegate.fmdb];
    filterdTagArray = [[NSMutableArray alloc] init];
    
    // タグ一覧を取得
    tagDao = [[TagDaoImpl alloc] initWithFMDBWrapper:appDelegate.fmdb];
    tagCache = [tagDao.tags mutableCopy];
    
    fastViewFlag = YES;
	bannerIsVisible = NO;
    
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
    self.tagSearchBar.delegate = self;
    self.tagSearchBarController.delegate = self;
    
    // UISearchBarのplaceholderのlocalizeがバグっているためあえて設定
    [self.tagSearchBar setPlaceholder:NSLocalizedString(@"tagview.searchbar.placeholer", @"tagview search bar placeholer")];
    
    // iPhoneのときのみ表示
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
    
    // ダミーのフッター
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 120)];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"タグ一覧表示");
    [super viewWillAppear:animated];
    // 選択していたセルまでスクロールさせる(戻った時に選択したセルを見せたほうが使いやすい)
    // 検索バーを隠すと選択セルまでスクロールができなかったため(一番上までスクロールされる)
    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    // 選択セルのハイライトを解除
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

// 回転処理 -----------------------------------------------

// 回転時の各ビューのサイズ・表示位置の調整を行う
- (void)changeRotateForm
{
    //CGFloat height = self.view.bounds.size.height + self.tagSearchBar.bounds.size.height;
    CGFloat height = self.view.bounds.size.height + self.tableView.contentOffset.y;
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
    DDLogInfo(@"タグ一覧表示: ローテーション %d", interfaceOrientation);
    [self changeRotateForm];
}

- (void)didReceiveMemoryWarning
{
    DDLogInfo(@"タグ一覧表示: メモリ警告");
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
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return filterdTagArray.count;
    } else {
        return tagCache.count + 1;
    }
}

// 画面上に見えているセルの表示更新
- (void)updateVisibleCells {
    // キャッシュを更新
    tagCache = [tagDao.tags mutableCopy];
    // テーブルを全更新
    [self.tableView reloadData];
}

- (IBAction)insertTag:(id)sender {
    // テキスト付きアラートダイアログ
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"tagview.inserttag.title", @"tag view insert tag dialog title")
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"tagview.inserttag.cancel", @"tag view insert tag dialog cancel button")
                                          otherButtonTitles:NSLocalizedString(@"tagview.inserttag.ok", @"tag view insert tag dialog ok button"), nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    NSUInteger bytes = [inputText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if(bytes >= 1 && bytes <= 24)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//OKボタンが押されたときのメソッド
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // OKボタンの処理（Cancelボタンの処理は標準でAlertを終了する処理が設定されている）
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if (buttonIndex == 1) {
        for (Tag* tag in tagCache) {
            // 同名タグが存在した場合警告を表示
            if ([[tag.name lowercaseString] isEqualToString:[inputText lowercaseString]]) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:NSLocalizedString(@"tagview.inserttag.warning.title", @"same tag name warning title")
                                      message:NSLocalizedString(@"tagview.inserttag.warning.message", @"same tag name warning message")
                                      delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"tagview.inserttag.warning.ok", @"same tag name warning ok button"), nil
                                      ];
                [alert show];
                return;
            }
        }
        
//        if (alertView.tag == ALERT_TAG_ADD) {
        // タグを追加
        Tag *newTag = [[Tag alloc] init];
        newTag.name = inputText;
        if ([tagDao add:newTag]) {
            newTag.tagId = [tagDao maxRefCount];
            [tagCache insertObject:newTag atIndex:0];
            
            // セルを二番目に追加
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // 追加したセルを選択 & 表示(対象が中心に来るようにスクロール)
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            
            // 選択ハイライトをフェードアウトさせる
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
            
            // サイズ更新
            [self changeRotateForm];
            DDLogInfo(@"タグ一覧表示: タグ追加 >> %@", newTag.name);
        }
//        }
//        else if (alertView.tag == ALERT_TAG_EDIT) {
//            Tag *updateTag = tagCache[self.tableView.indexPathForSelectedRow.row];
//            updateTag.name = inputText;
//            if ([tagDao update:updateTag]) {
//                tagCache = [[tagDao tags] mutableCopy];
//                [self.tableView reloadData];
//            }
//        }
    }
}

//- (void)setCellInfo:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath atCell:(UITableViewCell *)cell forTag:(Tag *)tag
//{
//    if (indexPath.row == 0) {
//        // 一番最初は「All Memo」
//        cell.textLabel.text = NSLocalizedString(@"tagview.cell.allmemo", @"タグビューのセル - All Memo");
//        cell.imageView.image = [UIImage imageNamed:@"home_32.png"];
//        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", [memoDao count]];
//    } else {
//        Tag *tag = tagCache[indexPath.row - 1];
//        cell.textLabel.text = tag.name;
//        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", [tagDao countOfMemo:tag]];
//    }
//}

// 検索時のtableViewの更新処理
- (UITableViewCell *)updateFilterdTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    
    Tag *tag = filterdTagArray[indexPath.row];
    cell.textLabel.text = tag.name;
    cell.imageView.image = [UIImage imageNamed:@"label_32.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", [tagDao countOfMemo:tag]];
    
    return cell;
}

// 通常時のtableViewの更新処理
- (UITableViewCell *)updateTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    
    if (indexPath.row == 0) {
        // 一番最初は「All Memo」
        cell.textLabel.text = NSLocalizedString(@"tagview.cell.allmemo", @"tag view cell - All Memo");
        cell.imageView.image = [UIImage imageNamed:@"home_32.png"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", [memoDao count]];
    } else {
        Tag *tag = tagCache[indexPath.row - 1];
        cell.textLabel.text = tag.name;
        cell.imageView.image = [UIImage imageNamed:@"label_32.png"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d", [tagDao countOfMemo:tag]];
    }
    
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
    if (indexPath.row == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // タグを削除(tagLinkも削除する)
        BOOL bResult = [tagDao remove:tagCache[indexPath.row - 1]];
        if (bResult) {
            DDLogInfo(@"タグ一覧表示: タグ削除 >> %@", ((Tag*)tagCache[indexPath.row - 1]).name);
            [tagCache removeObjectAtIndex:indexPath.row - 1];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

// tableViewCellの色を変える場合はこのタイミングで行う
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row % 2 == 0) {
//        cell.backgroundColor = [UIColor whiteColor];
//    } else {
//        cell.backgroundColor = [UIColor colorWithHue:0.61 saturation:0.09 brightness:0.99 alpha:1.0];
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 検索時セルタップでセグエを実行(セルにセグエが関連付けされていないため)
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self performSegueWithIdentifier:@"showTagMemo" sender:tableView];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTagMemo"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TMMemoTableViewController *memoTableViewController = [segue destinationViewController];
        if (sender == self.searchDisplayController.searchResultsTableView) {
            [memoTableViewController showTagMemo:filterdTagArray[indexPath.row]];
        } else {
            // 「All Memo」の場合
            if (indexPath.row == 0) {
                [memoTableViewController showTagMemo:nil];
            } else {
                [memoTableViewController showTagMemo:tagCache[indexPath.row - 1]];
            }
        }
    }
}

#pragma mark UISearchBarDelegate

//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
//{
//    [TMAppContext sharedManager].activeTextField = self.tagSearchBar;
//    return YES;
//}
//
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    [TMAppContext sharedManager].activeTextField = nil;
//}

#pragma mark Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [filterdTagArray removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@",searchText];
    filterdTagArray = [NSMutableArray arrayWithArray:[tagCache filteredArrayUsingPredicate:predicate]];
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
        DDLogInfo(@"タグ一覧表示: iAd表示");
	}
}

// 広告バナータップ後に広告画面切り替わる前に呼ばれる
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	BOOL shoudExecuteAction = YES; // 広告画面に切り替える場合はYES（通常はYESを指定する）
	if (!willLeave && shoudExecuteAction) {
		// 必要ならココに、広告と競合する可能性のある処理を一時停止する処理を記述する。
        DDLogInfo(@"タグ一覧表示: iAdタップ");
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
        DDLogInfo(@"タグ一覧表示: iAd非表示 >> %@", [error localizedDescription]);
    }
}

@end
