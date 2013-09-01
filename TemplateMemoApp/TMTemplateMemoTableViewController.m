//
//  TMTemplateMemoTableViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/25.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "AppDelegate.h"
#import "TMTemplateMemoTableViewController.h"
#import "TemplateDao.h"

#import "TemplateMemoSettingInfo.h"
#import "TemplateMemo.h"
#import "UserDefaultsWrapper.h"

@interface TMTemplateMemoTableViewController (){
    id<TemplateDao> templateDao;
    NSMutableArray *templateCache;
    NSMutableArray *filterdTemplateArray;
    BOOL _isSearching, _searchBarIsVisible;
}

@end

@implementation TMTemplateMemoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    templateDao = [[TemplateDaoImpl alloc] initWithFMDBWrapper:appDelegate.fmdb];
    templateCache = [[templateDao templates] mutableCopy];
    filterdTemplateArray = [[NSMutableArray alloc] init];
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.templateMemoViewController = self;
    
    self.templeSearchBar.delegate = self;
    self.templeSearchBarController.delegate = self;
    
    // UISearchBarのplaceholderのlocalizeがバグっているためあえて設定
    [self.templeSearchBar setPlaceholder:NSLocalizedString(@"templateview.searchbar.placeholer", @"templateview search bar placeholer")];
    
    self.templeSearchBar.scopeButtonTitles = @[
                                              NSLocalizedString(@"templatememoview.searchbar.scope.body", @"template memo view search scope - body"),
                                              NSLocalizedString(@"templatememoview.searchbar.scope.name", @"template memo view search scope - name"),
                                              NSLocalizedString(@"templatememoview.searchbar.scope.name_body", @"template memo view search scope - name + body")
                                              ];
    
    [self.templeSearchBar setShowsScopeBar:NO];
    [self.templeSearchBar sizeToFit];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"テンプレート一覧表示");
    [super viewWillAppear:animated];
    // 検索バーを隠す
//    [self.tableView setContentOffset:CGPointMake(0.0f, self.searchDisplayController.searchBar.frame.size.height)];
    
    // 選択していたセルまでスクロールさせる
    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)insertTemplateMemo:(id)sender
{
    // テキスト付きアラートダイアログ
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"templatememoview.insert.title", @"template memo view insert temple dialog title")
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"templatememoview.insert.cancel", @"template memo view insert temple dialog cancel button")
                                          otherButtonTitles:NSLocalizedString(@"templatememoview.insert.ok", @"template memo view insert temple dialog ok button"), nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    NSUInteger bytes = [inputText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if(bytes >= 1 && bytes <= 24)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//OKボタンが押されたときのメソッド
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // OKボタンの処理（Cancelボタンの処理は標準でAlertを終了する処理が設定されている）
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if (buttonIndex == 1) {
        for (TemplateMemo *templateMemo in templateCache) {
            // 同名タグが存在した場合警告を表示
            if ([[templateMemo.name lowercaseString] isEqualToString:[inputText lowercaseString]]) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:NSLocalizedString(@"templatememoview.insert.warning.title", @"template memo view insert temple dialog warning title")
                                      message:NSLocalizedString(@"templatememoview.insert.warning.message", @"template memo view insert temple dialog warning message")
                                      delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:NSLocalizedString(@"templatememoview.insert.warning.ok", @"template memo view insert temple dialog warning ok button"), nil
                                      ];
                [alert show];
                return;
            }
        }
        
        // テンプレートを追加
        TemplateMemo *templateMemo = [[TemplateMemo alloc] init];
        templateMemo.name = [inputText mutableCopy];
        templateMemo.body = @"";
        BOOL bResult = [templateDao add:templateMemo];
        if (bResult) {
            // 追加したデータのIDと日付の取得のため再取得
            templateCache = [[templateDao templates] mutableCopy];
            
            // セルを一番上に追加
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // 意図的に選択
            [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
            
            // トップにスクロールさせる
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            DDLogInfo(@"テンプレート一覧表示: テンプレート追加 >> %@", templateMemo.name);
        }
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return filterdTemplateArray.count;
    } else {
        return templateCache.count;
    }
}

// セルの更新
- (void)updateVisibleCells
{
    // TODO: 別の場所でやりたい
    templateCache = [[templateDao templates] mutableCopy];
    [self.tableView reloadData];
}

