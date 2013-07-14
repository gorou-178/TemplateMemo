//
//  TMPopoverManager.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/05.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMPopoverManager : NSObject<UIPopoverControllerDelegate>

+ (TMPopoverManager *)sharedManager;
- (void)presentPopoverWithContentViewController:(UIViewController *)contentViewController fromRect:(CGRect)fromRect inView:(UIView *)inView permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections animated:(BOOL)animated;
- (void)dismissPopoverAnimated:(BOOL)animated;

@end
