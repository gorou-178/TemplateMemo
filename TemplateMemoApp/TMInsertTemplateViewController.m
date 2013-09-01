//
//  TMInsertTemplateViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/20.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "AppDelegate.h"
#import "TMEditMemoViewController.h"
#import "TMInsertTemplateViewController.h"
#import "TemplateDao.h"

@interface TMInsertTemplateViewController ()
{
    id<TemplateDao> templateDao;
    NSMutableArray *templateCache;
    NSRange currentRange;
}
@end

@implementation TMInsertTemplateViewController

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
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"テンプレート追記画面表示");
    templateCache = [[templateDao templates] mutableCopy];
}

- (void)viewDidDisappear:(BOOL)animated
{
    templateCache = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return templateCache.count;
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
            cell.detailTextLabel.text = NSLocalizedString(@"inserttempleview.cell.preview.empty", @"insert template view empty preview");
        } else {
            cell.detailTextLabel.text = previewMemo.copy;
        }
    } else {
        cell.detailTextLabel.text = NSLocalizedString(@"inserttempleview.cell.preview.empty", @"insert template view empty preview");
    }
}

// 通常時のtableViewの更新処理
- (UITableViewCell *)updateTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
//    if ( cell == nil ) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
//    }
    [self setCellInfo:tableView cellForRowAtIndexPath:indexPath atCell:cell forTemplate:templateCache[indexPath.row]];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [self updateTableView:tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 選択をフェードアウト
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
    TemplateMemo *template = templateCache[indexPath.row];
    [self dismissViewControllerAnimated:YES completion:^(void){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate.editMemoViewController insertTemplate:template atRange:currentRange];
        });
    }];
}

- (void)setCurrentCaretPosision:(NSRange)range
{
    currentRange = range;
}

- (IBAction)onPushCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate.editMemoViewController insertTemplate:nil atRange:currentRange];
        });
    }];
}

@end
