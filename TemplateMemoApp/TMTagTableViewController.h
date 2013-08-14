//
//  TMTagTableViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class TMEditViewController;

@interface TMTagTableViewController : UITableViewController
    <UISearchDisplayDelegate, UISearchBarDelegate, ADBannerViewDelegate>
{
    ADBannerView *adView;
    BOOL bannerIsVisible;
    BOOL fastViewFlag;
}
@property (weak, nonatomic) IBOutlet UISearchBar *tagSearchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *tagSearchBarController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addTagButton;

// セルの更新
- (void)updateVisibleCells;
- (IBAction)insertTag:(id)sender;

@end
