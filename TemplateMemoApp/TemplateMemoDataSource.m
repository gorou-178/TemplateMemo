//
//  TemplateMemoDataSource.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/25.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TemplateMemoDataSource.h"
#import "TemplateDao.h"

#import "TemplateMemoSettingInfo.h"
#import "UserDefaultsWrapper.h"

@implementation TemplateMemoDataSource

- (id)init
{
    self = [super init];
    
    NSLog(@"TemplateMemoDataSource: init");
    
    id<TemplateDao> templateDao = [TemplateDaoImpl new];
    self.dataList = [[templateDao templates] mutableCopy];
    
    TemplateMemo *emptyTemplate = [[TemplateMemo alloc] init];
    emptyTemplate.row = 0;
    emptyTemplate.labelText = @"なし";
    emptyTemplate.name = @"なし";
    emptyTemplate.body = @"";
    [self.dataList insertObject:emptyTemplate atIndex:0];
    
    return self;
}

- (void)updateCellData:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath tableViewCell:(UITableViewCell *)cell
{
    TemplateMemoSettingInfo *templateMemoSettingInfo = [[TemplateMemoSettingInfo alloc] init];
    TemplateMemo *selectedTemplate = [UserDefaultsWrapper loadToObject:templateMemoSettingInfo.key];
    
    TemplateMemo *templateMemo = self.dataList[indexPath.row];
    templateMemo.labelText = [templateMemo.name mutableCopy]; // ラベル名とテンプレ名を同じにする
    cell.textLabel.text = templateMemo.name;
    
    // 同じテンプレートの場合チェックマークをつける
    if ([templateMemo isEqual:selectedTemplate]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
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

@end
