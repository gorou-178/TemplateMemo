//
//  AAMFeedbackViewController.m
//  AAMFeedbackViewController
//
//  Created by 深津 貴之 on 11/11/30.
//  Copyright (c) 2011年 Art & Mobile. All rights reserved.
//

#import "AAMFeedbackViewController.h"
#import "AAMFeedbackTopicsViewController.h"
#include <sys/types.h>
#include <sys/sysctl.h>

#import "UIDevice-Hardware.h"

#import "SSZipArchive.h"

@interface AAMFeedbackViewController(private)
    - (NSString *) _platform;
    - (NSString *) _platformString;
    - (NSString*)_feedbackSubject;
    - (NSString*)_feedbackBody;
    - (NSString*)_appName;
    - (NSString*)_appVersion;
    - (NSString*)_selectedTopic;
    - (NSString*)_selectedTopicToSend;
    - (void)_updatePlaceholder;
@end


@implementation AAMFeedbackViewController

@synthesize descriptionText;
@synthesize topics;
@synthesize topicsToSend;
@synthesize toRecipients;
@synthesize ccRecipients;
@synthesize bccRecipients;


+ (BOOL)isAvailable
{
    return [MFMailComposeViewController canSendMail];
}

-(id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if(self){
        self.topics = [[NSArray alloc]initWithObjects:
                       @"AAMFeedbackTopicsQuestion",
                       @"AAMFeedbackTopicsRequest",
                       @"AAMFeedbackTopicsBugReport",
                       @"AAMFeedbackTopicsMedia",
                       @"AAMFeedbackTopicsBusiness",
                       @"AAMFeedbackTopicsOther", nil];
        
        self.topicsToSend = [[NSArray alloc]initWithObjects:
                             @"Question",
                             @"Request",
                             @"Bug Report",
                             @"Media",
                             @"Business",
                             @"Other", nil];
    }
    return self;
}

- (id)initWithTopics:(NSArray*)theIssues
{
    self = [self init];
    if(self){
        self.topics = theIssues;
        self.topicsToSend = theIssues;
    }
    return self;
}

- (void)dealloc {
    self.descriptionText = nil;
    self.topics = nil;
    self.topicsToSend = nil;
    self.toRecipients = nil;
    self.ccRecipients = nil;
    self.bccRecipients = nil;
}


#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    self.title = NSLocalizedString(@"AAMFeedbackTitle", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDidPress:)];
    
    _doneButton = [[UIBarButtonItem alloc]initWithTitle:@"done" style:UIBarButtonItemStyleDone target:self action:@selector(onPushDone:)];
    _mailButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"AAMFeedbackButtonMail", nil) style:UIBarButtonItemStyleDone target:self action:@selector(confirmSendLogFile:)];
    self.navigationItem.rightBarButtonItem = _mailButton;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.toRecipients = [NSArray arrayWithObject:@"template-memo.app@gurimmer.lolipop.jp"];
    self.ccRecipients = nil;
    self.bccRecipients = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _descriptionPlaceHolder = nil;
    _descriptionTextView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    DDLogInfo(@"問い合わせフォーム表示");
    [super viewWillAppear:animated];
    [self registKeyBoardNotification];
    [self _updatePlaceholder];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_isFeedbackSent){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self unRegistKeyBoardNotification];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0){
        return 2;
    }
    return 4;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 && indexPath.row==1){
        return MAX(88, _descriptionTextView.contentSize.height);
    }
    
    return 44;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"AAMFeedbackTableHeaderTopics", nil);
            break;
        case 1:
            return NSLocalizedString(@"AAMFeedbackTableHeaderBasicInfo", nil);
            break;
        default:
            break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if(indexPath.section==1){
            //General Infos
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }else{
            if(indexPath.row==0){
                //Topics
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1      reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else{
                //Topics Description
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault      reuseIdentifier:CellIdentifier];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                _descriptionTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 0, 300, 88)];
                _descriptionTextView.backgroundColor = [UIColor clearColor];
                _descriptionTextView.font = [UIFont systemFontOfSize:16];
                _descriptionTextView.delegate = self;
                _descriptionTextView.scrollEnabled = NO;
                _descriptionTextView.text = self.descriptionText;
                [cell.contentView addSubview:_descriptionTextView];
                
                _descriptionPlaceHolder = [[UITextField alloc]initWithFrame:CGRectMake(16, 8, 300, 20)];
                _descriptionPlaceHolder.font = [UIFont systemFontOfSize:16];
                _descriptionPlaceHolder.placeholder = NSLocalizedString(@"AAMFeedbackDescriptionPlaceholder", nil);
                _descriptionPlaceHolder.userInteractionEnabled = NO;
                [cell.contentView addSubview:_descriptionPlaceHolder];
                
                [self _updatePlaceholder];
            }
        }
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    
                    cell.textLabel.text = NSLocalizedString(@"AAMFeedbackTopicsTitle", nil);
                    cell.detailTextLabel.text = NSLocalizedString([self _selectedTopic],nil);
                    break;
                case 1:
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Device";
                    cell.detailTextLabel.text = [[UIDevice currentDevice] platformString];
