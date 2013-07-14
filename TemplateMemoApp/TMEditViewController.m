//
//  TMEditViewController.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/04.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMTagTableViewController.h"
#import "TMEditViewController.h"
#import "TMMemoTableViewController.h"
#import "TMAppContext.h"
#import "Memo.h"
#import "TagDao.h"
#import "Tag.h"
#import "TagLink.h"

@interface TMEditViewController ()
{
    id<MemoDao> memoDao;
    id<TagDao> tagDao;
    id<UITextInput> activeTextInput;
    UITableViewController *activeSideView;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation TMEditViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    tagDao = [TagDaoImpl new];
    memoDao = [MemoDaoImpl new];
    
    // textView設定
    [self registerForKeyboardNotifications];
    
    // navigationItem UI作成
    [self createAddMemoButton];
    [self createEditDoneButton];
    self.navigationItem.rightBarButtonItem = self.addMemoButton;
    
    [self configureView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // textField設定
    self.tagTextField.delegate = self;
    self.tagTextField.returnKeyType = UIReturnKeyDone;
    
    // textFieldのラベル化
//    self.tagTextField.text = @"テスト";
//    NSDictionary *stringAttributes1 = @{NSStrokeColorAttributeName : [UIColor blueColor],
//                                        NSStrokeWidthAttributeName : @2.0};
//    NSAttributedString *string1 = [[NSAttributedString alloc] initWithString:@"テスト"
//                                                                  attributes:stringAttributes1];
//    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] init];
//    [mutableAttributedString appendAttributedString:string1];
//    self.tagTextField.attributedText = mutableAttributedString;
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
        if ([activeSideView.title isEqualToString:self.tagTableViewController.title]) {
            self.navigationItem.leftBarButtonItem.title = self.tagTableViewController.navigationItem.title;
        } else {
            self.navigationItem.leftBarButtonItem.title = self.memoTableViewController.navigationItem.title;
        }
    }
}

#pragma mark - Custom UI

- (void)createAddMemoButton
{
    if (self.addMemoButton == nil) {
        self.addMemoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onPushDone:)];
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
    if (_detailItem) {
        
        NSMutableString *tagText = [[NSMutableString alloc] init];
        NSArray *tags = [tagDao tagForMemo:_detailItem];
        for (int i = 0; i < tags.count; i++) {
            if (i != 0) {
                [tagText appendString:@" "];
            }
            [tagText appendString:((Tag*)tags[i]).name];
        }
        self.tagTextField.text = tagText;
        self.bodyTextView.text = _detailItem.body;
    }
}

#pragma mark - Text view

- (void)registerForKeyboardNotifications
{
    //TODO: 他UIのキーボードイベントの通知も来てしまうのでどうにかできないか(selector側での区別？)
    
    // キーボードが表示される時に通知が来る
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    // キーボードが閉じる時に通知が来る
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // キーボード表示 & キーボード切り替え後に通知が来る
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    // キーボードの切り替え時に通知が来る
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrameNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}

#pragma mark - Notification Keyboard selectors

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
    [self createEditDoneButton];
    self.navigationItem.rightBarButtonItem = self.editDoneButton;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    self.editMode = NO;
    NSLog(@"call keyboardWillBeHidden => editMode: %d", self.editMode);
    // キーボードが閉じたタイミングでボタンを「メモ追加ボタン」に変更
    [self createAddMemoButton];
    self.navigationItem.rightBarButtonItem = self.addMemoButton;
    
    // 選択したMemoを保存
    if (_detailItem && _memoTableViewController) {
        _detailItem.body = self.bodyTextView.text;
        
        BOOL bResult = [memoDao update:_detailItem];
        if (bResult) {
            [_memoTableViewController updateVisibleCells];
        }
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSLog(@"call textViewShouldBeginEditing");
    activeTextInput = self.bodyTextView;
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
    activeTextInput = nil;
    NSLog(@"call textViewDidEndEditing");
}

#pragma mark - Custom UI Selectors

- (void)onPushAdd:(id)sender {
    // メモコントローラのメモ追加処理をコール
    NSLog(@"onPushAdd");
    [self.memoTableViewController insertNewObject:sender];
}

