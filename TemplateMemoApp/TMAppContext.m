//
//  TMAppContext.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMAppContext.h"
#import "Common/MemoDao.h"

@implementation TMAppContext

// インスタンス取得(sharedManager)
+ (TMAppContext*)sharedManager {
    static TMAppContext* sharedSingleton;
    static dispatch_once_t onceToken;
    /* GCD(Grand Central Dispatch)という機能のひとつで、
     * dispatch_onceのブロック内での処理はアプリケーションのライフタイムで一度しか呼ばれないことが保証されている。
     * @synchronizedブロック同様、複数スレッドアクセスでもシングルトン状態を維持でき、より高速に処理される。
     */
    
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[TMAppContext alloc]
                           initSharedInstance];
    });
    return sharedSingleton;
}

// シングルトンイニシャライザ
- (id)initSharedInstance {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    return self;
}

// イニシャライザ(実行した場合エラーにする)
- (id)init {
    // 指定したセレクタを認識しないようにする
    // この場合、NSInvalidArgumentExceptionが発生するらしい
    // see: http://cocoaapi.hatenablog.com/entry/00020106/NSObject_doesNotRecognizeSelector_
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)deviceOrientationDidChange:(NSNotification*)notification {
//    UIDeviceOrientation orientation;
//    orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIDeviceOrientationUnknown) {
        NSLog(@"デバイス方向: 不明");
    }
    if(orientation == UIDeviceOrientationPortrait) {
        NSLog(@"デバイス方向: 縦(ホームボタン下)");
    }
    if(orientation == UIDeviceOrientationPortraitUpsideDown) {
        NSLog(@"デバイス方向: 縦(ホームボタン上)");
    }
    if(orientation == UIDeviceOrientationLandscapeLeft) {
        NSLog(@"デバイス方向: 横(ホームボタン右)");
    }
    if(orientation == UIDeviceOrientationLandscapeRight) {
        NSLog(@"デバイス方向: 横(ホームボタン左)");
    }
}

@end
