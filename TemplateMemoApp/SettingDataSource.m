//
//  SettingDataSource.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/21.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "SettingDataSource.h"
#import "UserDefaultsWrapper.h"

@implementation SettingDataSource

- (void)updateCellData:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath tableViewCell:(UITableViewCell *)cell
{
    // No Implements
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifer];
    }
    [self updateCellData:tableView cellForRowAtIndexPath:indexPath tableViewCell:cell];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)update:(SettingInfo *)settingInfo
{
    NSLog(@"SettingDataSource: update");
    [UserDefaultsWrapper save:settingInfo.key toObject:settingInfo.settingData];
    return YES;
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    SettingDataSource *mutableCopy = [[[self class] allocWithZone:zone] init];
    mutableCopy.dataList = [self.dataList mutableCopy];
    return mutableCopy;
}

@end