- (void)onPushDone:(id)sender {
    // 意図的にキーボードを閉じる場合
    NSLog(@"onPushDone");
    // 現在アクティブなtextInputによって閉じるキーボードを変更
    if (activeTextInput == self.tagTextField) {
        [self.tagTextField resignFirstResponder];
        [self saveTag];
    } else {
        [self.bodyTextView resignFirstResponder];
    }
    activeTextInput = nil;
}

// tagTextFieldの内容でTag/TagLinkを保存
- (void)saveTag
{
    if (self.tagTextField.text.length > 0) {
        // 入力タグから重複を消す
        NSArray *tagNames = [self.tagTextField.text componentsSeparatedByString:@" "];
        NSSet *uniqOriginalTagNameSet = [[NSSet alloc] initWithArray:tagNames];
        NSString *uniqTagNameText = [[uniqOriginalTagNameSet allObjects] componentsJoinedByString:@" "];
        self.tagTextField.text = uniqTagNameText;
        
        /*
         1 入力されたタグ名半角空白で区切る
         2 現在登録されているタグ一覧を取得
         3 タグ名が一致するタグを全て取り出す
         4 タグ名が一致しないタグは新規登録
         5 保存対象のメモのtagLinkから全てのtagを取得
         6 5と3でtagが一致しなかったtagをメモのtagLinkを削除
         7 4のtagLinkを新規登録
         */
        
        // 現在登録されているtagを追加
        NSMutableArray *tags = [tagDao.tags mutableCopy];
        NSMutableSet *tagNameSet = [[NSMutableSet alloc] init];
        for (Tag *tag in tags) {
            [tagNameSet addObject:tag.name];
        }
        
        // 新しく設定されたtagを調べる
        for (NSString *tagName in tagNames) {
            // 現在登録されているタグにはないタグ名の場合、新規追加する
            if (![tagNameSet containsObject:tagName]) {
                Tag *tag = [Tag new];
                tag.name = tagName;
                tag.deleteFlag = 0;
                [tagDao add:tag];
            }
        }
        
        // 再度タグを全て取得(tagIdの取得がしたいため)
        tags = [tagDao.tags mutableCopy];
        
        // 元々のtagLinkのタグが入力タグに存在しない場合、リンクを削除する
        NSMutableArray *copyTagNames = [tagNames mutableCopy];
        NSMutableArray *memoTags = [[tagDao tagForMemo:_detailItem] mutableCopy];
        for (Tag *tag in memoTags) {
            if (![tagNames containsObject:tag.name]) {
                [tagDao removeTagLink:_detailItem forLinkTag:tag];
            } else {
                [copyTagNames removeObject:tag.name];
            }
        }
        
        // 新しく追加したTagのTagLinkを追加
        for (NSString *tagName in copyTagNames) {
            for (Tag *tag in tags) {
                if ([tag.name isEqualToString:tagName]) {
                    [tagDao addTagLink:_detailItem forLinkTag:tag];
                }
            }
        }
    }
}

#pragma mark - tagTextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"tagTextField shouldBeginEditing");
    activeTextInput = self.tagTextField;
    return YES;
}

// tagTextFieldでreturnキータップでキーボードを閉じる
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"tagTextField shouldReturn");
    [textField resignFirstResponder];
    activeTextInput = nil;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"tagTextField DidEndEditing");
    activeTextInput = nil;
}

#pragma mark - tagTextField Actions

- (IBAction)onDidEndOnExitForTagTextField:(id)sender {
    NSLog(@"tagTextField EndTagEdit");
    activeTextInput = nil;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    // popoverのviewによってボタンの文言を変更
//    UIViewController *popoverViewController = popoverController.contentViewController;
//    if ([popoverViewController.title isEqual:NSLocalizedString(@"tagTableViewTitle", nil)]) {
//        barButtonItem.title = NSLocalizedString(@"tagTableViewTitle", nil);
//    } else if ([popoverViewController.title isEqual:NSLocalizedString(@"memoTableViewTitle", nil)]) {
//        barButtonItem.title = NSLocalizedString(@"memoTableViewTitle", nil);
//    }
    if ([activeSideView.title isEqualToString:self.tagTableViewController.title]) {
        barButtonItem.title = @"タグ";
    } else {
        barButtonItem.title = @"メモ";
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

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
*/

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
 
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
 
}
*/

@end
