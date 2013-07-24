//
//  SettingDetailTableViewController.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common/SettingInfo.h"

@interface SettingDetailTableViewController : UITableViewController <UITableViewDelegate>
{
    __strong SettingInfo *settingInfo_;
    __strong NSArray *dataList_;
}

- (void)setSettingInfo:(SettingInfo *)settingInfo withDataList:(NSArray *)dataList;

@end
