//
//  TMEditMemoViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/26.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Memo;
@class TemplateMemo;

@interface TMEditMemoViewController : UIViewController
    <UISplitViewControllerDelegate, UITextViewDelegate>

// IBOutlet
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;

// Custom UI
@property (strong, nonatomic) UIBarButtonItem *addMemoButton;
@property (strong, nonatomic) UIBarButtonItem *editDoneButton;

// member
@property (strong, nonatomic) Memo* detailItem;
@property (strong, nonatomic) TemplateMemo* templateMemo;
@property (assign, nonatomic) bool editMode;

// Public Selector
- (Memo *)currentMemo;
- (TemplateMemo *)currentTemplateMemo;
- (void)setActiveSideView:(UITableViewController*)tableViewController;
@end
