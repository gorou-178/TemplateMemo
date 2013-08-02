//
//  UserDefaultsWrapper.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/23.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "UserDefaultsWrapper.h"

@implementation UserDefaultsWrapper

+ (void)save:(NSString *)key toObject:(id<NSCoding>)value
{
    NSData *binaryData = [NSKeyedArchiver archivedDataWithRootObject:value];
    [[NSUserDefaults standardUserDefaults] setValue:binaryData forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)loadToObject:(NSString *)key
{
    NSData *binaryData = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:binaryData];
}

@end
