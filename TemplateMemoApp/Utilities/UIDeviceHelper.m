//
//  UIDeviceHelper.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/28.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "UIDeviceHelper.h"

@implementation UIDeviceHelper

+ (BOOL)isPhone
{
    static BOOL isPhone;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isPhone = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    });
    return isPhone;
}

+ (BOOL)isRetina
{
    static BOOL isRetina;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isRetina = [UIScreen mainScreen].scale == 2.f;
    });
    return isRetina;
}

+ (BOOL)is568h
{
    static BOOL is568h;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        is568h = height == 568.f;
    });
    return is568h;
}

+ (BOOL)isJapaneseLanguage
{
    static BOOL isJapanese;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *currentLanguage = [languages objectAtIndex:0];
        isJapanese = [currentLanguage isEqualToString:@"ja"];
    });
    return isJapanese;
}

@end
