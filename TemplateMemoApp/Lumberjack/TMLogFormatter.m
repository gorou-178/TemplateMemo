//
//  TMLogFormatter.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/08/13.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "TMLogFormatter.h"
#import "DateUtil.h"

@implementation TMLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->logFlag)
    {
        case LOG_FLAG_ERROR   : logLevel = @"ERROR"; break;
        case LOG_FLAG_WARN    : logLevel = @" WARN"; break;
        case LOG_FLAG_INFO    : logLevel = @" INFO"; break;
        case LOG_FLAG_VERBOSE : logLevel = @" VERB"; break;
        default               : logLevel = @"     "; break;
    }
    
    NSString *strDate = [DateUtil dateToString:logMessage->timestamp atDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    return [NSString stringWithFormat:@"[%@] %@ %@\n", strDate, logLevel, logMessage->logMsg];
}

@end
