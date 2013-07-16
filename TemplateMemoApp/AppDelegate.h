//
//  AppDelegate.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/06/02.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMTagTableViewController.h"
#import "TMMemoTableViewController.h"
#import "TMEditViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TMTagTableViewController *tagTableViewController;
@property (strong, nonatomic) TMMemoTableViewController *memoTableViewController;
@property (strong, nonatomic) TMEditViewController *editViewController;

@end
