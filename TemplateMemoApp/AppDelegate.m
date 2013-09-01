//
//  AppDelegate.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/06/02.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "AppDelegate.h"
#import "FMDBWrapper.h"

#import "Font.h"
#import "FontSize.h"
#import "TemplateMemo.h"
#import "FontSettingInfo.h"
#import "FontSizeSettingInfo.h"
#import "TemplateMemoSettingInfo.h"

#import "UserDefaultsWrapper.h"

#import "DDFileLogger.h"
#import "DDTTYLogger.h"
#import "TMLogFormatter.h"

#import "TagDao.h"
#import "TemplateDao.h"
#import "UIDeviceHelper.h"

#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

- (id)init
{
    self = [super init];
    if (self) {
        // 各ControllerのawakeFromNibがdidFinishLaunchingWithOptionsより先に呼ばれるためここで生成
        self.fmdb = [[FMDBWrapper alloc] init];
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *logDirPath = [documentPaths objectAtIndex:0];
    logDirPath = [[NSString alloc] initWithString:[logDirPath stringByAppendingPathComponent:@"logs"]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:[[DDLogFileManagerDefault alloc] initWithLogsDirectory:logDirPath]];
    fileLogger.logFormatter = [[TMLogFormatter alloc] init];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:fileLogger];
    
    DDLogInfo(@"AppDelegate: アプリ起動");
    DDLogVerbose(@"AppDelegate: ログ保存先 >> %@", logDirPath);
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    
//#if DEBUG
//    // NSUserDefaultsのデータを全て削除
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
//#endif
    
    // デフォルト設定を登録
    FontSizeSettingInfo *fontSizeSettingInfo = [[FontSizeSettingInfo alloc] init];
    FontSize *fontSize = [[FontSize alloc] init];
    fontSize.row = 1;
    fontSize.size = [UIFont systemFontSize];
    fontSize.labelText = [[NSString alloc] initWithFormat:NSLocalizedString(@"setting.fontsize.small", @"setting fontsize - small"), fontSize.size];
    
    FontSettingInfo *fontSettingInfo = [[FontSettingInfo alloc] init];
    Font *defaultFont = [[Font alloc] init];
    if ([UIDeviceHelper isJapaneseLanguage]) {
        defaultFont.uiFont = [UIFont fontWithName:@"BokutachinoGothic" size:fontSize.size];
        defaultFont.row = 2;
        defaultFont.name = [defaultFont.uiFont fontName];
        defaultFont.labelText = @"ぼくたちのゴシック";
    }
    else {
        defaultFont.uiFont = [UIFont systemFontOfSize:fontSize.size];
        defaultFont.row = 0;
        defaultFont.name = [defaultFont.uiFont fontName];
        defaultFont.labelText = [defaultFont.uiFont familyName];
    }
    
    TemplateMemoSettingInfo *templateMemoSettingInfo = [[TemplateMemoSettingInfo alloc] init];
    TemplateMemo *templateMemo = [[TemplateMemo alloc] init];
    templateMemo.row = 0;
    templateMemo.name = NSLocalizedString(@"setting.template.label.none", @"setting template label - none");
    templateMemo.labelText = NSLocalizedString(@"setting.template.name.none", @"setting template label - none");
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"firstLaunch",nil]];
    
    FontSize *loadFontSize = [UserDefaultsWrapper loadToObject:fontSizeSettingInfo.key];
    if (loadFontSize == nil) {
        [UserDefaultsWrapper save:fontSizeSettingInfo.key toObject:fontSize];
    }
    
    Font *loadFont = [UserDefaultsWrapper loadToObject:fontSettingInfo.key];
    if (loadFont == nil) {
        [UserDefaultsWrapper save:fontSettingInfo.key toObject:defaultFont];
    }
    
    TemplateMemo *loadTemplateMemo = [UserDefaultsWrapper loadToObject:templateMemoSettingInfo.key];
    if (loadTemplateMemo == nil) {
        [UserDefaultsWrapper save:templateMemoSettingInfo.key toObject:templateMemo];
    }
    
    // 初期データ
    id<TagDao> tagDao = [[TagDaoImpl alloc] initWithFMDBWrapper:_fmdb];
    id<TemplateDao> templateDao = [[TemplateDaoImpl alloc] initWithFMDBWrapper:_fmdb];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        Tag *todo = [[Tag alloc] init];
        todo.name = @"TODO";
        todo.posision = 1;
        [tagDao add:todo];
        
        TemplateMemo *sample = [[TemplateMemo alloc] init];
        sample.name = NSLocalizedString(@"templateview.sample.name", @"templateview first lunch sample template name");
        sample.body = NSLocalizedString(@"templateview.sample.body", @"templateview first lunch sample template body");;
        [templateDao add:sample];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    }

    [Crashlytics startWithAPIKey:@"4ecc495945d8e304a61450176eac3359c478aa8c"];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLogInfo(@"AppDelegate: アプリ停止");
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DDLogInfo(@"AppDelegate: アプリ復帰");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    DDLogInfo(@"AppDelegate: アプリ終了");
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
    
    FMDBWrapper *fmdbWrapper = [[FMDBWrapper alloc] init];
    if ([fmdbWrapper open]) {
        if ([fmdbWrapper vacuum]) {
            DDLogInfo(@"AppDelegate: DB最適化完了");
        }
    }
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
