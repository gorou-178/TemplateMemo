//
//  SettingInfo.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "SettingInfo.h"

@implementation SettingData
@synthesize row = row;
@synthesize labelText = labelText;

- (id)mutableCopyWithZone:(NSZone *)zone
{
    SettingData *mutableCopy = [[[self class] allocWithZone:zone] init];
    mutableCopy.row = self.row;
    mutableCopy.labelText = [self.labelText mutableCopy];
    return mutableCopy;
}

// シリアライズ時に呼ばれる
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[NSNumber numberWithInt:row] forKey:@"row"];
    [coder encodeObject:labelText forKey:@"labelText"];
}

// デシリアライズ時に呼ばれる
- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self) {
        row = [[coder decodeObjectForKey:@"row"] intValue];
        labelText = [coder decodeObjectForKey:@"labelText"];
    }
    return self;
}

@end

@implementation SettingInfo

@synthesize dataSource = dataSource;
@synthesize settingData = settingData;
@synthesize detailTitle = detailTitle;
@synthesize key = key;

- (id)init
{
    self = [super init];
    detailTitle = @"デフォルト";
    key = @"setting.default";
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    SettingInfo *mutableCopy = [[[self class] allocWithZone:zone] init];
    mutableCopy.dataSource = self.dataSource;
    mutableCopy.settingData = [self.settingData mutableCopy];
    mutableCopy.detailTitle = [self.detailTitle mutableCopy];
    mutableCopy.key = [self.key mutableCopy];
    return mutableCopy;
}

@end
