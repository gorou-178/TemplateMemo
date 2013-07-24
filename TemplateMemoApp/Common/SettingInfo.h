//
//  SettingInfo.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SettingDataSource;

// 設定データ(具体的なデータ)
@interface SettingData : NSObject <NSCoding, NSMutableCopying> {
 @protected
    int row;
    NSString *labelText;
}
@property (assign, nonatomic) int row;
@property (strong, nonatomic) NSString *labelText;
@end

// 設定情報(データ格納情報)
@interface SettingInfo : NSObject <NSMutableCopying> {
 @protected
    SettingDataSource *dataSource;
    SettingData *settingData;
    NSString *detailTitle;
    NSString *key;
}
@property (strong, nonatomic) SettingDataSource *dataSource;
@property (strong, nonatomic) SettingData *settingData;
@property (strong, nonatomic) NSString *detailTitle;
@property (strong, nonatomic) NSString *key;
@end

// 設定情報更新プロトコル
@protocol SettingUpdater <NSObject>
@required
- (BOOL)update:(SettingInfo *)settingInfo;
@end
