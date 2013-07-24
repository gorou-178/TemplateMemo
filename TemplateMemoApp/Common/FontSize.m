//
//  FontSize.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "FontSize.h"

@implementation FontSize

// mutableCopy時に呼ばれる
- (id)mutableCopyWithZone:(NSZone *)zone
{
    FontSize *mutableCopy = [[[self class] allocWithZone:zone] init];
    mutableCopy.row = self.row;
    mutableCopy.labelText = [self.labelText mutableCopy];
    mutableCopy.size = self.size;
    return mutableCopy;
}

// シリアライズ時に呼ばれる
- (void)encodeWithCoder:(NSCoder *)coder {
//    [coder encodeObject:indexPath];
    [coder encodeObject:[NSNumber numberWithInt:row] forKey:@"row"];
    [coder encodeObject:labelText forKey:@"labelText"];
    [coder encodeObject:[NSNumber numberWithInt:self.size] forKey:@"size"];
}

// デシリアライズ時に呼ばれる
- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self) {
        row = [[coder decodeObjectForKey:@"row"] intValue];
        labelText = [coder decodeObjectForKey:@"labelText"];
        self.size = [[coder decodeObjectForKey:@"size"] intValue];
    }
    return self;
}

@end
