//
//  TagLink.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/10.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tag;

@interface TagLink : NSObject

@property (strong, nonatomic) Tag *tag;
@property (strong, nonatomic) NSArray *memos;

@end
