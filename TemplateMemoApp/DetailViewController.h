//
//  DetailViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/06/02.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common/Memo.h"
#import "Common/MemoDao.h"

@interface DetailViewController : UIViewController
    <UISplitViewControllerDelegate, UITextViewDelegate>

// IBOutlet
@property (weak, nonatomic) IBOutlet UITableView *baseTableView;
@property (weak, nonatomic) IBOutlet UITextField *tagTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *bodyScrollView;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;

// Custom UI
@property (strong, nonatomic) UIBarButtonItem *addMemoButton;
@property (strong, nonatomic) UIBarButtonItem *editDoneButton;

// member
@property (strong, nonatomic) Memo* detailItem;
@property (nonatomic, strong) MemoDaoImpl* memoDao;
@property (assign, nonatomic) bool editMode;

@end
