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

@interface TMEditMemoViewController ()
{
    id<MemoDao> memoDao;
    id<TagDao> tagDao;
    id<TemplateDao> templateDao;
    id<UITextInput> activeTextInput;
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
    
    // textView設定
//    [self registerForKeyboardNotifications];
    
    // navigationItem UI作成
    [self createEditDoneButton];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self createAddMemoButton];
        self.navigationItem.rightBarButtonItem = self.addMemoButton;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    originalSize = CGSizeZero;
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    appDelegate.editMemoViewController = self;
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

- (void)createAddMemoButton
{
    if (self.addMemoButton == nil) {
        self.addMemoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onPushAdd:)];
    }
}

- (void)createEditDoneButton
{
    if (self.editDoneButton == nil) {
        self.editDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onPushDone:)];
    }
}

#pragma mark - Managing the tmEditViewControler

- (void)setDetailItem:(Memo *)newDetailItem
{
    // TODO: ポインタ比較はNGだと思う
    if (_detailItem != newDetailItem) {
        
        // 編集モード - メモ
        _editTarget = TMEditTargetMemo;
        [self.tagSettingButton setEnabled:YES];
        
//        // メモ選択で表示する
//        if ([self.bodyTextView isHidden]) {
//            [self.bodyTextView setHidden:NO];
//            [self.tagTextField setHidden:NO];
//        }
        
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)setTemplateMemo:(TemplateMemo *)templateMemo
{
    // TODO: ポインタ比較はNGだと思う
    if (_templateMemo != templateMemo ) {
        _editTarget = TMEditTargetTemplate;
        _templateMemo = templateMemo;
        [self.tagSettingButton setEnabled:NO];
        
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

#pragma mark - Notification Keyboard selectors

//- (void)keyboardWillChangeFrameNotification:(NSNotification*)aNotification
//{
//    NSLog(@"call keyboardWillChangeFrameNotification");
//}
//
//- (void)keyboardWillShowNotification:(NSNotification*)aNotification
//{
//    NSLog(@"call keyboardWillShowNotification");
//}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    self.editMode = YES;
    NSLog(@"call keyboardWasShown => editMode: %d", self.editMode);
   
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    if([_bodyTextView isFirstResponder])
    {
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
    
    // キーボードを開いたタイミングでボタンを「編集完了ボタン」に変更
    [self createEditDoneButton];
    [self.navigationItem setRightBarButtonItem:self.editDoneButton animated:YES];
}

- (void)keybaordWillHide:(NSNotification*)aNotification
{
    self.editMode = NO;
    NSLog(@"call keyboardWillBeHidden => editMode: %d", self.editMode);
    
    if([_bodyTextView isFirstResponder])
    {
        NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        CGRect frame = _bodyTextView.frame;
        frame.size = originalSize;
        _bodyTextView.frame = frame;
        
        originalSize = CGSizeZero;
        
        [UIView commitAnimations];
    }
    
    // キーボードが閉じたタイミングでボタンを「メモ追加ボタン」に変更(iPadのみ)
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self createAddMemoButton];
        [self.navigationItem setRightBarButtonItem:self.addMemoButton animated:YES];
        [self.navigationItem setRightBarButtonItem:self.addMemoButton animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
    
    if (_editTarget == TMEditTargetMemo) {
        // メモを保存
        [self saveMemo];
    } else if (_editTarget == TMEditTargetTemplate) {
        // テンプレートを保存
        [self saveTemplateMemo];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"call textViewShouldBeginEditing");
    activeTextInput = self.bodyTextView;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    activeTextInput = nil;
    NSLog(@"call textViewDidEndEditing");
}

- (void)viewWillAppear:(BOOL)animated
{
    // super
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    // super
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
    NSLog(@"★applicationWillResignActive");
    [self onPushDone:self.editDoneButton];
}

#pragma mark - Custom UI Selectors

- (void)onPushAdd:(id)sender {
    // メモコントローラのメモ追加処理をコール
    NSLog(@"onPushAdd");
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (_editTarget == TMEditTargetMemo) {
        [appDelegate.memoTableViewController insertNewObject:sender];
    } else if (_editTarget == TMEditTargetTemplate) {
        [appDelegate.templateMemoViewController insertTemplateMemo:sender];
    }
}

- (void)onPushDone:(id)sender {
    // 意図的にキーボードを閉じる場合
    NSLog(@"onPushDone");
    // 現在アクティブなtextInputによって閉じるキーボードを変更
//    if (activeTextInput == self.tagTextField) {
//        [self.tagTextField resignFirstResponder];
//    } else {
        [self.bodyTextView resignFirstResponder];
//    }
    activeTextInput = nil;
    
    // タグを保存
//    [self saveTag];
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
        }
    }
}

// テンプレートを保存
- (void)saveTemplateMemo
{
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
        }
    }
}

