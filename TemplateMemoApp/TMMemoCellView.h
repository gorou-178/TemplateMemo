//
//  TMMemoCellView.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/17.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMMemoCellView : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *tmTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tmDetailTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *tmRightTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *tmImageView;

@end
