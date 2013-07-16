//
//  TagDao.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/10.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDBWrapper.h"

@class Memo;
@class Tag;

@protocol TagDao
// タグ全件取得
- (NSArray*)tags;

// メモに関連付けされたタグを全件取得
- (NSArray*)tagForMemo:(Memo*)memo;

// 登録されたタグの件数を取得
- (int)count;

// タグに関連付けされているメモの件数を取得
- (int)countOfMemo:(Tag*)tag;

// タグを追加
- (BOOL)add:(Tag*)tag;

// タグリンクを追加
- (BOOL)addTagLink:(Memo*)memo forLinkTag:(Tag*)tag;

// タグを更新
- (BOOL)update:(Tag*)tag;

// タグを一括更新
- (BOOL)allUpdate:(NSArray*)tags;

// タグを削除
- (BOOL)remove:(Tag*)tag;

// タグリンクを削除
- (BOOL)removeTagLink:(Memo*)memo forLinkTag:(Tag*)tag;
@end

// タグのFMDB実装
@interface TagDaoImpl : FMDBWrapper <TagDao>

@end
