//
//  TMEditMemoViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/26.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "AppDelegate.h"
#import "TMEditMemoViewController.h"
#import "MemoDao.h"
#import "TagDao.h"
#import "TemplateDao.h"
#import "Font.h"
#import "FontSize.h"
#import "TemplateMemo.h"
#import "FontSettingInfo.h"
#import "FontSizeSettingInfo.h"
#import "UserDefaultsWrapper.h"

#import "DateUtil.h"

#import "TMTagSettingTableViewController.h"
#import "TMMemoInfoTableViewController.h"

#import "MemoUndoRedoStore.h"
#import "KeyboardButtonView.h"

#import "TMInsertTemplateViewController.h"
#import "TextViewHistory.h"

#import "UIDeviceHelper.h"

#define DISP_AD_BOTTOM

@interface TMEditMemoViewController ()
{
    id<MemoDao> memoDao;
    id<TagDao> tagDao;
    id<TemplateDao> templateDao;
    UITableViewController *activeSideView;
    BOOL _registered;
    CGSize originalSize;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation TMEditMemoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.editMemoViewController = self;
    
    tagDao = [[TagDaoImpl alloc] initWithFMDBWrapper:appDelegate.fmdb];
    memoDao = [[MemoDaoImpl alloc] initWithFMDBWrapper:appDelegate.fmdb];
    templateDao = [[TemplateDaoImpl alloc] initWithFMDBWrapper:appDelegate.fmdb];
    _editTarget = TMEditTargetMemo;
    
    fastViewFlag = YES;
	bannerIsVisible = NO;
    
    _undoStore = [[MemoUndoRedoStore alloc] init];
    _redoStore = [[MemoUndoRedoStore alloc] init];
    
    [self setAddMemoButton];
}

