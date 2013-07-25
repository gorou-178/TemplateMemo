//
//  TemplateMemo.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingInfo.h"

@interface TemplateMemo : SettingData <NSCoding, NSMutableCopying>
@property (assign, nonatomic) NSInteger templateId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSDate* createDate;
@property (strong, nonatomic) NSDate* modifiedDate;
@property (assign, nonatomic) NSInteger deleteFlag;
@end
