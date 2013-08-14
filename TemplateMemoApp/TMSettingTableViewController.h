//
//  TMSettingTableViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@interface TMSettingTableViewController : UITableViewController <ADBannerViewDelegate>
{
    ADBannerView *adView;
    BOOL bannerIsVisible;
    BOOL fastViewFlag;
}
@end
