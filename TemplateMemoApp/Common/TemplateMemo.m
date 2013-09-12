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
    mutableCopy.templateId = self.templateId;
    mutableCopy.name = [self.name mutableCopy];
    mutableCopy.body = [self.body mutableCopy];
    mutableCopy.createDate = self.createDate;
    mutableCopy.modifiedDate = self.modifiedDate;
    mutableCopy.deleteFlag = self.deleteFlag;
    return mutableCopy;
}

// シリアライズ時に呼ばれる
- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:[NSNumber numberWithInt:self.templateId] forKey:@"templateId"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.body forKey:@"body"];
    [coder encodeObject:[DateUtil dateToString:self.createDate atDateFormat:@"yyyy/MM/dd hh:mm:ss"] forKey:@"createDate"];
    [coder encodeObject:[DateUtil dateToString:self.modifiedDate atDateFormat:@"yyyy/MM/dd hh:mm:ss"] forKey:@"modifiedDate"];
    [coder encodeObject:[NSNumber numberWithInt:self.deleteFlag] forKey:@"deleteFlag"];
}

// デシリアライズ時に呼ばれる
- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.templateId = [[coder decodeObjectForKey:@"templateId"] intValue];
        self.name = [coder decodeObjectForKey:@"name"];
        self.body = [coder decodeObjectForKey:@"body"];
        self.createDate = [DateUtil dateStringToDate:[coder decodeObjectForKey:@"createDate"] atDateFormat:@"yyyy/MM/dd hh:mm:ss"];
        self.modifiedDate = [DateUtil dateStringToDate:[coder decodeObjectForKey:@"modifiedDate"] atDateFormat:@"yyyy/MM/dd hh:mm:ss"];
        self.deleteFlag = [[coder decodeObjectForKey:@"deleteFlag"] intValue];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (object == nil) {
        return NO;
    } else if (self == object) {
        // ポインタ比較で同じなら同じオブジェクト
        return YES;
    } else if (![self isMemberOfClass:[object class]]) {
        // 別クラス(または継承クラス)の場合はNO
        return NO;
    }
    // hashが等しい場合のみYES
    return ([self hash] == [object hash] ? YES : NO);
}

// TODO: Javaのhash値と同じ計算方法だけどいいかな？
- (NSUInteger)hash
{
    NSUInteger prime = 31;
    NSUInteger result = 1;
    result = prime * ( result + self.templateId );
    result = prime * ( result + ((self.name == nil) ? 0 : self.name.hash) );
    result = prime * ( result + ((self.body == nil) ? 0 : self.body.hash) );
    result = prime * ( result + ((self.createDate == nil) ? 0 : self.createDate.hash) );
    result = prime * ( result + ((self.modifiedDate == nil) ? 0 : self.modifiedDate.hash) );
    result = prime * ( result + self.deleteFlag );
    return result;
}

@end
