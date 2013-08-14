//
//  NSMutableArray+StackAdditions.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/06.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "NSMutableArray+StackAdditions.h"

@implementation NSMutableArray (StackAdditions)
- (id)pop
{
    // nil if [self count] == 0
    id lastObject = [self lastObject];
    if (lastObject)
        [self removeLastObject];
    return lastObject;
}

- (void)push:(id)obj
{
    [self addObject: obj];
}
@end
