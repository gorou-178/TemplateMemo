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

#import "TMMemoCellView.h"

#import "DateUtil.h"

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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.memoTableViewController = self;
    
    activeFilterTag = nil;
    memoDao = [[MemoDaoImpl alloc] initWithFMDBWrapper:appDelegate.fmdb];
    tagDao = [[TagDaoImpl alloc] initWithFMDBWrapper:appDelegate.fmdb];
    filterdMemoArray = [[NSMutableArray alloc] init];
    
    fastViewFlag = YES;
	bannerIsVisible = NO;
    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // UITableViewのCellサブクラスとしてXIBのサブクラスを登録
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([TMMemoCellView class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    
    self.memoSearchBar.delegate = self;
    self.memoSearchBarController.delegate = self;
    
    // UISearchBarのplaceholderのlocalizeがバグっているためあえて設定
    [self.memoSearchBar setPlaceholder:NSLocalizedString(@"memoview.searchbar.placeholer", @"memoview search bar placeholer")];
    
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
    
    // 全てのメモ
//    [self showTagMemo:nil];
}

- (void)onPushBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"メモ一覧表示");
    [super viewWillAppear:animated];
    
    // 検索バーを隠す + 一番上にスクロール(更新すると一番上に来る + 新規追加でも一番上に追加されるため)
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
            
            // サイズ更新
            [self changeRotateForm];
        }
    }
    else if ([[segue identifier] isEqualToString:@"showMemo"]) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        NSIndexPath *indexPath = (NSIndexPath*)sender;
        if (self.tableView == self.searchDisplayController.searchResultsTableView)
        {
            [appDelegate.editMemoViewController setDetailItem:filterdMemoArray[indexPath.row]];
        } else {
            [appDelegate.editMemoViewController setDetailItem:memoCache[indexPath.row]];
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
    TemplateMemoSettingInfo *templateMemoSettingInfo = [[TemplateMemoSettingInfo alloc] init];
    TemplateMemo *templateMemo = [UserDefaultsWrapper loadToObject:templateMemoSettingInfo.key];
    
    // TODO: 何も入力せずに別のメモを選択 または 画面を戻った場合に、新規追加をなかったことにしたい
    Memo* memo = [[Memo alloc] init];
    memo.createDate = [DateUtil nowDateForSystemTimeZone];
    memo.modifiedDate = memo.createDate;
    if (templateMemo != nil) {
        if ([templateMemo.body length] > 0) {
            
            NSMutableArray *matchStrings = [[NSMutableArray alloc] init];
            NSDate *currentDate = [NSDate date];
            NSMutableString *templateBody = [templateMemo.body mutableCopy];
            
            // 「${date(改行以外の文字列で最短)}」にマッチする正規表現
            NSRegularExpression *dateFormatRegex = [NSRegularExpression regularExpressionWithPattern:@"\\$\\{date(?:\\(([^\r\n]*?)\\))\\}" options:0 error:nil];
            // 「${date}」にマッチする正規表現
            NSRegularExpression *dateRegex = [NSRegularExpression regularExpressionWithPattern:@"\\$\\{date\\}" options:0 error:nil];
            
            /*
             グループの個数が正規表現で変化しても、最大グループ数でnumberOfRangesで返ってくるため、正規表現を分けた。
             また、マッチした場合、元文字列のマッチした「範囲」が返ってくる。
             逐次置換をすると元文字列の範囲が変わってしまいエラーになるため、一旦マッチした文字列を取り出している。
             */
            
            // フォーマットありパターン
            id collectDateFormatWord = ^(NSTextCheckingResult *match, NSMatchingFlags flag, BOOL *stop){
                NSString *format = [templateBody substringWithRange:[match rangeAtIndex:1]];
                NSString *strDate = [DateUtil dateToString:currentDate atDateFormat:format];
                NSDictionary *matchData = @{@"word": [templateBody substringWithRange:[match rangeAtIndex:0]], @"strDate": strDate};
                [matchStrings addObject:matchData];
            };
            
            // フォーマットなしパターン
            id collectDateWord = ^(NSTextCheckingResult *match, NSMatchingFlags flag, BOOL *stop){
                NSString *format = @"yyyy/MM/dd";
                NSString *strDate = [DateUtil dateToString:currentDate atDateFormat:format];
                NSDictionary *matchData = @{@"word": [templateBody substringWithRange:[match rangeAtIndex:0]], @"strDate": strDate};
                [matchStrings addObject:matchData];
            };
            
            NSRange range = NSMakeRange(0, templateBody.length);
            [dateFormatRegex enumerateMatchesInString:templateBody options:0 range:range usingBlock:collectDateFormatWord];
            [dateRegex enumerateMatchesInString:templateBody options:0 range:range usingBlock:collectDateWord];
            
            // 再検索して置換
            for (NSDictionary *matchData in matchStrings) {
                NSRange range = [templateBody rangeOfString:[matchData objectForKey:@"word"]];
                [templateBody replaceCharactersInRange:range withString:[matchData objectForKey:@"strDate"]];
            }
            
            memo.body = templateBody;
        } else {
            memo.body = @"";
        }
    } else {
        memo.body = @"";
    }
    
    // DBに登録
    BOOL bResult = [memoDao add:memo];
    if (bResult) {
        if (activeFilterTag != nil) {
            memoCache = [[memoDao memos] mutableCopy];
            // メモにタグを関連付けする
            [tagDao addTagLink:memoCache[0] forLinkTag:activeFilterTag];
            memoCache = [[memoDao tagMemos:activeFilterTag].memos mutableCopy];
            if (templateMemo != nil) {
                DDLogInfo(@"メモ一覧表示: メモ追加(テンプレート使用:%@, タグ:%@)", templateMemo.name, activeFilterTag.name);
            } else {
                DDLogInfo(@"メモ一覧表示: メモ追加(タグ:%@)", activeFilterTag.name);
            }
        } else {
            memoCache = [[memoDao memos] mutableCopy];
            if (templateMemo != nil) {
                DDLogInfo(@"メモ一覧表示: メモ追加(テンプレート使用:%@)", templateMemo.name);
            } else {
                DDLogInfo(@"メモ一覧表示: メモ追加");
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [self.tableView reloadData];
            [appDelegate.tagTableViewController updateVisibleCells];
        });
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
        self.navigationItem.title = NSLocalizedString(@"memoview.navigation.allmemo.title", @"memo view title - All Memo");
        memoCache = [memoDao.memos mutableCopy];
    } else {
        DDLogInfo(@"メモ一覧表示: %@のメモ", tag.name);
        activeFilterTag = tag;
        self.navigationItem.title = [[NSString alloc] initWithFormat:NSLocalizedString(@"memoview.navigation.tagmemo.title", @"memo view tagmemo title"), tag.name];
        
        // 指定タグがついたメモの一覧を取得
        TagLink *tagLink = [memoDao tagMemos:tag];
        
        // タグのメモ一覧でキャッシュを更新
        memoCache = [tagLink.memos mutableCopy];
    }
    
    // テーブル全体をリロード
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
    if (activeFilterTag != nil) {
        memoCache = [[memoDao tagMemos:activeFilterTag].memos mutableCopy];
    } else {
        memoCache = [memoDao.memos mutableCopy];
    }
    [self.tableView reloadData];
}

