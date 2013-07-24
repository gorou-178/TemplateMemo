//
//  SettingDataSource.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingInfo.h"

@interface SettingDataSource : NSObject <UITableViewDataSource,SettingUpdater,NSMutableCopying>
@property (strong, nonatomic) NSMutableArray *dataList;
@end
