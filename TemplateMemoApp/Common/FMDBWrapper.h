//
//  FMDBWrapper.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/10.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface FMDBWrapper : NSObject
{
@protected
    NSString* strDBFilePath;
    FMDatabase *db;
}
- (id)init;
- (id)initWithDataBaseFileName:(NSString *)fileName;
- (void)dealloc;

- (BOOL)open;

@end
