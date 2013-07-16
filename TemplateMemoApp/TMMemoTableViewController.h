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

// メモの追加
- (void)insertNewObject:(id)sender;

// タグのメモ一覧を表示
- (void)showTagMemo:(Tag *)tag;

// セルの更新
- (void)updateVisibleCells;

@end