// シングルタップ時の動作
- (void)handleSingleTap
{
    // 編集可能に変更し、編集状態にする
    if (![self.bodyTextView isEditable]) {
        [self.bodyTextView setEditable:YES];
    }
    [self.bodyTextView becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    originalSize = CGSizeZero;
    
    // 編集不可状態のTextViewにシングルタップジェスチャーを追加
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    
    //modify this number to recognizer number of tap
    [singleTap setNumberOfTapsRequired:1];
    [self.bodyTextView addGestureRecognizer:singleTap];
    
    CGRect insetSize;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        adView = [[ADBannerView alloc] init];
        adView.delegate = self;
        adView.autoresizesSubviews = YES;
        adView.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin;
        adView.alpha = 0.0;
        insetSize = adView.bounds;
        [self.view addSubview:adView];
    } else {
        insetSize = CGRectMake(0, 0, 0, 50);
    }
    
    // UITableView のコンテンツに余白を付ける
    self.bodyTextView.contentInset = UIEdgeInsetsMake(0.f, 0.f, insetSize.size.height, 0.f);
    // UITableView のスクロール可能範囲に余白を付ける
    self.bodyTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0.f, 0.f, insetSize.size.height, 0.f);
    
    // 日本語のときは英字自動大文字入力と自動補完をオフにする
    if ([UIDeviceHelper isJapaneseLanguage]) {
        // 英字の自動大文字入力をオフ
        self.bodyTextView.autocapitalizationType = UITextAutocapitalizationTypeNone;
        // 英字の自動補完をオフ
        self.bodyTextView.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    // キーボードアクセサリビュー作成
    CGRect bounds = self.view.bounds;
    KeyboardButtonView *accessoryView = [[KeyboardButtonView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width,35)];
    [accessoryView.closeButton addTarget:self action:@selector(onPushCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [accessoryView.rightButton addTarget:self action:@selector(onPushRightButton:) forControlEvents:UIControlEventTouchUpInside];
    [accessoryView.leftButton addTarget:self action:@selector(onPushLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    [accessoryView.templateButton addTarget:self action:@selector(onPushTemplateButton:) forControlEvents:UIControlEventTouchUpInside];
    [accessoryView.undoButton addTarget:self action:@selector(onPushUndoButton:) forControlEvents:UIControlEventTouchUpInside];
    [accessoryView.redoButton addTarget:self action:@selector(onPushRedoButton:) forControlEvents:UIControlEventTouchUpInside];
    [accessoryView setHidden:YES];
    
    self.bodyTextView.inputAccessoryView = accessoryView;
    
    self.bodyTextView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setActiveSideView:(UITableViewController*)tableViewController
{
    activeSideView = tableViewController;
    if (self.navigationItem.leftBarButtonItem != nil) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        if ([activeSideView.title isEqualToString:appDelegate.tagTableViewController.title]) {
            self.navigationItem.leftBarButtonItem.title = appDelegate.tagTableViewController.navigationItem.title;
        } else {
            self.navigationItem.leftBarButtonItem.title = appDelegate.memoTableViewController.navigationItem.title;
        }
    }
}

- (void)insertTemplate:(TemplateMemo*)templateMemo atRange:(NSRange)range
{
    if (templateMemo) {
        
        // てんぷれ挿入をundoに積む
        [_undoStore push:_detailItem.memoid bodyHistory:_bodyTextView.text atRange:_bodyTextView.selectedRange];
        
        NSMutableString *str = [_bodyTextView.text mutableCopy];
        NSMutableString *body = [templateMemo.body mutableCopy];
        
        NSRegularExpression *dateFormatRegex = [NSRegularExpression regularExpressionWithPattern:@"\\$\\{date(?:\\(([^\r\n]*?)\\))\\}" options:0 error:nil];
        NSRegularExpression *dateRegex = [NSRegularExpression regularExpressionWithPattern:@"\\$\\{date\\}" options:0 error:nil];
        NSMutableArray *matchStrings = [[NSMutableArray alloc] init];
        NSDate *currentDate = [NSDate date];
        
        /*  
            グループの個数が正規表現で変化しても、最大グループ数でnumberOfRangesで返ってくるため、正規表現を分けた。
            また、マッチした場合、元文字列のマッチした「範囲」が返ってくる。
            逐次置換をすると元文字列の範囲が変わってしまいエラーになるため、一旦マッチした文字列を取り出している。
        */
        
        // フォーマットありパターン
        id collectDateFormatWord = ^(NSTextCheckingResult *match, NSMatchingFlags flag, BOOL *stop){
            NSString *format = [body substringWithRange:[match rangeAtIndex:1]];
            NSLog(@"ranges = %d, flag = %d, word = %@, format = %@", match.numberOfRanges, flag, [body substringWithRange:[match rangeAtIndex:0]], format);
            NSString *strDate = [DateUtil dateToString:currentDate atDateFormat:format];
            NSDictionary *matchData = @{@"word": [body substringWithRange:[match rangeAtIndex:0]], @"strDate": strDate};
            [matchStrings addObject:matchData];
        };
        
        // フォーマットなしパターン
        id collectDateWord = ^(NSTextCheckingResult *match, NSMatchingFlags flag, BOOL *stop){
            NSString *format = @"yyyy/MM/dd";
            NSLog(@"ranges = %d, flag = %d, word = %@, format = %@", match.numberOfRanges, flag, [body substringWithRange:[match rangeAtIndex:0]], format);
            NSString *strDate = [DateUtil dateToString:currentDate atDateFormat:format];
            NSDictionary *matchData = @{@"word": [body substringWithRange:[match rangeAtIndex:0]], @"strDate": strDate};
            [matchStrings addObject:matchData];
        };
        
        [dateFormatRegex enumerateMatchesInString:body options:0 range:NSMakeRange(0, body.length) usingBlock:collectDateFormatWord];
        [dateRegex enumerateMatchesInString:body options:0 range:NSMakeRange(0, body.length) usingBlock:collectDateWord];

        // 置換
        for (NSDictionary *matchData in matchStrings) {
            [body replaceCharactersInRange:[body rangeOfString:[matchData objectForKey:@"word"]] withString:[matchData objectForKey:@"strDate"]];
        }
        
        // テキストを設定するとスクロールしてしまうのでスクロールしないようにする
        [str insertString:body atIndex:range.location];
        _bodyTextView.scrollEnabled = NO;
        [_bodyTextView setText:str];
        _bodyTextView.scrollEnabled = YES;
        
        // 挿入したテンプレートの最後にキャレットを移動
        range.location += [templateMemo.body length];
        _bodyTextView.selectedRange = range;
        
        [self saveMemo];
    }
    
    // そのキャレットが表示される位置までスクロール
    [_bodyTextView scrollRangeToVisible:range];
    
    [_bodyTextView becomeFirstResponder];
}

- (Memo *)currentMemo
{
    return _detailItem;
}

- (TemplateMemo *)currentTemplateMemo
{
    return _templateMemo;
}

#pragma mark - Custom UI

- (IBAction)onPushTrashButton:(id)sender {
    
    NSString *title;
    NSString *message;
    if (self.editTarget == TMEditTargetMemo) {
        title = NSLocalizedString(@"editmemoview.memo.trash.title", @"edit memo view trash memo confirm dialog title");
        message = NSLocalizedString(@"editmemoview.memo.trash.message", @"edit memo view trash memo confirm dialog message");
    }
    else if (self.editTarget == TMEditTargetTemplate) {
        title = NSLocalizedString(@"editmemoview.temple.trash.title", @"edit memo view trash temple confirm dialog title");
        message = NSLocalizedString(@"editmemoview.temple.trash.message", @"edit memo view trash temple confirm dialog message");
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"editmemoview.trash.confirm.cancel", @"edit memo view trash confirm dialog cancel button")
                                          otherButtonTitles:NSLocalizedString(@"editmemoview.trash.confirm.ok", @"edit memo view trash confirm dialog ok button"), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        if (self.editTarget == TMEditTargetMemo) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                TMMemoTableViewController *memoTableView = appDelegate.memoTableViewController;
                [memoTableView removeMemo:_detailItem];
            });
        }
        else if (self.editTarget == TMEditTargetTemplate) {
            dispatch_async(dispatch_get_main_queue(), ^(void){
                TMTemplateMemoTableViewController *templateTableView = appDelegate.templateMemoViewController;
                [templateTableView removeTemplate:_templateMemo];
            });
        }
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self.bodyTextView setHidden:YES];
            [self.memoInfoButton setEnabled:NO];
            [self.tagSettingButton setEnabled:NO];
            [self.addMemoButton setEnabled:NO];
            self.navigationItem.title = NSLocalizedString(@"editmemoview.navigation.title", @"edit memo view title");
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        [self.trashButton setEnabled:NO];
        
//        dispatch_async(dispatch_get_main_queue(), ^(void){
//            [appDelegate.memoTableViewController.tableView reloadData];
//            [appDelegate.tagTableViewController.tableView reloadData];
//            [appDelegate.templateMemoViewController.tableView reloadData];
//        });        
    }
}

