//
//  DateUtil.m
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/10.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import "DateUtil.h"

@implementation DateUtil

+ (NSString *)dateToString:(NSDate *)date atDateFormat:(NSString *)format
{
    return [DateUtil dateToString:date atDateFormat:format setTimeZone:[NSTimeZone systemTimeZone]];
}

+ (NSString *)dateToString:(NSDate *)date atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone
{
    return [DateUtil dateToString:date atDateFormat:format setTimeZone:timeZone setLocale:[NSLocale currentLocale]];
}

+ (NSString *)dateToString:(NSDate *)date atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone setLocale:(NSLocale *)locale
{
    return [DateUtil dateToString:date atDateFormat:format setTimeZone:timeZone setLocale:locale setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
}

+ (NSString *)dateToString:(NSDate *)date atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone setLocale:(NSLocale *)locale setCalendar:(NSCalendar *)calendar
{
    if (date == nil || format == nil) {
        return nil;
    }
    
    // システムのタイムゾーンを設定(12時間表示のバグ回避)
    if (timeZone == nil) {
        timeZone = [NSTimeZone systemTimeZone];
    }
    
    // ロケールを設定(12時間表示のバグ回避 + 曜日表示)
    if (locale == nil) {
        locale = [NSLocale currentLocale];
    }
    
    // グレゴリオ暦のカレンダーを設定(和暦表示バグ回避のため)
    if (calendar == nil) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:locale];
    [formatter setTimeZone:timeZone];
    [formatter setCalendar:calendar];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}


+ (NSDate *)dateStringToDate:(NSString *)strDate atDateFormat:(NSString *)format
{
    return [DateUtil dateStringToDate:strDate atDateFormat:format setTimeZone:[NSTimeZone systemTimeZone]];
}

+ (NSDate *)dateStringToDate:(NSString *)strDate atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone
{
    return [DateUtil dateStringToDate:strDate atDateFormat:format setTimeZone:timeZone setLocale:[NSLocale currentLocale]];
}

+ (NSDate *)dateStringToDate:(NSString *)strDate atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone setLocale:(NSLocale *)locale
{
    return [DateUtil dateStringToDate:strDate atDateFormat:format setTimeZone:timeZone setLocale:locale setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]];
}

+ (NSDate *)dateStringToDate:(NSString *)strDate atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone setLocale:(NSLocale *)locale setCalendar:(NSCalendar *)calendar
{
    if (strDate == nil || format == nil) {
        return nil;
    }
    
    // システムのタイムゾーンを設定
    if (timeZone == nil) {
        timeZone = [NSTimeZone systemTimeZone];
    }
    
    // ロケールを設定
    if (locale == nil) {
        locale = [NSLocale currentLocale];
    }
    
    // グレゴリオ暦のカレンダーを設定
    if (calendar == nil) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:locale];
    [formatter setTimeZone:timeZone];
    [formatter setCalendar:calendar];
    [formatter setDateFormat:format];
    return [formatter dateFromString:strDate];
}

+ (NSDate *)nowDateForSystemTimeZone
{
    return [self nowDate:[NSTimeZone systemTimeZone]];
}

+ (NSDate *)nowDateForDefaultTimeZone
{
    return [self nowDate:[NSTimeZone defaultTimeZone]];
}

+ (NSDate *)nowDateForLocalTimeZone
{
    return [self nowDate:[NSTimeZone localTimeZone]];
}

+ (NSDate *)nowDate:(NSTimeZone *)timeZone
{
    return [NSDate dateWithTimeIntervalSinceNow:[timeZone secondsFromGMT]];
}

@end
