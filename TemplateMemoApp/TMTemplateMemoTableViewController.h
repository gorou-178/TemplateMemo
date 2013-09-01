//
//  TMTemplateMemoTableViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/25.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMTemplateMemoTableViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *templeSearchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *templeSearchBarController;
- (IBAction)insertTemplateMemo:(id)sender;
// セルの更新
- (void)updateVisibleCells;

- (BOOL)removeTemplate:(TemplateMemo *)templateMemo;

@end
