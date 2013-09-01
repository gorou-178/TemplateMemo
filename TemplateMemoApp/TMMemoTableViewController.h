//
//  TMMemoTableViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "Common/MemoDao.h"

@interface TMMemoTableViewController : UITableViewController
    <UISearchDisplayDelegate, UISearchBarDelegate, ADBannerViewDelegate>
{
    ADBannerView *adView;
    BOOL bannerIsVisible;
    BOOL fastViewFlag;
}
@property (weak, nonatomic) IBOutlet UISearchBar *memoSearchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *memoSearchBarController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addMemoButton;

- (IBAction)onPushAddButton:(id)sender;

// タグのメモ一覧を表示
- (void)showTagMemo:(Tag *)tag;

// セルの更新
- (void)updateVisibleCells;

- (BOOL)removeMemo:(Memo *)memo;

@end
