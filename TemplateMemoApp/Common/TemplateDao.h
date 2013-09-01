//
//  TemplateDao.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/25.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "FMDBWrapper.h"
#import "TemplateMemo.h"

@protocol TemplateDao <NSObject>
- (NSArray *)templates;
- (BOOL)add:(TemplateMemo *)templateMemo;
- (BOOL)update:(TemplateMemo *)templateMemo;
- (BOOL)remove:(TemplateMemo *)templateMemo;
- (int)maxRefCount;
@end

@interface TemplateDaoImpl : NSObject<TemplateDao, FMDBUsable>

@end
