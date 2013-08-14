//
//  TMLicenseViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/04.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMLicenseViewController.h"

@interface TMLicenseViewController ()

@end

@implementation TMLicenseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"appLicence_ja" ofType:@"html"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"ライセンス情報表示");
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
