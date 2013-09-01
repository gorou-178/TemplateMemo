//
//  DateUtil.h
//  TemplateMemoApp
//
//  Created by gurimmer on 2013/07/10.
//  Copyright (c) 2013年 gurimmer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtil : NSObject

// 日付を文字列に変換
+ (NSString *)dateToString:(NSDate *)date atDateFormat:(NSString *)format;
+ (NSString *)dateToString:(NSDate *)date atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone;
+ (NSString *)dateToString:(NSDate *)date atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone setLocale:(NSLocale *)locale;
+ (NSString *)dateToString:(NSDate *)date atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone setLocale:(NSLocale *)locale setCalendar:(NSCalendar *)calendar;

// 文字列を日付に変換
+ (NSDate *)dateStringToDate:(NSString *)strDate atDateFormat:(NSString *)format;
+ (NSDate *)dateStringToDate:(NSString *)strDate atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone;
+ (NSDate *)dateStringToDate:(NSString *)strDate atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone setLocale:(NSLocale *)locale;
+ (NSDate *)dateStringToDate:(NSString *)strDate atDateFormat:(NSString *)format setTimeZone:(NSTimeZone *)timeZone setLocale:(NSLocale *)locale setCalendar:(NSCalendar *)calendar;

// 現在日付
+ (NSDate *)nowDateForSystemTimeZone;
+ (NSDate *)nowDateForDefaultTimeZone;
+ (NSDate *)nowDateForLocalTimeZone;
+ (NSDate *)nowDate:(NSTimeZone *)timeZone;

@end
