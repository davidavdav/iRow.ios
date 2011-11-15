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
    if (dc.week) {
        df.dateStyle = NSDateFormatterShortStyle;
        df.timeStyle = NSDateFormatterNoStyle;
        return [df stringFromDate:self];
    } else if (dc.day) {
        return [NSString stringWithFormat:@"%d days ago",dc.day];
    } else if (dc.hour) {
        return [NSString stringWithFormat:@"%d hours ago",dc.hour];
    } else if (dc.minute) {
        return [NSString stringWithFormat:@"%d minutes ago",dc.minute];
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

@end