//                    cell.detailTextLabel.text = [self _platformString];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 1:
                    cell.textLabel.text = @"iOS";
                    cell.detailTextLabel.text = [UIDevice currentDevice].systemVersion;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 2:
                    cell.textLabel.text = @"App Name";
                    cell.detailTextLabel.text = [self _appName];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                case 3:
                    cell.textLabel.text = @"App Version";
                    cell.detailTextLabel.text = [self _appVersion];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0 && indexPath.row==0){
        [_descriptionTextView resignFirstResponder];
        
        AAMFeedbackTopicsViewController *vc = [[AAMFeedbackTopicsViewController alloc]initWithStyle:UITableViewStyleGrouped];
        vc.delegate = self;
        vc.selectedIndex = _selectedTopicsIndex;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (void)cancelDidPress:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextDidPress:(BOOL)isAttachLogFile
{
    [_descriptionTextView resignFirstResponder];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];

    if (!picker) return;

    picker.mailComposeDelegate = self;
    [picker setToRecipients:self.toRecipients];
    [picker setCcRecipients:self.ccRecipients];  
    [picker setBccRecipients:self.bccRecipients];
    [picker setSubject:[self _feedbackSubject]];
    [picker setMessageBody:[self _feedbackBody] isHTML:NO];
    
    if (isAttachLogFile) {
        if (![self deleteTmpFile]) {
            DDLogError(@"作業ディレクトリのファイル削除に失敗しました");
        }
        else {
            DDLogInfo(@"作業ディレクトリのファイル削除");
        }
        
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
        NSString *logDirPath = [documentPaths objectAtIndex:0];
        logDirPath = [[NSString alloc] initWithString:[logDirPath stringByAppendingPathComponent:@"logs"]];
        NSLog(@"logDirPath: %@", logDirPath);
        
        NSString *zipFileName = @"logs.zip";
        NSString *zipFilePath = [self createZipLogFile:NSTemporaryDirectory() zipFileName:zipFileName logFileDir:logDirPath];
        NSData *zipFileBinaryData = [[NSData alloc] initWithContentsOfFile:zipFilePath];
        [picker addAttachmentData:zipFileBinaryData mimeType:@"" fileName:zipFileName];
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}


- (void)textViewDidChange:(UITextView *)textView
{
    CGRect f = _descriptionTextView.frame;
    f.size.height = _descriptionTextView.contentSize.height;
    _descriptionTextView.frame = f;
    [self _updatePlaceholder];
    self.descriptionText = _descriptionTextView.text;
    
    //Magic for updating Cell height
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if(result==MFMailComposeResultCancelled){
        DDLogInfo(@"問い合わせフォーム表示: メール送信キャンセル");
    }else if(result==MFMailComposeResultSent){
        _isFeedbackSent = YES;
        DDLogInfo(@"問い合わせフォーム表示: メール送信");
    }else if(result==MFMailComposeResultFailed){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                        message:@"AAMFeedbackMailDidFinishWithError"
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        DDLogInfo(@"問い合わせフォーム表示: メール送信に失敗 >> %@", [error localizedDescription]);
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)feedbackTopicsViewController:(AAMFeedbackTopicsViewController *)feedbackTopicsViewController didSelectTopicAtIndex:(NSInteger)selectedIndex {
    _selectedTopicsIndex = selectedIndex;
}

#pragma mark - Internal Info

- (void)_updatePlaceholder
{
    if([_descriptionTextView.text length]>0){
        _descriptionPlaceHolder.hidden = YES;
    }else{
        _descriptionPlaceHolder.hidden = NO;
    }
}

- (NSString*)_feedbackSubject
{
    return [NSString stringWithFormat:@"%@: %@", [self _appName],[self _selectedTopicToSend], nil];
}
   
- (NSString*)_feedbackBody
{
    NSString *body = [NSString stringWithFormat:@"%@\n\n\nDevice:\n%@\n\niOS:\n%@\n\nApp:\n%@ %@",
                      _descriptionTextView.text,
                      [self _platformString],
                      [UIDevice currentDevice].systemVersion, 
                      [self _appName],
                      [self _appVersion], nil];

    return body;
}

- (NSString*)_selectedTopic
{
    return [topics objectAtIndex:_selectedTopicsIndex];
}

- (NSString*)_selectedTopicToSend
{
    return [topicsToSend objectAtIndex:_selectedTopicsIndex];
}

- (NSString*)_appName
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:
            @"CFBundleDisplayName"];
}

