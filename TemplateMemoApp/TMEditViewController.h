//
//  TMEditViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/04.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common/MemoDao.h"

@class TMMemoTableViewController;

@interface TMEditViewController : UITableViewController
    <UISplitViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate>

// IBOutlet
@property (weak, nonatomic) IBOutlet UITextField *tagTextField;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;

// Custom UI
@property (strong, nonatomic) UIBarButtonItem *addMemoButton;
@property (strong, nonatomic) UIBarButtonItem *editDoneButton;

@property (strong, nonatomic) TMMemoTableViewController* memoTableViewController;

// member
@property (strong, nonatomic) Memo* detailItem;
@property (assign, nonatomic) bool editMode;

// Action
- (IBAction)onDidEndOnExitForTagTextField:(id)sender;

@end
