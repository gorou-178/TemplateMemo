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

@interface TMTemplateMemoTableViewController (){
    id<TemplateDao> templateDao;
    NSMutableArray *templateCache;
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
    templateDao = [TemplateDaoImpl new];
    templateCache = [[templateDao templates] mutableCopy];
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.templateMemoViewController = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)insertTemplateMemo:(id)sender
{
    // テキスト付きアラートダイアログ
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"テンプレート名を入力"
                                                    message:@"\n"
                                                   delegate:self
                                          cancelButtonTitle:@"キャンセル"
                                          otherButtonTitles:@"OK", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alert show];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if( [inputText length] >= 1 )
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
            if ([templateMemo.name isEqualToString:inputText]) {
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:@"警告"
                                      message:@"同名のテンプレートが存在します"
                                      delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"OK", nil
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
            
//            // idを設定して、キャッシュの一番上に追加
//            int refCount = [templateDao maxRefCount];
//            templateMemo.templateId = refCount;
//            [templateCache insertObject:templateMemo atIndex:0];
            
            // セルを一番上に追加
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            // 追加したセルを選択 & 表示(トップにスクロールさせる)
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
            
            // 選択ハイライトをフェードアウトさせる
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
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
    return templateCache.count;
}

// セルの更新
- (void)updateVisibleCells
{
    // TODO: 別の場所でやりたい
    templateCache = [[templateDao templates] mutableCopy];
    [self.tableView reloadData];
//    for (UITableViewCell *cell in [self.tableView visibleCells]){
//        [self updateCell:cell forTableView:self.tableView atIndexPath:[self.tableView indexPathForCell:cell]];
//    }
}

- (void)updateCell:(UITableViewCell *)cell forTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    TemplateMemo *templateMemo = templateCache[indexPath.row];
    cell.textLabel.text = templateMemo.name;
    
    // 改行までをタイトルとして設定
    NSMutableArray *lines = [NSMutableArray array];
    [templateMemo.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        [lines addObject:line];
        //        *stop = YES;
    }];
    
    // プレビュー内容を作成(2行目以降で作成)
    if (lines.count > 0) {
        NSMutableString *previewMemo = [NSMutableString new];
        for (int i = 0; i < lines.count; i++) {
            if ([previewMemo length] > 30) {
                break;
            }
            [previewMemo appendString:lines[i]];
        }
        cell.detailTextLabel.text = previewMemo.copy;
    } else {
        cell.detailTextLabel.text = @"(no preview)";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    [self updateCell:cell forTableView:tableView atIndexPath:indexPath];
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
        BOOL bResult = [templateDao remove:templateCache[indexPath.row]];
        if (bResult) {
            [templateCache removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate.editMemoViewController setTemplateMemo:templateCache[indexPath.row]];
}

@end