- (NSString*)_appVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

// Codes are from 
// http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk
// Thanks for sss and UIBuilder
- (NSString *) _platform
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

- (NSString *) _platformString
{
    NSString *platform = [self _platform];
    NSLog(@"%@",platform);
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad 4 (CDMA)";
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    return platform;
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

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    self.navigationItem.rightBarButtonItem = _doneButton;
}

- (void)keybaordWillHide:(NSNotification*)aNotification
{
    self.navigationItem.rightBarButtonItem = _mailButton;
}

- (void)onPushDone:(id)sender
{
    [_descriptionTextView resignFirstResponder];
}

- (BOOL)deleteTmpFile
{
    BOOL bResult = NO;
    
    // ファイルマネージャを作成
    NSError *error;
    NSString *tmpDirPath = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *deleteList = [fileManager contentsOfDirectoryAtPath:tmpDirPath
                                                           error:&error];
    if (!error) {
        for (NSString *fileName in deleteList) {
            NSString *filePath = [tmpDirPath stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:filePath error:&error];
        }
        DDLogInfo(@"作業ディレクトリのファイルを削除");
        bResult = YES;
    } else {
        DDLogError(@"作業ディレクトリのファイル一覧取得に失敗: %@", error);
        return bResult;
    }
    
    return bResult;
}

- (void)confirmSendLogFile:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"feedbackview.mailsend.confirm.title", @"send mail into log file confirm dialog title")
                                                    message:NSLocalizedString(@"feedbackview.mailsend.confirm.message", @"send mail into log file confirm dialog message")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"feedbackview.mailsend.confirm.cancel", @"send mail into log file confirm dialog cancel button")
                                          otherButtonTitles:NSLocalizedString(@"feedbackview.mailsend.confirm.nolog", @"send mail into log file confirm dialog not into button"),
                          NSLocalizedString(@"feedbackview.mailsend.confirm.intolog", @"send mail into log file confirm dialog into button"), nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self nextDidPress:NO];
    }
    else if (buttonIndex == 2) {
        [self nextDidPress:YES];
    }
}

- (NSString *)createZipLogFile:(NSString *)outputPath zipFileName:(NSString*)zipFileName logFileDir:(NSString *)logDirPath
{
    // ファイルマネージャを作成
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *zipOutputPath = [outputPath stringByAppendingPathComponent:zipFileName];
    NSArray *logFiles = [fileManager contentsOfDirectoryAtPath:logDirPath
                                                     error:&error];
    if (!error) {
        // ファイルやディレクトリの一覧を表示する
        NSMutableArray *logFilePathList = [[NSMutableArray alloc] init];
        for (NSString *fileName in logFiles) {
            NSString *filePath = [logDirPath stringByAppendingPathComponent:fileName];
            [logFilePathList addObject:filePath];
        }
        
        // ログファイルをzip圧縮
        BOOL bResult = [SSZipArchive createZipFileAtPath:zipOutputPath withFilesAtPaths:logFilePathList];
        if (bResult) {
            DDLogInfo(@"ログファイルをZIP圧縮しました");
            return zipOutputPath;
        } else {
            DDLogError(@"ログファイルのZIP圧縮に失敗しました");
            return nil;
        }
    } else {
        DDLogError(@"ログファイルディレクトリのファイル一覧取得に失敗しました: %@", error);
        return nil;
    }
    return nil;
}

@end
