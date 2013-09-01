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
#import "TextViewHistory.h"

@implementation MemoUndoRedoStore

- (id)init
{
    self = [super init];
    if (self) {
        undoRedoStore = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)push:(NSInteger)memoId bodyHistory:(NSString *)body atRange:(NSRange)range;
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
    TextViewHistory *history = [[TextViewHistory alloc] init];
    history.text = [body mutableCopy];
    history.selectedRange = range;
    [undoRedoHistory push:history];
    bResult = YES;
    
    return bResult;
}

- (TextViewHistory *)pop:(NSInteger)memoId
{
    NSMutableArray *undoRedoHistory = [undoRedoStore objectForKey:[NSNumber numberWithInt:memoId]];
    if (undoRedoHistory == nil) {
        // pushしていない場合はnilを返す
        return nil;
    }
    
    TextViewHistory *history = [undoRedoHistory pop];
    if (history == nil) {
        return nil;
    }
    
    return history;
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
