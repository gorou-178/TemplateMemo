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

#import "TMTagSettingTableViewController.h"
#import "TMMemoInfoTableViewController.h"

#import "MemoUndoRedoStore.h"
#import "KeyboardButtonView.h"

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
    tagDao = [TagDaoImpl new];
    memoDao = [MemoDaoImpl new];
    templateDao = [TemplateDaoImpl new];
    _editTarget = TMEditTargetMemo;
    
    fastViewFlag = YES;
	bannerIsVisible = NO;
    
    _undoStore = [[MemoUndoRedoStore alloc] init];
    _redoStore = [[MemoUndoRedoStore alloc] init];
    
    [self setAddMemoButton];
    [self setEditDoneButton];
}

- (void)handleSingleTap
{
    NSLog(@"handleSingleTap");
    if (![self.bodyTextView isEditable]) {
        [self.bodyTextView setEditable:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    originalSize = CGSizeZero;
    
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
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.editMemoViewController = self;
    self.bodyTextView.delegate = self;
    
    // キーボードアクセサリビュー作成
    CGRect bounds = self.view.bounds;
    KeyboardButtonView *accessoryView = [[KeyboardButtonView alloc] initWithFrame:CGRectMake(0,0,bounds.size.width,35)];
    [accessoryView.closeButton addTarget:self action:@selector(onPushCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [accessoryView.rightButton addTarget:self action:@selector(onPushRightButton:) forControlEvents:UIControlEventTouchUpInside];
    [accessoryView.leftButton addTarget:self action:@selector(onPushLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    self.bodyTextView.inputAccessoryView = accessoryView;
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

- (Memo *)currentMemo
{
    return _detailItem;
}

- (TemplateMemo *)currentTemplateMemo
{
    return _templateMemo;
}

#pragma mark - Custom UI

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
        [self.tagSettingButton setEnabled:YES];
        [self.addMemoButton setEnabled:YES];
        
        // メモ選択で表示する
        if ([self.bodyTextView isHidden]) {
            [self.bodyTextView setHidden:NO];
            [self.memoInfoButton setEnabled:YES];
        }
        
        // Update the view.
        [self configureView];
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
        [self.tagSettingButton setEnabled:NO];
        [self.addMemoButton setEnabled:NO];
        
        // メモ選択で表示する
        if ([self.bodyTextView isHidden]) {
            [self.bodyTextView setHidden:NO];
            [self.memoInfoButton setEnabled:YES];
        }
        
        // Update the view.
        [self configureView];
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
        
        self.bodyTextView.text = [_detailItem.body mutableCopy];
        
        // 改行までをタイトルとして設定
        NSMutableArray *lines = [NSMutableArray array];
        [_detailItem.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            [lines addObject:line];
            *stop = YES;
        }];
        
        if (lines.count <= 0) {
            self.navigationItem.title = @"(no title)";
            return;
        }
        
        // タイトルは本文の一行目
        self.navigationItem.title = [lines objectAtIndex:0];
        
    } else if (_editTarget == TMEditTargetTemplate) {
        self.navigationItem.title = [_templateMemo.name mutableCopy];
        
        self.bodyTextView.text = [_templateMemo.body mutableCopy];
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    // アクティブ出ない場合何もしない
    if(![_bodyTextView isFirstResponder])
    {
        return;
    }
    
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
        return;
    }
    
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
    [self changeRotateForm];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // iPadにてアプリ起動時にランドスケープの場合、ボタン表示位置が左寄りになるのを防ぐために必要
    if(fastViewFlag == YES){
        fastViewFlag = NO;
        [self changeRotateForm];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
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

- (void)applicationWillResignActive:(NSNotificationCenter *)center
{
    // キーボード表示と同時に他のアプリやOSの通知ダイアログが表示された場合の対処
    DDLogInfo(@"メモ表示: 非アクティブ");
    [self onPushDone:self.editDoneButton];
}

//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
////    NSLog(@"'%@' text:%@ , loc:%d , len:%d → %@",textView.text , text , range.location , range.length , newString);
//    // 変換完了であればUndoに積む
//    if ([_bodyTextView markedTextRange] == nil) {
//
////        [[_bodyTextView.undoManager prepareWithInvocationTarget:self] updateTextRange:textView.selectedTextRange currentText:textView.text];
////        [_undoStore push:_detailItem.memoid bodyHistory:textView.text];
//    }
//
//    return YES;
//}

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
//    [self saveMemo];
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

- (void)moveSelectRange:(NSInteger)offset
{
    UITextRange *currentRange = self.bodyTextView.selectedTextRange;
    UITextPosition *newPosition =
    [self.bodyTextView positionFromPosition:currentRange.end offset:offset];
    
    UITextRange *newRange;
    newRange = [self.bodyTextView textRangeFromPosition:currentRange.start
                                                 toPosition:newPosition];
    
    self.bodyTextView.selectedTextRange = newRange;
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
}

//- (void)onPushRedoButton:(id)sender
//{
//    if (_detailItem) {
//        NSString *redoBody = [_redoStore pop:_detailItem.memoid];
//        if (redoBody != nil) {
//            // redo前のデータをundoに積む
//            [_undoStore push:_detailItem.memoid bodyHistory:_detailItem.body];
//            _detailItem.body = [redoBody mutableCopy];
//            [self.bodyTextView setText:[redoBody mutableCopy]];
//        } else {
//            
//        }
//    }
//}
//
//- (void)onPushUndoButton:(id)sender
//{
//    if (_detailItem) {
//        NSString *undoBody = [_undoStore pop:_detailItem.memoid];
//        if (undoBody != nil) {
//            // undo前のデータをredoに積む
//            [_redoStore push:_detailItem.memoid bodyHistory:_detailItem.body];
//            _detailItem.body = [undoBody mutableCopy];
//            [self.bodyTextView setText:[undoBody mutableCopy]];
//        }
//    }
//}

// メモを保存
- (void)saveMemo
{
    [self setAddMemoButton];
    
    // 選択したMemoを保存
    if (_detailItem) {
        
        if (self.bodyTextView.text.length > 0) {
            _detailItem.body = self.bodyTextView.text;
        } else {
            _detailItem.body = @"";
        }
        
        BOOL bResult = [memoDao update:_detailItem];
        if (bResult) {
            
            // 改行までをタイトルとして設定
            NSMutableArray *lines = [NSMutableArray array];
            [_detailItem.body enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                [lines addObject:line];
                //        *stop = YES;
            }];
            
            // 内容が空の場合
            if (lines.count <= 0) {
                self.navigationItem.title = @"(no title)";
                return;
            }
            
            // タイトルは本文の一行目
            self.navigationItem.title = [lines objectAtIndex:0];
            
            AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
            [appDelegate.memoTableViewController updateVisibleCells];
            DDLogInfo(@"メモ表示: メモを保存");
        }
    }
}

// テンプレートを保存
- (void)saveTemplateMemo
{
    [self setAddMemoButton];
    if (_templateMemo) {
        
        if ([self.bodyTextView.text length] > 0) {
            _templateMemo.body = self.bodyTextView.text;
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
    [self setEditDoneButton];
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
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
        barButtonItem.title = @"タグ";
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
    CGFloat height = self.view.bounds.size.height;
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
