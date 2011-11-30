//
//  RelativeDate.m
//  iSTI
//
//  Created by David van Leeuwen on 08-02-11.
//  Copyright 2011 strApps. All rights reserved.
//

#define kNow 2.5
#define kMin 60
#define kHour 60
#define kDay 24

#import "RelativeDate.h"

@implementation NSDate (RelativeDate)

-(NSString*)relativeDate {
    NSDateComponents * dc = [[NSCalendar currentCalendar] components:NSWeekCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:self toDate:[NSDate date] options:0];
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	NSTimeInterval tdiff = -[self timeIntervalSinceNow];
    if (tdiff < 0 || tdiff > 7 * 24 * 3600) {
        df.dateStyle = NSDateFormatterMediumStyle;
        df.timeStyle = NSDateFormatterNoStyle;
        return [df stringFromDate:self];
    } else if (dc.day) {
        df.dateFormat = @"EEEE";
        return [df stringFromDate:self];
    } else if (dc.hour) {
        df.dateStyle = NSDateFormatterNoStyle;
        df.timeStyle = NSDateFormatterShortStyle;
        return [df stringFromDate:self];
    } else if (dc.minute) {
        return [NSString stringWithFormat:@"%d minute%@ ago",dc.minute, dc.minute==1 ? @"" : @"s"];
    }
    return @"just now";
    /* old implementation:
	NSTimeInterval tdiff = [self timeIntervalSinceNow];
	BOOL past = tdiff<0;
	NSString * tdir = (past) ? @"ago" : @"from now";
	if (past) tdiff *= -1.0;
	if (tdiff < kNow) return @"about now";
	if (tdiff < kMin ) return [NSString stringWithFormat:@"%1.0f seconds %@", tdiff, tdir];
	tdiff /= kMin;
	if (tdiff < kHour) 
		return [NSString stringWithFormat:@"%1.0f minutes %@", tdiff, tdir];
	tdiff /= kHour;
	NSDateFormatter * df = [[NSDateFormatter alloc] init];
	if (tdiff < kDay) {
		[df setDateStyle:NSDateFormatterNoStyle];
		[df setTimeStyle:NSDateFormatterShortStyle];
	} else {
		[df setDateStyle:NSDateFormatterMediumStyle];
		[df setTimeStyle:NSDateFormatterNoStyle];
		[df setDoesRelativeDateFormatting:YES];
	}
	NSString * res = [df stringFromDate:self];
	return res;
     */
}

-(NSString*)mediumDate {
    return [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}
-(NSString*)shortTime {
    return [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

-(NSString*) mediumshortDateTime {
    return [NSDateFormatter localizedStringFromDate:self dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
}

@end