- (void)setAddMemoButton
{
    // キーボードが閉じたタイミングでボタンを「メモ追加ボタン」に変更(iPadのみ)
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (self.addMemoButton == nil) {
            self.addMemoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onPushAdd:)];
            [self.addMemoButton setEnabled:NO];
        }
        [self.navigationItem setRightBarButtonItem:self.addMemoButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

- (void)setEditDoneButton
{
    if (self.editDoneButton == nil) {
        self.editDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onPushDone:)];
    }
    [self.navigationItem setRightBarButtonItem:self.editDoneButton animated:YES];
}

#pragma mark - Managing the tmEditViewControler

- (void)setDetailItem:(Memo *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        _editTarget = TMEditTargetMemo;
        
        KeyboardButtonView *accessoryView = (KeyboardButtonView*)self.inputAccessoryView;
        [accessoryView.templateButton setEnabled:YES];
        
        [self.tagSettingButton setEnabled:YES];
        [self.addMemoButton setEnabled:YES];
        [self.trashButton setEnabled:YES];
        
        // メモ選択で表示する
        if ([self.bodyTextView isHidden]) {
            [self.bodyTextView setHidden:NO];
            [self.memoInfoButton setEnabled:YES];
        }
        
        // Update the view.
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self configureView];
        }
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)setTemplateMemo:(TemplateMemo *)templateMemo
{
    if (_templateMemo != templateMemo ) {
        _editTarget = TMEditTargetTemplate;
        _templateMemo = templateMemo;
        
        KeyboardButtonView *accessoryView = (KeyboardButtonView*)self.inputAccessoryView;
        [accessoryView.templateButton setEnabled:NO];
        
        [self.tagSettingButton setEnabled:NO];
        [self.addMemoButton setEnabled:NO];
        [self.trashButton setEnabled:YES];
        
        // メモ選択で表示する
        if ([self.bodyTextView isHidden]) {
            [self.bodyTextView setHidden:NO];
            [self.memoInfoButton setEnabled:YES];
        }
        
        // Update the view.
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [self configureView];
        }
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    FontSettingInfo *fontSettingInfo = [[FontSettingInfo alloc] init];
    Font *font = [UserDefaultsWrapper loadToObject:fontSettingInfo.key];
    self.bodyTextView.font = font.uiFont;
    
    if (_editTarget == TMEditTargetMemo) {
        
        [self.bodyTextView setText:[_detailItem.body mutableCopy]];
        
        // 改行までをタイトルとして設定
        NSMutableArray *lines = [NSMutableArray array];
        [_detailItem.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            [lines addObject:line];
            *stop = YES;
        }];
        
        if (lines.count <= 0) {
            self.navigationItem.title = NSLocalizedString(@"editmemoview.navigation.title.empty", @"edit memo view empty title");
            return;
        }
        
        // タイトルは本文の一行目
        self.navigationItem.title = [lines objectAtIndex:0];
        
    } else if (_editTarget == TMEditTargetTemplate) {
        self.navigationItem.title = [_templateMemo.name mutableCopy];
        [self.bodyTextView setText:[_templateMemo.body mutableCopy]];
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    // アクティブでない場合何もしない
    if(![_bodyTextView isFirstResponder])
    {
        DDLogCVerbose(@"body no active");
        return;
    }
    
    [self.bodyTextView.inputAccessoryView setHidden:NO];
    
    self.editMode = YES;
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGRect frame = _bodyTextView.frame;
    if(CGSizeEqualToSize(originalSize, CGSizeZero))
    {
        originalSize = frame.size;
    }
    
    CGPoint pt = CGPointMake(0, CGRectGetMinY(keyboardRect));
    pt = [_bodyScrollView convertPoint:pt fromView:self.view];
    
    CGSize size = CGSizeZero;
    if( pt.y > _bodyTextView.frame.origin.y )
    {
        size = CGSizeMake(_bodyTextView.frame.size.width, pt.y - _bodyTextView.frame.origin.y);
        frame.size = size;
        _bodyTextView.frame = frame;
        
        [UIView commitAnimations];
    }
}

