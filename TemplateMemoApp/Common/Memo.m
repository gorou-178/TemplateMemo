//
//  Memo.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/06/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "Memo.h"

//@interface Memo ()
//
//@end

@implementation Memo : NSObject

- (id)init
{
    self = [super init];
    //NSLog(@"Memo init");
    return self;
}

- (void)dealloc
{
    //NSLog(@"Memo dealloc");
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
    int result = 1;
    result = prime * result + ((self.body == nil) ? 0 : self.body.hash);
    result = prime * result + ((self.createDate == nil) ? 0 : self.createDate.hash);
    result = prime * result + ((self.modifiedDate == nil) ? 0 : self.modifiedDate.hash);
    result = prime * result + self.deleteFlag;
    return result;
}

@end
