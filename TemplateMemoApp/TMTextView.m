//
//  TMTextView.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/12.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMTextView.h"

@implementation TMTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan");
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    NSLog(@"touchesMoved");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"****touchesEnded");
    [super touchesEnded:touches withEvent:event];
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    [super addGestureRecognizer:gestureRecognizer];
    // Check the new gesture recognizer is the same kind as the one we want to implement
    // Note:
    // This works because `UITextTapRecognizer` is a subclass of `UITapGestureRecognizer`
    // and the text view has some `UITextTapRecognizer` added :)
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tgr = (UITapGestureRecognizer *)gestureRecognizer;
        if ([tgr numberOfTapsRequired] == 1 &&
            [tgr numberOfTouchesRequired] == 1) {
            // If found then add self to its targets/actions
            [tgr addTarget:self action:@selector(_handleOneFingerTap:)];
        }
    }
}
- (void)removeGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    // Check the new gesture recognizer is the same kind as the one we want to implement
    // Read above note
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *tgr = (UITapGestureRecognizer *)gestureRecognizer;
        if ([tgr numberOfTapsRequired] == 1 &&
            [tgr numberOfTouchesRequired] == 1) {
            // If found then remove self from its targets/actions
            [tgr removeTarget:self action:@selector(_handleOneFingerTap:)];
        }
    }
    [super removeGestureRecognizer:gestureRecognizer];
}

- (void)_handleOneFingerTap:(UITapGestureRecognizer *)tgr
{
    NSLog(@"_handleOneFingerTap");
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:tgr forKey:@"UITapGestureRecognizer"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TextViewOneFingerTapNotification" object:self userInfo:userInfo];
    // Or I could have handled the action here directly ...
}

//- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
//{
//    NSLog(@"touchesShouldBegin");
//    if (![self isEditable]) {
//        [self setEditable:YES];
//    }
//    return YES;
//}
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"touchesBegan");
//    [super touchesBegan:touches withEvent:event];
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    [super touchesBegan:touches withEvent:event];
//    NSLog(@"touchesMoved");
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    NSLog(@"****touchesEnded");
//    [self.nextResponder touchesEnded: touches withEvent:event];
//    NSLog(@"****touchesEnded");
//    [super touchesEnded:touches withEvent:event];
//    NSLog(@"****touchesEnded");
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
