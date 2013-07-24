//
//  UserDefaultsWrapper.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/23.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsWrapper : NSObject 
+ (void)save:(NSString *)key toObject:(id<NSCoding>)value;
+ (id)loadToObject:(NSString *)key;
@end
