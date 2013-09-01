//
//  TextViewHistory.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/26.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextViewHistory : NSObject
@property (strong, nonatomic) NSString *text;
@property (assign, nonatomic) NSRange selectedRange;
@end
