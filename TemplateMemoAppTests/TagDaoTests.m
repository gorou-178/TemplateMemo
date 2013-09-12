//
//  TagDaoTests.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/09/09.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TagDaoTests.h"
#import "TagDao.h"
#import "Tag.h"
#import "TagLink.h"
#import "Memo.h"
#import "DateUtil.h"

@interface TagDaoTests ()
{
    FMDBWrapper *_fmdb;
    id<TagDao> _tagDao;
}
@end

@implementation TagDaoTests

#pragma mark - Clean up Method

- (void)setUp
{
    [super setUp];
    
    if (!_fmdb) {
        _fmdb = [[FMDBWrapper alloc] initWithDataBaseFileName:@"test_database"];
        _tagDao = [[TagDaoImpl alloc] initWithFMDBWrapper:_fmdb];
    }
}

- (void)tearDown
{
    // Tear-down code here.
    [self _deleteAll];
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testAddTag
{
    NSArray *tags = [self _createTestTag:3 deleteFlag:NO];
    BOOL bResult = NO;
    for (Tag *tag in tags) {
        bResult = [_tagDao add:tag];
        if (!bResult) {
            STFail(@"tag add fail");
        }
    }
}

- (void)testTags
{
    NSArray *tags = [self _createTestTag:3 deleteFlag:NO];
    BOOL bResult = NO;
    for (Tag *tag in tags) {
        bResult = [_tagDao add:tag];
        if (!bResult) {
            STFail(@"tag add fail");
        }
    }
    
    NSArray *resultTags = [_tagDao tags];
    
    STAssertEquals(tags.count, resultTags.count, @"addTag resultTag miss match count");
    
    for (NSInteger i = 0; i < resultTags.count; i++) {
        STAssertEqualObjects(tags[i], resultTags[i], @"addTag resultTag not equal tag");
    }
}

- (void)testRemoveTag
{
    NSArray *tags = [self _createTestTag:6 deleteFlag:NO];
    BOOL bResult = NO;
    for (Tag *tag in tags) {
        bResult = [_tagDao add:tag];
        if (!bResult) {
            STFail(@"tag add fail");
        }
    }
    
    for (NSInteger i = 3; i < 6; i++) {
        bResult = [_tagDao remove:tags[i]];
        if (!bResult) {
            STFail(@"tag remove fail");
        }
    }

    NSArray *resultTags = [_tagDao tags];
    for (NSInteger i = 0; i < 3; i++) {
        STAssertEqualObjects(tags[i], resultTags[i], @"addTag resultTag not equal tag");
    }
}

#pragma mark - Private

- (BOOL)_deleteAll
{
    BOOL bResult = [_fmdb.db executeUpdate:@"delete from tag"];
    if (bResult) {
        NSLog(@"TagDao - tearDown db reset");
    } else {
        NSLog(@"TagDao - ERROR tearDown db reset fails");
    }
    return bResult;
}

- (NSArray *)_createTestTag:(NSInteger) count deleteFlag:(NSInteger) flag
{
    NSMutableArray *tags = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i <= count; i++) {
        Tag *tag = [[Tag alloc] init];
        tag.tagId = i;
        tag.name = [[NSString alloc] initWithFormat:@"タグ%d", i];
        tag.posision = i;
        tag.createDate = [DateUtil nowDateForLocalTimeZone];
        tag.modifiedDate = [DateUtil nowDateForLocalTimeZone];
        tag.deleteFlag = flag;
        [tags addObject:tag];
    }
    return tags;
}

- (NSArray *)_createTestMemo:(NSInteger) count deleteFlag:(NSInteger) flag
{
    NSMutableArray *memos = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i <= count; i++) {
        Memo *memo = [[Memo alloc] init];
        memo.memoid = i;
        memo.body = [[NSString alloc] initWithFormat:@"メモ本文%d", i];
        memo.createDate = [DateUtil nowDateForLocalTimeZone];
        memo.modifiedDate = [DateUtil nowDateForLocalTimeZone];
        memo.deleteFlag = flag;
        [memos addObject:memo];
    }
    return memos;
}

@end