// セルの内容を設定する
- (void)setCellInfo:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath atCell:(TMMemoCellView *)cell forMemo:(Memo *)memo
{
    if (cell == nil) {
        return;
    }
    
    cell.tmImageView.image = [UIImage imageNamed:@"document_text_32.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // 改行までをタイトルとして設定
    NSMutableArray *lines = [NSMutableArray array];
    [memo.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [lines addObject:line];
    }];
    
    // 内容が空の場合
    if (lines.count <= 0) {
        cell.tmTitleLabel.text = NSLocalizedString(@"memoview.cell.title.empty", @"memo view cell empty title");
        cell.tmDetailTextLabel.text = NSLocalizedString(@"memoview.cell.preview.empty", @"memo view cell empty preview");
        return;
    }
    
    // タイトルは本文の一行目
    cell.tmTitleLabel.text = [lines objectAtIndex:0];
    if ([cell.tmTitleLabel.text length] <= 0) {
        cell.tmTitleLabel.text = NSLocalizedString(@"memoview.cell.title.empty", @"memo view cell empty title");
    }
    
    // プレビュー内容を作成(2行目以降で作成)
    if (lines.count > 1) {
        NSMutableString *previewMemo = [NSMutableString new];
        for (int i = 1; i < lines.count; i++) {
            // プレビュー2行に収まる程度の文字数で以降を切り捨てる
            if ([previewMemo length] > 50) {
                break;
            }
            [previewMemo appendString:lines[i]];
        }
        if ([previewMemo length] <= 0) {
            cell.tmDetailTextLabel.text = NSLocalizedString(@"memoview.cell.preview.empty", @"memo view cell empty preview");
        } else {
            cell.tmDetailTextLabel.text = previewMemo.copy;
        }
    } else {
        cell.tmDetailTextLabel.text = NSLocalizedString(@"memoview.cell.preview.empty", @"memo view cell empty preview");
    }
    
    // 現在時刻との差分を計算
    NSDate *nowDate = [DateUtil nowDateForSystemTimeZone];
    float tmp= [nowDate timeIntervalSinceDate:memo.modifiedDate];
    int month = (int)(tmp / (86400 * 90));
    int day = (int)(tmp / 86400);
    int hh = (int)(tmp / 3600);
    
    NSString *dayFormat;
    if (month > 0) {
        dayFormat = NSLocalizedString(@"memoview.cell.date.yyyymmdd", @"memo view cell date - yyyymmdd");
    }
    else if (day > 0) {
        dayFormat = NSLocalizedString(@"memoview.cell.date.mmddhhmm", @"memo view cell date - MMdd HH:mm");
    }
    else if (hh > 0) {
        dayFormat = NSLocalizedString(@"memoview.cell.date.hhmm", @"memo view cell date - HH:mm");
    } else {
        dayFormat = NSLocalizedString(@"memoview.cell.date.hhmm", @"memo view cell date - HH:mm");
    }
    
    cell.tmRightTextLabel.text = [DateUtil dateToString:memo.modifiedDate atDateFormat:dayFormat];
}

