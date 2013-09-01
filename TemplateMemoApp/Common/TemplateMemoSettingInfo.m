//
//  TemplateMemoSettingInfo.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/25.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TemplateMemoSettingInfo.h"
#import "UIDeviceHelper.h"

@implementation TemplateMemoSettingInfo

- (id)init
{
    self = [super init];
    detailTitle = NSLocalizedString(@"settinginfo.defaulttemplate.title", @"settinginfo title - default template");
    if ([UIDeviceHelper isJapaneseLanguage]) {
        key = @"setting.ja.templateMemo";
    }
    else {
        key = @"setting.en.templateMemo";
    }
    
    return self;
}

@end
