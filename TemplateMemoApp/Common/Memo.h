//
//  Memo.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/06/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Memo : NSObject
//{
//    NSNumber* memoid;
//    NSString* title;
//    NSMutableString* memo;
//    NSDate* createDate;
//    NSDate* modifiedDate;
//}
@property (nonatomic, assign) NSInteger memoid;
//@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* body;
@property (nonatomic, strong) NSDate* createDate;
@property (nonatomic, strong) NSDate* modifiedDate;
@property (nonatomic, assign) NSInteger deleteFlag;
@end
