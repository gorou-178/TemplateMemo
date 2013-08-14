//
//  UINavigationController+AllRotate.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/12.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "UINavigationController+AllRotate.h"

@implementation UINavigationController (AllRotate)

// iOS 6.* and over
- (BOOL)shouldAutorotate
{
    return YES;
}

// iOS 6.* and over
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

// iOS 5.* and below
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
