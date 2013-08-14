//
//  KeyboardButtonView.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/12.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "KeyboardButtonView.h"

@implementation KeyboardButtonView

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"★initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
//        UINib *nib;
//        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//            nib = [UINib nibWithNibName:@"KeyboardButtonView_iPhone" bundle:[NSBundle mainBundle]];
//        } else {
//            nib = [UINib nibWithNibName:@"KeyboardButtonView_iPad" bundle:[NSBundle mainBundle]];
//        }
//        NSArray *array = [nib instantiateWithOwner:self options:nil];
//        [self addSubview:[array objectAtIndex:0]];
        
        NSString *nibName = NSStringFromClass([self class]);
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            nibName = [nibName stringByAppendingString:@"_iPhone"];
        } else {
            nibName = [nibName stringByAppendingString:@"_iPad"];
        }
        UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
        return [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib
{
    NSLog(@"★awakeFromNib");
//    [self.closeButton setImage:[UIImage imageNamed:@"arrow_sans_down_16"] forState:UIControlStateNormal];
//    [self.rightButton setImage:[UIImage imageNamed:@"arrow_sans_right_16"] forState:UIControlStateNormal];
//    [self.leftButton setImage:[UIImage imageNamed:@"arrow_sans_left_16"] forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
