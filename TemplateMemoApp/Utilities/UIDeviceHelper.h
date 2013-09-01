//
//  UIDeviceHelper.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/28.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDeviceHelper : NSObject

// iPhoneか
+ (BOOL)isPhone;
// Retinaディスプレイか
+ (BOOL)isRetina;
// 4inch(iPhone5)か
+ (BOOL)is568h;
// 言語環境が日本語か
+ (BOOL)isJapaneseLanguage;

@end
