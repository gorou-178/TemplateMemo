//
//  TagDao.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/10.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDBWrapper.h"

@class Tag;

@protocol TagDao
- (NSArray*)tags;
- (int)count;
- (BOOL)add:(Tag*)tag;
- (BOOL)update:(Tag*)tag;
- (BOOL)allUpdate:(NSArray*)tags;
- (BOOL)remove:(Tag*)tag;
@end

@interface TagDaoImpl : FMDBWrapper <TagDao>

@end
