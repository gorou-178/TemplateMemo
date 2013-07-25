//
//  TMTemplateMemoTableViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/25.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

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

- (IBAction)insertTemplateMemo:(id)sender {
    
    TemplateMemo *templateMemo = [[TemplateMemo alloc] init];
    templateMemo.name = @"default Template";
    templateMemo.body = @"default...";
    BOOL bResult = [templateDao add:templateMemo];
    if (bResult) {
        // idを設定して、キャッシュの一番上に追加
        int refCount = [templateDao maxRefCount];
        templateMemo.templateId = refCount;
        [templateCache insertObject:templateMemo atIndex:0];
        
        // セルを一番上に追加
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        // 追加したセルを選択 & 表示(トップにスクロールさせる)
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
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
        }
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
