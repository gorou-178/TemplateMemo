//
//  MemoUndoRedoStore.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/06.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "MemoUndoRedoStore.h"
#import "NSMutableArray+StackAdditions.h"
#import "Memo.h"

@implementation MemoUndoRedoStore

- (id)init
{
    self = [super init];
    if (self) {
        undoRedoStore = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)push:(NSInteger)memoId bodyHistory:(NSString *)body;
{
    BOOL bResult = NO;
    
    if (body == nil) {
        return bResult;
    }
    
    NSMutableArray *undoRedoHistory = [undoRedoStore objectForKey:[NSNumber numberWithInt:memoId]];
    if (undoRedoHistory == nil) {
        undoRedoHistory = [[NSMutableArray alloc] init];
        [undoRedoStore setObject:undoRedoHistory forKey:[NSNumber numberWithInt:memoId]];
    }
    
    // スタックに積む
    [undoRedoHistory push:body];
    bResult = YES;
    
    return bResult;
}

- (NSString *)pop:(NSInteger)memoId
{
    NSMutableArray *undoRedoHistory = [undoRedoStore objectForKey:[NSNumber numberWithInt:memoId]];
    if (undoRedoHistory == nil) {
        // pushしていない場合はnilを返す
        return nil;
    }
    
    NSString *body = [undoRedoHistory pop];
    if (body == nil) {
        return nil;
    }
    
    return body;
}

- (BOOL)remove:(NSInteger)memoId
{
    BOOL bResult = NO;
    
    if ([[undoRedoStore allKeys] containsObject:[NSNumber numberWithInt:memoId]]) {
        [undoRedoStore removeObjectForKey:[NSNumber numberWithInt:memoId]];
        bResult = YES;
    }
    
    return bResult;
}

@end
