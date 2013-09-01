//
//  FontSizeSettingInfo.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "FontSizeSettingInfo.h"
#import "UIDeviceHelper.h"

@implementation FontSizeSettingInfo

- (id)init
{
    self = [super init];
    detailTitle = NSLocalizedString(@"settinginfo.fontsize.title", @"settinginfo title - fontsize");
    if ([UIDeviceHelper isJapaneseLanguage]) {
        key = @"setting.ja.font.size";
    }
    else {
        key = @"setting.en.font.size";
    }
    return self;
}

@end
