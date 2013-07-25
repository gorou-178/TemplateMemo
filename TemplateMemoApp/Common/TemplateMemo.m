//
//  TemplateMemo.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TemplateMemo.h"

@implementation TemplateMemo

// mutableCopy時に呼ばれる
- (id)mutableCopyWithZone:(NSZone *)zone
{
    TemplateMemo *mutableCopy = [[[self class] allocWithZone:zone] init];
    mutableCopy.row = self.row;
    mutableCopy.labelText = [self.labelText mutableCopy];
    mutableCopy.name = [self.name mutableCopy];
    mutableCopy.body = [self.body mutableCopy];
    mutableCopy.createDate = self.createDate;
    mutableCopy.modifiedDate = self.modifiedDate;
    mutableCopy.deleteFlag = self.deleteFlag;
    return mutableCopy;
}

// シリアライズ時に呼ばれる
- (void)encodeWithCoder:(NSCoder *)coder {
    //    [coder encodeObject:indexPath];
    [coder encodeObject:[NSNumber numberWithInt:row] forKey:@"row"];
    [coder encodeObject:labelText forKey:@"labelText"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.body forKey:@"body"];
    [coder encodeObject:self.createDate forKey:@"createDate"];
    [coder encodeObject:self.modifiedDate forKey:@"modifiedDate"];
    [coder encodeObject:[NSNumber numberWithInt:self.deleteFlag] forKey:@"deleteFlag"];
}

// デシリアライズ時に呼ばれる
- (id)initWithCoder:(NSCoder *)coder {
    self = [self init];
    if (self) {
        row = [[coder decodeObjectForKey:@"row"] intValue];
        labelText = [coder decodeObjectForKey:@"labelText"];
        self.name = [coder decodeObjectForKey:@"name"];
        self.body = [coder decodeObjectForKey:@"body"];
        self.createDate = [[coder decodeObjectForKey:@"createDate"] date];
        self.modifiedDate = [[coder decodeObjectForKey:@"modifiedDate"] date];
        self.deleteFlag = [[coder decodeObjectForKey:@"deleteFlag"] intValue];
    }
    return self;
}

@end
