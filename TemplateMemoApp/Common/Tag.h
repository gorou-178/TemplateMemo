//
//  Tag.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/10.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tag : NSObject
@property (assign, nonatomic) NSInteger tagId;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) NSInteger posision;
@property (strong, nonatomic) NSDate* createDate;
@property (strong, nonatomic) NSDate* modifiedDate;
@property (assign, nonatomic) NSInteger deleteFlag;
@end