// 検索時のtableViewの更新処理
- (UITableViewCell *)updateFilterdTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TMMemoCellView *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self setCellInfo:tableView cellForRowAtIndexPath:indexPath atCell:cell forMemo:filterdMemoArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: プレビュー表示行を設定できるようにする
    return 50 + (1 * 14);
}

// 通常時のtableViewの更新処理
- (UITableViewCell *)updateTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TMMemoCellView *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
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
        [self removeMemo:memoCache[indexPath.row]];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (BOOL)removeMemo:(Memo *)memo
{
    if (![memoCache containsObject:memo]) {
        return NO;
    }
    
    NSInteger row = -1;
    for (int i = 0; i < memoCache.count; i++) {
        if ([memo isEqual:memoCache[i]]) {
            row = i;
            break;
        }
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
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
            title = NSLocalizedString(@"memoview.cell.title.empty", @"memo view cell empty title");
        } else {
            title = [lines objectAtIndex:0];
        }
        DDLogInfo(@"メモ一覧表示: メモ削除 >> %@", title);
        [memoCache removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
    }
    return bResult;
}

// iPadの場合、セルの選択イベントで処理(iPhoneでもセグエイベント処理後にイベント発生するので注意)
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // iPhoneの場合、セグエで画面遷移
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self performSegueWithIdentifier:@"showMemo" sender:indexPath];
    }
    else {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            [appDelegate.editMemoViewController setDetailItem:filterdMemoArray[indexPath.row]];
        } else {
            [appDelegate.editMemoViewController setDetailItem:memoCache[indexPath.row]];
        }
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
    CGFloat height = self.view.bounds.size.height + self.tableView.contentOffset.y;
//    CGFloat cellHeight = (self.view.bounds.size.height / (50 + (1 * 14))) * 14;
//    height += cellHeight;
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
