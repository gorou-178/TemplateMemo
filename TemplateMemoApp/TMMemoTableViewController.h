//
//  TMMemoTableViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common/MemoDao.h"

@interface TMMemoTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *memoCache;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addMemoButton;

// メモの追加
- (IBAction)insertNewObject:(id)sender;
//- (void)insertNewObject:(id)sender;

// タグのメモ一覧を表示
- (void)showTagMemo:(Tag *)tag;

// セルの更新
- (void)updateVisibleCells;

@end
