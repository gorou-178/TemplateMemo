//
//  DetailViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/06/02.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    if (self.detailItem) {
        self.detailTextView.text = self.detailItem.body;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    
    // UI作成
    self.addMemoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onPushDone:)];
    self.editDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onPushDone:)];
    self.navigationItem.rightBarButtonItem = self.addMemoButton;
    
    self.memoDao = [MemoDaoImpl new];
    
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text view

- (void)registerForKeyboardNotifications
{
    // キーボードが表示される時に通知が来る
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    // キーボードが閉じる時に通知が来る
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // キーボード表示 & キーボード切り替え後に通知が来る
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    // キーボードの切り替え時に通知が来る
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrameNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

- (void)keyboardWillChangeFrameNotification:(NSNotification*)aNotification
{
    NSLog(@"call keyboardWillChangeFrameNotification");
}

- (void)keyboardWillShowNotification:(NSNotification*)aNotification
{
    NSLog(@"call keyboardWillShowNotification");
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    self.editMode = YES;
    NSLog(@"call keyboardWasShown => editMode: %d", self.editMode);
    // キーボードを開いたタイミングでボタンを「編集完了ボタン」に変更
    self.navigationItem.rightBarButtonItem = self.editDoneButton;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.editMode = NO;
    NSLog(@"call keyboardWillBeHidden => editMode: %d", self.editMode);
    // キーボードが閉じたタイミングでボタンを「メモ追加ボタン」に変更
    self.navigationItem.rightBarButtonItem = self.addMemoButton;
    
    // 選択したMemoを保存
    if (_detailItem) {
        _detailItem.body = self.detailTextView.text;
        [self.memoDao update:_detailItem];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"call textViewShouldBeginEditing");
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    NSLog(@"call textViewShouldEndEditing");
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"call textViewDidBeginEditing");
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"call textViewDidEndEditing");
}

- (IBAction)onPushDone:(id)sender {
    // 意図的にキーボードを閉じる場合
    [self.detailTextView resignFirstResponder];
}


#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"test1", @"");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