- (void)keybaordWillHide:(NSNotification*)aNotification
{
    // アクティブでない場合何もしない
    if(![_bodyTextView isFirstResponder])
    {
        DDLogCVerbose(@"body no active");
        return;
    }
    
    [self.bodyTextView.inputAccessoryView setHidden:YES];
    
    self.editMode = NO;
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGRect frame = _bodyTextView.frame;
    frame.size = originalSize;
    _bodyTextView.frame = frame;
    
    originalSize = CGSizeZero;
    
    [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"メモ表示");
    [super viewWillAppear:animated];
    
    [self registKeyBoardNotification];
    
    [self changeRotateForm];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self configureView];
    }
    
    // iPadにてアプリ起動時にランドスケープの場合、ボタン表示位置が左寄りになるのを防ぐために必要
    if(fastViewFlag == YES){
        fastViewFlag = NO;
        [self changeRotateForm];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self unRegistKeyBoardNotification];
}

- (void)applicationWillResignActive:(NSNotificationCenter *)center
{
    // キーボード表示と同時に他のアプリやOSの通知ダイアログが表示された場合の対処
    DDLogInfo(@"メモ表示: 非アクティブ");
    [self onPushDone:self.editDoneButton];
}

- (void)registKeyBoardNotification
{
    // Register for notifiactions
    if (!_registered) {
        NSNotificationCenter *center;
        center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(keyboardWillShow:)
                       name:UIKeyboardWillShowNotification
                     object:nil];
        
        [center addObserver:self
                   selector:@selector(keybaordWillHide:)
                       name:UIKeyboardWillHideNotification
                     object:nil];
        
        // キーボード表示中に何かの通知が来た場合の対処
        [center addObserver:self
                   selector:@selector(applicationWillResignActive:)
                       name:UIApplicationWillResignActiveNotification
                     object:nil];
        _registered = YES;
    }
}

- (void)unRegistKeyBoardNotification
{
    // Unregister from notification center
    if (_registered) {
        NSNotificationCenter *center;
        center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self
                          name:UIKeyboardWillShowNotification
                        object:nil];
        
        [center removeObserver:self
                          name:UIKeyboardWillHideNotification
                        object:nil];
        
        [center removeObserver:self
                          name:UIApplicationWillResignActiveNotification
                        object:nil];
        _registered = NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
//    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
//    NSLog(@"'%@' text:%@ , loc:%d , len:%d → %@",textView.text , text , range.location , range.length , newString);
    // 変換完了であればUndoに積む
    if ([_bodyTextView markedTextRange] == nil) {
        [_undoStore push:_detailItem.memoid bodyHistory:textView.text atRange:textView.selectedRange];
    }
    
    return YES;
}

