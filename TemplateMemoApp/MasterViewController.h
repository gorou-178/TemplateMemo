//
//  MasterViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/06/02.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common/MemoDao.h"

@class TMEditViewController;

@interface MasterViewController : UITableViewController

@property (nonatomic, strong) MemoDaoImpl* memoDao;
@property (strong, nonatomic) TMEditViewController *tmEditViewController;

@end
