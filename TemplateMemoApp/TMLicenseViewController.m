//
//  TMLicenseViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/04.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMLicenseViewController.h"
#import "UIDeviceHelper.h"

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
    NSString *licenceFileName;
    if ([UIDeviceHelper isJapaneseLanguage]) {
        licenceFileName = @"appLicence_ja";
    } else {
        licenceFileName = @"appLicence_en";
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:licenceFileName ofType:@"html"];
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

- (IBAction)onPushCloseButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
