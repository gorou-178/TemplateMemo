//
//  TMMemoInfoTableViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/01.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMEditMemoViewController;

@interface TMMemoInfoTableViewController : UITableViewController
- (void)setActiveMemo:(TMEditMemoViewController *)editViewController;
@end