// tagTextFieldの内容でTag/TagLinkを保存
//- (void)saveTag
//{
//    if (self.tagTextField.text.length > 0) {
//        
//        /*
//         1 入力されたタグ名半角空白で区切る
//         2 現在登録されているタグ一覧を取得
//         3 タグ名が一致するタグを全て取り出す
//         4 タグ名が一致しないタグは新規登録
//         5 保存対象のメモのtagLinkから全てのtagを取得
//         6 5と3でtagが一致しなかったtagをメモのtagLinkを削除
//         7 4のtagLinkを新規登録
//         */
//        
//        // 入力タグから重複を消す
//        NSArray *tagNames = [self.tagTextField.text componentsSeparatedByString:@" "];
//        NSSet *uniqOriginalTagNameSet = [[NSSet alloc] initWithArray:tagNames];
//        NSString *uniqTagNameText = [[uniqOriginalTagNameSet allObjects] componentsJoinedByString:@" "];
//        self.tagTextField.text = uniqTagNameText;
//        
//        // 現在登録されているtagを追加
//        NSMutableArray *tags = [tagDao.tags mutableCopy];
//        NSMutableSet *tagNameSet = [[NSMutableSet alloc] init];
//        for (Tag *tag in tags) {
//            [tagNameSet addObject:tag.name];
//        }
//        
//        // 新しく設定されたtagを調べる
//        for (NSString *tagName in tagNames) {
//            // 現在登録されているタグにはないタグ名の場合、新規追加する
//            if (![tagNameSet containsObject:tagName]) {
//                Tag *tag = [Tag new];
//                tag.name = tagName;
//                tag.deleteFlag = 0;
//                [tagDao add:tag];
//            }
//        }
//        
//        // 再度タグを全て取得(tagIdの取得がしたいため)
//        tags = [tagDao.tags mutableCopy];
//        
//        // 元々のtagLinkのタグが入力タグに存在しない場合、リンクを削除する
//        NSMutableArray *copyTagNames = [tagNames mutableCopy];
//        NSMutableArray *memoTags = [[tagDao tagForMemo:_detailItem] mutableCopy];
//        for (Tag *tag in memoTags) {
//            if (![tagNames containsObject:tag.name]) {
//                [tagDao removeTagLink:_detailItem forLinkTag:tag];
//            } else {
//                [copyTagNames removeObject:tag.name];
//            }
//        }
//        
//        // 新しく追加したTagのTagLinkを追加
//        for (NSString *tagName in copyTagNames) {
//            for (Tag *tag in tags) {
//                if ([tag.name isEqualToString:tagName]) {
//                    [tagDao addTagLink:_detailItem forLinkTag:tag];
//                }
//            }
//        }
//        
//        // タグTableViewを更新
//        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//        [appDelegate.tagTableViewController updateVisibleCells];
//    }
//}

//#pragma mark - tagTextField delegate
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
//{
//    NSLog(@"tagTextField shouldBeginEditing");
//    activeTextInput = self.tagTextField;
//    return YES;
//}
//
//// tagTextFieldでreturnキータップでキーボードを閉じる
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    NSLog(@"tagTextField shouldReturn");
//    [textField resignFirstResponder];
//    activeTextInput = nil;
//    return YES;
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    NSLog(@"tagTextField DidEndEditing");
//    activeTextInput = nil;
//}

#pragma mark - tagTextField Actions

//- (IBAction)onDidEndOnExitForTagTextField:(id)sender {
//    NSLog(@"tagTextField EndTagEdit");
//    activeTextInput = nil;
//}

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
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
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

@end