//- (void)updateTextRange:(UITextRange *)textRange currentText:(NSString *)currentText
//{
//    [[_bodyTextView.undoManager prepareWithInvocationTarget:self] updateTextRange:_bodyTextView.selectedTextRange currentText:_bodyTextView.text];
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.bodyTextView.scrollEnabled = NO;
//        [self.bodyTextView setText:currentText];
////        [self.bodyTextView replaceRange:textRange withText:currentText];
//        self.bodyTextView.scrollEnabled = YES;
//        self.bodyTextView.selectedTextRange = textRange;
//    });
//}

#pragma mark - Custom UI Selectors

- (void)onPushAdd:(id)sender {
    // メモコントローラのメモ追加処理をコール
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (_editTarget == TMEditTargetMemo) {
        DDLogInfo(@"メモ表示: メモ新規作成");
        [appDelegate.memoTableViewController onPushAddButton:sender];
    } else if (_editTarget == TMEditTargetTemplate) {
        DDLogInfo(@"メモ表示: テンプレート新規作成");
        [appDelegate.templateMemoViewController insertTemplateMemo:sender];
    }
}

- (void)onPushDone:(id)sender {
    // 意図的にキーボードを閉じる場合
    DDLogInfo(@"メモ表示: 編集完了");
    [self.bodyTextView resignFirstResponder];
    [self.bodyTextView setEditable:NO];
}

- (void)onPushCloseButton:(id)sender
{
    DDLogInfo(@"メモ表示: キーボードを閉じる");
    [self onPushDone:sender];
}

- (void)onPushRightButton:(id)sender
{
    UITextRange *currentRange = self.bodyTextView.selectedTextRange;
    if([currentRange.end isEqual:self.bodyTextView.endOfDocument]){
        return;
    }
    
    [currentRange isEmpty] ? [self moveCaret:1] : [self moveSelectRange:1];
}

- (void)onPushLeftButton:(id)sender
{
    UITextRange *currentRange = self.bodyTextView.selectedTextRange;
    if([currentRange.start isEqual:self.bodyTextView.beginningOfDocument]){
        return;
    }
    
    [currentRange isEmpty] ? [self moveCaret:-1] : [self moveSelectRange:-1];
}

- (void)onPushTemplateButton:(id)sender
{
    TMInsertTemplateViewController *insertTemplateView = [[self storyboard] instantiateViewControllerWithIdentifier:@"insertTemplateTableView"];
    [insertTemplateView setCurrentCaretPosision:self.bodyTextView.selectedRange];
    
    // キーボードを一旦消す
    [self.bodyTextView resignFirstResponder];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // iPadの場合、画面中央配置にする
        insertTemplateView.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:insertTemplateView animated:YES completion:nil];
}

- (void)moveSelectRange:(NSInteger)offset
{
    UITextRange *currentRange = self.bodyTextView.selectedTextRange;
    UITextPosition *newPosition =
    [self.bodyTextView positionFromPosition:currentRange.end offset:offset];
    
    UITextRange *newRange;
    newRange = [self.bodyTextView textRangeFromPosition:currentRange.start
                                                 toPosition:newPosition];
    
    self.bodyTextView.selectedTextRange = newRange;
    // 移動した部分が表示されるようにスクロースさせる
    [self.bodyTextView scrollRangeToVisible:[self.bodyTextView selectedRange]];
}

- (void)moveCaret:(NSInteger)offset
{
    UITextRange *currentRange = self.bodyTextView.selectedTextRange;
    UITextPosition *newPosition =
    [self.bodyTextView positionFromPosition:currentRange.start offset:offset];
    
    UITextRange *newRange;
    newRange = [self.bodyTextView textRangeFromPosition:newPosition
                                                 toPosition:newPosition];
    
    self.bodyTextView.selectedTextRange = newRange;
    // 移動した部分が表示されるようにスクロースさせる
    [self.bodyTextView scrollRangeToVisible:[self.bodyTextView selectedRange]];
}

