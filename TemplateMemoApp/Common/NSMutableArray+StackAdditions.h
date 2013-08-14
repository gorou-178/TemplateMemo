//
//  NSMutableArray+StackAdditions.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/06.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (StackAdditions)
- (id)pop;
- (void)push:(id)obj;
@end
