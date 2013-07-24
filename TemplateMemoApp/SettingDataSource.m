//
//  SettingDataSource.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "SettingDataSource.h"
#import "UserDefaultsWrapper.h"

@implementation SettingDataSource

- (BOOL)update:(SettingInfo *)settingInfo
{
    NSLog(@"SettingDataSource: update");
    [UserDefaultsWrapper save:settingInfo.key toObject:settingInfo.settingData];
    return YES;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    SettingDataSource *mutableCopy = [[[self class] allocWithZone:zone] init];
    mutableCopy.dataList = [self.dataList mutableCopy];
    return mutableCopy;
}

@end
