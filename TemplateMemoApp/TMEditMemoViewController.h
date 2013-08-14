//
//  TMEditMemoViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/26.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

#import "TMTextView.h"

@class Memo;
@class TemplateMemo;
@class MemoUndoRedoStore;

typedef enum enumTMEditTarget
{
    TMEditTargetMemo,
    TMEditTargetTemplate
} TMEditTarget;

@interface TMEditMemoViewController : UIViewController
    <UISplitViewControllerDelegate, UITextViewDelegate, ADBannerViewDelegate>
{
    ADBannerView *adView;
    BOOL bannerIsVisible;
    BOOL fastViewFlag;
}

// IBOutlet
@property (weak, nonatomic) IBOutlet UIScrollView *bodyScrollView;
@property (weak, nonatomic) IBOutlet TMTextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *tagSettingButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *memoInfoButton;

// Custom UI
@property (strong, nonatomic) UIBarButtonItem *addMemoButton;
@property (strong, nonatomic) UIBarButtonItem *editDoneButton;

// member
@property (strong, nonatomic) Memo* detailItem;
@property (strong, nonatomic) TemplateMemo* templateMemo;
@property (assign, nonatomic) BOOL editMode;
@property (assign, nonatomic) TMEditTarget editTarget;
@property (strong, nonatomic) MemoUndoRedoStore *undoStore;
@property (strong, nonatomic) MemoUndoRedoStore *redoStore;

// Public Selector
- (Memo *)currentMemo;
- (TemplateMemo *)currentTemplateMemo;
- (void)setActiveSideView:(UITableViewController*)tableViewController;
@end