- (void)setCellInfo:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath atCell:(UITableViewCell *)cell forTemplate:(TemplateMemo *)templateMemo
{
    cell.imageView.image = [UIImage imageNamed:@"note_32.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = templateMemo.name;
    
    // 改行までをタイトルとして設定
    NSMutableArray *lines = [NSMutableArray array];
    [templateMemo.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [lines addObject:line];
    }];
    
    // プレビュー内容を作成(2行目以降で作成)
    if (lines.count > 0) {
        NSMutableString *previewMemo = [NSMutableString new];
        for (int i = 0; i < lines.count; i++) {
            if ([previewMemo length] > 50) {
                break;
            }
            [previewMemo appendString:lines[i]];
        }
        if ([previewMemo length] <= 0) {
            cell.detailTextLabel.text = NSLocalizedString(@"templatememoview.cell.preview.empty", @"template memo view cell preview empty");
        } else {
            cell.detailTextLabel.text = previewMemo.copy;
        }
    } else {
        cell.detailTextLabel.text = NSLocalizedString(@"templatememoview.cell.preview.empty", @"template memo view cell preview empty");
    }
}

// 検索時のtableViewの更新処理
- (UITableViewCell *)updateFilterdTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    [self setCellInfo:tableView cellForRowAtIndexPath:indexPath atCell:cell forTemplate:filterdTemplateArray[indexPath.row]];
    return cell;
}


// 通常時のtableViewの更新処理
- (UITableViewCell *)updateTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    [self setCellInfo:tableView cellForRowAtIndexPath:indexPath atCell:cell forTemplate:templateCache[indexPath.row]];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell = [self updateFilterdTableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        cell = [self updateTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {        
        [self removeTemplate:templateCache[indexPath.row]];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (BOOL)removeTemplate:(TemplateMemo *)templateMemo
{
    BOOL bResult = NO;
    
    if (![templateCache containsObject:templateMemo]) {
        return bResult;
    }
    
    NSInteger row = -1;
    for (int i = 0; i < templateCache.count; i++) {
        if ([templateMemo isEqual:templateCache[i]]) {
            row = i;
            break;
        }
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    // 同じテンプレートの場合
    TemplateMemoSettingInfo *templateMemoSettingInfo = [[TemplateMemoSettingInfo alloc] init];
    TemplateMemo *defTemplateMemo = [UserDefaultsWrapper loadToObject:templateMemoSettingInfo.key];
    if ([defTemplateMemo isEqual:templateCache[indexPath.row]]) {
        // テキスト付きアラートダイアログ
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"templatememoview.remove.warning.title", @"template memo view remove temple warning title")
                                                        message:NSLocalizedString(@"templatememoview.remove.warning.message", @"template memo view remove temple warning message")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"templatememoview.remove.warning.ok", @"template memo view remove temple warning ok button")
                                              otherButtonTitles:nil];
        [alert show];
        bResult = YES;
    }
    else {
        bResult = [templateDao remove:templateCache[indexPath.row]];
        if (bResult) {
            DDLogInfo(@"テンプレート一覧表示: テンプレート削除 >> %@", ((TemplateMemo *)templateCache[indexPath.row]).name);
            [templateCache removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
    return bResult;
}

//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
//{
//    [TMAppContext sharedManager].activeTextField = self.templeSearchBar;
//    return YES;
//}
//
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    [TMAppContext sharedManager].activeTextField = nil;
//}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [appDelegate.editMemoViewController setTemplateMemo:filterdTemplateArray[indexPath.row]];
    } else {
        [appDelegate.editMemoViewController setTemplateMemo:templateCache[indexPath.row]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    TMEditMemoViewController *editMemoViewController = (TMEditMemoViewController*)segue.destinationViewController;
    if (appDelegate.editMemoViewController == nil) {
        appDelegate.editMemoViewController = editMemoViewController;
    }
}

#pragma mark Content Filtering

-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [filterdTemplateArray removeAllObjects];
    if ([scope isEqualToString:NSLocalizedString(@"templatememoview.searchbar.scope.name", @"template memo view search scope - name")]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@",searchText];
        filterdTemplateArray = [NSMutableArray arrayWithArray:[templateCache filteredArrayUsingPredicate:predicate]];
    } else if ([scope isEqualToString:NSLocalizedString(@"templatememoview.searchbar.scope.body", @"template memo view search scope - body")]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.body contains[c] %@",searchText];
        filterdTemplateArray = [NSMutableArray arrayWithArray:[templateCache filteredArrayUsingPredicate:predicate]];
    } else if ([scope isEqualToString:NSLocalizedString(@"templatememoview.searchbar.scope.name_body", @"template memo view search scope - name + body")]) {
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"self.name contains[c] %@",searchText];
        NSPredicate *bodyPredicate = [NSPredicate predicateWithFormat:@"self.body contains[c] %@",searchText];
        NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:namePredicate, bodyPredicate, nil]];
        filterdTemplateArray = [NSMutableArray arrayWithArray:[templateCache filteredArrayUsingPredicate:predicate]];
    }
}

#pragma mark - UISearchDisplayController Delegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
    [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

@end
