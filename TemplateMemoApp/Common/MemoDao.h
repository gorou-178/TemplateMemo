//
//  MemoDao.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/06/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDBWrapper.h"
#import "MemoDao.h"

@class TagLink;
@class Tag;
@class Memo;

@protocol MemoDao
- (NSArray*)memos;
- (TagLink*)tagMemos:(Tag*)tag;
- (int)count;
- (BOOL)add:(Memo*)memo;
- (BOOL)update:(Memo*)memo;
- (BOOL)remove:(Memo*)memo;
@end

@interface MemoDaoImpl : FMDBWrapper <MemoDao>
@end