- (void)onPushRedoButton:(id)sender
{
    if (_detailItem) {
        TextViewHistory *history = [_redoStore pop:_detailItem.memoid];
        if (history != nil) {
            // redo前のデータをundoに積む
            [_undoStore push:_detailItem.memoid bodyHistory:self.bodyTextView.text atRange:self.bodyTextView.selectedRange];
            _detailItem.body = [history.text mutableCopy];
            
            self.bodyTextView.scrollEnabled = NO;
            [self.bodyTextView setText:[history.text mutableCopy]];
            self.bodyTextView.scrollEnabled = YES;
            
            self.bodyTextView.selectedRange = history.selectedRange;
            [self.bodyTextView scrollRangeToVisible:self.bodyTextView.selectedRange];
        } else {
            
        }
    }
}

- (void)onPushUndoButton:(id)sender
{
    if (_detailItem) {
        TextViewHistory *history = [_undoStore pop:_detailItem.memoid];
        if (history != nil) {
            // undo前のデータをredoに積む
            [_redoStore push:_detailItem.memoid bodyHistory:self.bodyTextView.text atRange:self.bodyTextView.selectedRange];
            _detailItem.body = [history.text mutableCopy];
            
            self.bodyTextView.scrollEnabled = NO;
            [self.bodyTextView setText:[history.text mutableCopy]];
            self.bodyTextView.scrollEnabled = YES;
            
            self.bodyTextView.selectedRange = history.selectedRange;
            [self.bodyTextView scrollRangeToVisible:self.bodyTextView.selectedRange];
        }
    }
}

// メモを保存
- (void)saveMemo
{
    // 選択したMemoを保存
    if (_detailItem) {
        
        if (self.bodyTextView.text.length > 0) {
            _detailItem.body = self.bodyTextView.text;
        } else {
            _detailItem.body = @"";
        }
        
        BOOL bResult = [memoDao update:_detailItem];
        if (bResult) {
            
            // 情報を更新
            _detailItem = [memoDao memo:_detailItem.memoid];
            
            // 改行までをタイトルとして設定
            NSMutableArray *lines = [NSMutableArray array];
            [_detailItem.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                [lines addObject:line];
                //        *stop = YES;
            }];
            
            // 内容が空の場合
            if (lines.count <= 0) {
                self.navigationItem.title = NSLocalizedString(@"editmemoview.navigation.title.empty", @"edit memo view empty title");
                return;
            }
            
            // タイトルは本文の一行目
            self.navigationItem.title = [lines objectAtIndex:0];
            
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//            [appDelegate.memoTableViewController updateVisibleCells];
            [appDelegate.memoTableViewController updateVisibleCells];
            DDLogInfo(@"メモ表示: メモを保存");
        }
    }
}

// テンプレートを保存
- (void)saveTemplateMemo
{
    if (_templateMemo) {
        
        if ([self.bodyTextView hasText]) {
            _templateMemo.body = [self.bodyTextView.text mutableCopy];
        } else {
            _templateMemo.body = @"";
        }
        
        if ([templateDao update:_templateMemo]) {
            
            self.navigationItem.title = _templateMemo.name;
            
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate.templateMemoViewController updateVisibleCells];
            DDLogInfo(@"メモ表示: テンプレートを保存");
        }
    }
}

#pragma mark - Text view Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    DDLogVerbose(@"メモ編集: 編集開始");
    [self setEditDoneButton];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    DDLogVerbose(@"メモ編集: 編集終了");
    [self setAddMemoButton];
    if (_editTarget == TMEditTargetMemo) {
        // メモを保存
        [self saveMemo];
    } else if (_editTarget == TMEditTargetTemplate) {
        // テンプレートを保存
        [self saveTemplateMemo];
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    // popoverのviewによってボタンの文言を変更(アクティブなViewのタイトルで判別)
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if ([activeSideView.title isEqualToString:appDelegate.tagTableViewController.title]) {
        barButtonItem.title = appDelegate.tagTableViewController.navigationItem.title;
    } else {
        barButtonItem.title = appDelegate.memoTableViewController.navigationItem.title;
    }
    if (barButtonItem.title == nil) {
        barButtonItem.title = NSLocalizedString(@"editmemoview.barbutton.tag.title", @"edit memo view bar button default title");
    }
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
    DDLogInfo(@"メモ表示: ポップオーバー表示");
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
    DDLogInfo(@"メモ表示: 2カラム表示");
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showTagSetting"]) {
        TMTagSettingTableViewController *destinationView = [segue destinationViewController];
        [destinationView setActiveMemo:self];
    } else if ([[segue identifier] isEqualToString:@"showMemoInfo"]){
        TMMemoInfoTableViewController *destinationView = [segue destinationViewController];
        [destinationView setActiveMemo:self];
    }
}

