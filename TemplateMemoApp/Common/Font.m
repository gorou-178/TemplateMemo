//
//  Font.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "Font.h"
#import "FontSizeSettingInfo.h"
#import "FontSize.h"
#import "UserDefaultsWrapper.h"

@implementation Font

// mutableCopy時に呼ばれる
- (id)mutableCopyWithZone:(NSZone *)zone
{
    FontSizeSettingInfo *fontSizeSettingInfo = [[FontSizeSettingInfo alloc] init];
    FontSize *fontSize = [UserDefaultsWrapper loadToObject:fontSizeSettingInfo.key];
    
    Font *mutableCopy = [[[self class] allocWithZone:zone] init];
    mutableCopy.row = self.row;
    mutableCopy.labelText = [self.labelText mutableCopy];
    mutableCopy.name = [self.name mutableCopy];
    mutableCopy.uiFont = [UIFont fontWithName:mutableCopy.name size:fontSize.size];
    return mutableCopy;
}

// シリアライズ時に呼ばれる
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:[NSNumber numberWithInt:row] forKey:@"row"];
    [coder encodeObject:labelText forKey:@"labelText"];
    [coder encodeObject:self.name forKey:@"name"];
}

// デシリアライズ時に呼ばれる
- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self) {
        
        FontSizeSettingInfo *fontSizeSettingInfo = [[FontSizeSettingInfo alloc] init];
        FontSize *fontSize = [UserDefaultsWrapper loadToObject:fontSizeSettingInfo.key];
        
        row = [[coder decodeObjectForKey:@"row"] intValue];
        labelText = [coder decodeObjectForKey:@"labelText"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.uiFont = [UIFont fontWithName:self.name size:fontSize.size];
    }
    return self;
}

@end
