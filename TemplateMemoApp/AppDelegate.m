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

#import "TMAppContext.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        splitViewController.delegate = (id)navigationController.topViewController;
    }
    
    [TMAppContext sharedManager];
    
#if DEBUG
    // NSUserDefaultsのデータを全て削除
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
#endif
    
    // デフォルト設定を登録
    FontSizeSettingInfo *fontSizeSettingInfo = [[FontSizeSettingInfo alloc] init];
    FontSize *fontSize = [[FontSize alloc] init];
    fontSize.row = 0;
    fontSize.size = 14;
    fontSize.labelText = [[NSString alloc] initWithFormat:@"最小(%gpt)", fontSize.size];
    
    FontSettingInfo *fontSettingInfo = [[FontSettingInfo alloc] init];
    Font *systemFont = [[Font alloc] init];
    systemFont.uiFont = [UIFont systemFontOfSize:fontSize.size];
    systemFont.row = 0;
    systemFont.name = [systemFont.uiFont fontName];
    systemFont.labelText = [systemFont.uiFont familyName];
    
    TemplateMemoSettingInfo *templateMemoSettingInfo = [[TemplateMemoSettingInfo alloc] init];
    TemplateMemo *templateMemo = [[TemplateMemo alloc] init];
    templateMemo.row = 0;
    templateMemo.name = @"なし";
    templateMemo.labelText = @"なし";
    
    FontSize *loadFontSize = [UserDefaultsWrapper loadToObject:fontSizeSettingInfo.key];
    if (loadFontSize == nil) {
        [UserDefaultsWrapper save:fontSizeSettingInfo.key toObject:fontSize];
    }
    
    Font *loadFont = [UserDefaultsWrapper loadToObject:fontSettingInfo.key];
    if (loadFont == nil) {
        [UserDefaultsWrapper save:fontSettingInfo.key toObject:systemFont];
    }
    
    TemplateMemo *loadTemplateMemo = [UserDefaultsWrapper loadToObject:templateMemoSettingInfo.key];
    if (loadTemplateMemo == nil) {
        [UserDefaultsWrapper save:templateMemoSettingInfo.key toObject:templateMemo];
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    FMDBWrapper *fmdbWrapper = [[FMDBWrapper alloc] init];
    if ([fmdbWrapper open]) {
        if ([fmdbWrapper vacuum]) {
            NSLog(@"SQLite: 最適化完了");
        }
    }
}

@end
