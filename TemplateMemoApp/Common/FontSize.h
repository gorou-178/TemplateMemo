//
//  FontSize.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingInfo.h"

@interface FontSize : SettingData <NSCoding, NSMutableCopying>
@property (assign, nonatomic) CGFloat size;
@end
