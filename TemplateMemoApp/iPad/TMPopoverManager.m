//
//  TMPopoverManager.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMPopoverManager.h"

@implementation TMPopoverManager{
    __strong UIPopoverController *_popoverController;
}

#pragma mark - singleton implementation

// インスタンス取得
+ (TMPopoverManager*)sharedManager {
    static TMPopoverManager* sharedSingleton;
    static dispatch_once_t onceToken;
    /* GCD(Grand Central Dispatch)という機能のひとつで、
     * dispatch_onceのブロック内での処理はアプリケーションのライフタイムで一度しか呼ばれないことが保証されている。
     * @synchronizedブロック同様、複数スレッドアクセスでもシングルトン状態を維持でき、より高速に処理される。
     */
    dispatch_once(&onceToken, ^{
        sharedSingleton = [[TMPopoverManager alloc]
                           initSharedInstance];
    });
    return sharedSingleton;
}

// シングルトンイニシャライザ
- (id)initSharedInstance {
    self = [super init];
    if (self) {
        // 初期化処理
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

#pragma mark - popover

- (void)presentPopoverWithContentViewController:(UIViewController *)contentViewController fromRect:(CGRect)fromRect inView:(UIView *)inView permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections animated:(BOOL)animated
{
    if (_popoverController) {
        [_popoverController dismissPopoverAnimated:NO];
    }
    
    _popoverController = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
    _popoverController.delegate = self;
    [_popoverController presentPopoverFromRect:fromRect inView:inView permittedArrowDirections:permittedArrowDirections animated:animated];
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
    if (_popoverController) {
        [_popoverController dismissPopoverAnimated:YES];
        _popoverController = nil;
        
        NSLog(@"AppContext released popoverController.");
    }
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popoverController = nil;
    
    NSLog(@"AppContext released popoverController.");
}

@end
