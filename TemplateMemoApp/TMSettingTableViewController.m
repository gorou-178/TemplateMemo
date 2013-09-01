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
#import "TemplateMemo.h"
#import "TemplateMemoDataSource.h"
#import "TemplateMemoSettingInfo.h"

#import "AAMFeedbackViewController.h"

#define DISP_AD_BOTTOM

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

- (void)awakeFromNib
{
    fastViewFlag = YES;
	bannerIsVisible = NO;
    
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"設定表示");
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    [self.tableView reloadData];
    [self changeRotateForm];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    DDLogInfo(@"設定表示: ローテーション >> %d", interfaceOrientation);
    [self changeRotateForm];
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
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            settingInfo = [[TemplateMemoSettingInfo alloc] init];
            TemplateMemo *templateMemo = [UserDefaultsWrapper loadToObject:settingInfo.key];
            cell.detailTextLabel.text = templateMemo.labelText;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    [self updateCellData:tableView cellForRowAtIndexPath:indexPath tableViewCell:cell];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        if (indexPath.row == 2) {
            AAMFeedbackViewController *vc = [[AAMFeedbackViewController alloc]init];
            vc.toRecipients = [NSArray arrayWithObject:@"template-memo.app@gurimmer.lolipop.jp"];
            vc.ccRecipients = nil;
            vc.bccRecipients = nil;
            UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:vc];
            [self presentViewController:nvc animated:YES completion:nil];
            DDLogInfo(@"設定表示: ご意見・ご要望を送るタップ");
        }
    }
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
    } else if ([[segue identifier] isEqualToString:@"showTemplate"]) {
        SettingInfo *settingInfo = [[TemplateMemoSettingInfo alloc] init];
        settingInfo.dataSource = [[TemplateMemoDataSource alloc] init];
        [viewController setSettingInfo:settingInfo withDataList:settingInfo.dataSource.dataList];
    }
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
        DDLogInfo(@"設定表示: iAd表示");
	}
}

// 広告バナータップ後に広告画面切り替わる前に呼ばれる
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	BOOL shoudExecuteAction = YES; // 広告画面に切り替える場合はYES（通常はYESを指定する）
	if (!willLeave && shoudExecuteAction) {
		// 必要ならココに、広告と競合する可能性のある処理を一時停止する処理を記述する。
        DDLogInfo(@"設定表示: iAdタップ");
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
        DDLogInfo(@"設定表示: iAd非表示 >> %@", [error localizedDescription]);
    }
}

@end
