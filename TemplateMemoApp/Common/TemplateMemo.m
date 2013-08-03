//
//  TemplateMemo.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TemplateMemo.h"
#import "DateUtil.h"

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
    [coder encodeObject:[DateUtil dateToString:self.createDate atDateFormat:@"yyyy/MM/dd hh:mm:ss"] forKey:@"createDate"];
    [coder encodeObject:[DateUtil dateToString:self.modifiedDate atDateFormat:@"yyyy/MM/dd hh:mm:ss"] forKey:@"modifiedDate"];
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
        self.createDate = [DateUtil dateStringToDate:[coder decodeObjectForKey:@"createDate"] atDateFormat:@"yyyy/MM/dd hh:mm:ss"];
        self.modifiedDate = [DateUtil dateStringToDate:[coder decodeObjectForKey:@"modifiedDate"] atDateFormat:@"yyyy/MM/dd hh:mm:ss"];
        self.deleteFlag = [[coder decodeObjectForKey:@"deleteFlag"] intValue];
    }
    return self;
}

@end
