//
//  MemoUndoRedoStore.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/06.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Memo;
@class TextViewHistory;

@interface MemoUndoRedoStore : NSObject
{
    NSMutableDictionary *undoRedoStore;
}
- (BOOL)push:(NSInteger)memoId bodyHistory:(NSString *)body atRange:(NSRange)range;
- (TextViewHistory *)pop:(NSInteger)memoId;
- (BOOL)remove:(NSInteger)memoId;
@end
