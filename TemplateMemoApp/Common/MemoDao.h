//
//  MemoDao.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/06/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDBWrapper.h"
#import "Memo.h"
#import "Tag.h"
#import "TagLink.h"

@protocol MemoDao

// メモを全件取得
- (NSArray*)memos;

// タグに関連付けされたメモを取得
- (TagLink*)tagMemos:(Tag*)tag;

// メモの登録数取得
- (int)count;

// 自動インクリメントキーの現在の最大値を取得
- (int)maxRefCount;

// メモの追加
- (BOOL)add:(Memo*)memo;

// メモを更新
- (BOOL)update:(Memo*)memo;

// メモを削除
- (BOOL)remove:(Memo*)memo;
@end

@interface MemoDaoImpl : FMDBWrapper <MemoDao>
@end
