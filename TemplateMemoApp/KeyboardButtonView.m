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
    self = [super initWithFrame:frame];
    if (self) {        
        DDLogVerbose(@"キーボードビュー読み込み");
        NSString *nibName = NSStringFromClass([self class]);
        UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
        return [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib
{
    DDLogVerbose(@"キーボードビュー表示");
    [super awakeFromNib];
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
