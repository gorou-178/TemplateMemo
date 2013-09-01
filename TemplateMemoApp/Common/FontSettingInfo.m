//
//  FontSettingInfo.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "FontSettingInfo.h"
#import "UIDeviceHelper.h"

@implementation FontSettingInfo

- (id)init
{
    self = [super init];
    detailTitle = NSLocalizedString(@"settinginfo.font.title", @"settinginfo title - font");
    if ([UIDeviceHelper isJapaneseLanguage]) {
        key = @"setting.ja.font";
    }
    else {
        key = @"setting.en.font";
    }
    return self;
}

@end
