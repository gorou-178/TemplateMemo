//
//  TemplateMemoDataSource.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/25.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TemplateMemoDataSource.h"
#import "TemplateDao.h"

@implementation TemplateMemoDataSource

- (id)init
{
    self = [super init];
    
    NSLog(@"TemplateMemoDataSource: init");
    
    id<TemplateDao> templateDao = [TemplateDaoImpl new];
    self.dataList = [[templateDao templates] mutableCopy];
    
    return self;
}

- (void)updateCellData:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath tableViewCell:(UITableViewCell *)cell
{
    TemplateMemo *templateMemo = self.dataList[indexPath.row];
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

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *identifer = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
//    }
//    [self updateCellData:tableView cellForRowAtIndexPath:indexPath tableViewCell:cell];
//    return cell;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return self.dataList.count;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}
//
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return NO;
//}

@end
