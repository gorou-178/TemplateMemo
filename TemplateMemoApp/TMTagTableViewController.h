//
//  TMTagTableViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMEditViewController;

@interface TMTagTableViewController : UITableViewController

@property (strong, nonatomic) TMEditViewController *tmEditViewController;

// セルの更新
- (void)updateVisibleCells;

@end
