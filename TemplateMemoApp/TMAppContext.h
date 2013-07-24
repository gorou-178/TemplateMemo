//
//  TMAppContext.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common/MemoDao.h"

// TODO: シングルトンクラスをここで一元管理したい
@interface TMAppContext : NSObject

// インスタンス取得
+ (TMAppContext*)sharedManager;

// DB操作
//@property (atomic, strong, readonly) id<MemoDao> memoDao;

// アクティブキーボード
@property (atomic, strong) id activeTextField;

@end