// スクロールされる度に呼ばれる
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect frame = self.view.frame;
    float viewHeight = frame.size.height;
    float adViewWidth = adView.frame.size.width;
    float adViewHeight = adView.frame.size.height;
    adView.center = CGPointMake(adViewWidth / 2, self.bodyTextView.contentOffset.y + viewHeight - adViewHeight / 2);
    [self.view bringSubviewToFront:adView];
}

#pragma mark - iAd Delegate

// iAD ------------------------------------------------

// 新しい広告がロードされた後に呼ばれる
// 非表示中のバナービューを表示する
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	if (!bannerIsVisible) {
        UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
        if (interfaceOrientation != UIDeviceOrientationPortrait && interfaceOrientation != UIDeviceOrientationPortraitUpsideDown ) {
            return;
        }
		[UIView beginAnimations:@"animateAdBannerOn" context:NULL];
		[UIView setAnimationDuration:1.0];
        
#ifdef DISP_AD_BOTTOM
		banner.frame = CGRectOffset(banner.frame, 0, -CGRectGetHeight(banner.frame));
#else
		banner.frame = CGRectOffset(banner.frame, 0, CGRectGetHeight(banner.frame));
#endif
        banner.alpha = 1.0;
        
		[UIView commitAnimations];
		bannerIsVisible = YES;
        DDLogInfo(@"メモ表示: iAd表示");
	}
}

// 広告バナータップ後に広告画面切り替わる前に呼ばれる
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
	BOOL shoudExecuteAction = YES; // 広告画面に切り替える場合はYES（通常はYESを指定する）
	if (!willLeave && shoudExecuteAction) {
		// 必要ならココに、広告と競合する可能性のある処理を一時停止する処理を記述する。
        DDLogInfo(@"メモ表示: iAdタップ");
	}
	return shoudExecuteAction;
}

// 広告画面からの復帰時に呼ばれる
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    // 必要ならココに、一時停止していた処理を再開する処理を記述する。
}

// 表示中の広告が無効になった場合に呼ばれる
// 表示中のバナービューを非表示にする
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if (bannerIsVisible) {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		[UIView setAnimationDuration:1.0];
        
#ifdef DISP_AD_BOTTOM
        banner.frame = CGRectOffset(banner.frame, 0, CGRectGetHeight(banner.frame));
#else
        banner.frame = CGRectOffset(banner.frame, 0, -CGRectGetHeight(banner.frame));
#endif
        banner.alpha = 0.0;
        
        [UIView commitAnimations];
        bannerIsVisible = NO;
        DDLogInfo(@"メモ表示: iAd非表示 >> %@", [error localizedDescription]);
    }
}

// 回転処理 -----------------------------------------------

// 回転時の各ビューのサイズ・表示位置の調整を行う
- (void)changeRotateForm
{
    CGFloat height = self.view.bounds.size.height + self.bodyTextView.contentOffset.y;
#ifdef DISP_AD_BOTTOM
    adView.frame = CGRectMake(0, height, adView.frame.size.width, adView.frame.size.height);
	if (bannerIsVisible) {
		adView.frame = CGRectOffset(adView.frame, 0, -CGRectGetHeight(adView.frame));
    }
#else
	if (bannerIsVisible) {
		adView.frame = CGRectMake(0, 0, adView.frame.size.width, adView.frame.size.height);
    }
    else{
        adView.frame = CGRectMake(0, -adView.frame.size.height, adView.frame.size.width, adView.frame.size.height);
    }
#endif
}

// 回転アニメーション直前にコール
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    DDLogInfo(@"メモ表示: ローテーション %d", interfaceOrientation);
    if (interfaceOrientation != UIDeviceOrientationPortrait && interfaceOrientation != UIDeviceOrientationPortraitUpsideDown ) {
        [self bannerView:adView didFailToReceiveAdWithError:nil];
    } else {
        [self bannerViewDidLoadAd:adView];
        [self changeRotateForm];
    }
}

@end
