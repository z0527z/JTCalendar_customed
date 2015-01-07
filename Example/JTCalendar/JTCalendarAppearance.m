//
//  JTCalendarAppearance.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarAppearance.h"

#import "JTCalendar.h"

@implementation JTCalendarAppearance

- (instancetype)init
{
    self = [super init];
    if(!self){
        return nil;
    }
        
    [self setDefaultValues];
    
    return self;
}

- (void)setDefaultValues
{
    self.isWeekMode = NO;
    
    self.weekDayFormat = JTCalendarWeekDayFormatShort;
    self.useCacheSystem = YES;
    
    self.ratioContentMenu = 2.;
    self.autoChangeMonth = YES;
    
    self.dayCircleRatio = 1.;
    self.dayDotRatio = 1. / 9.;
    
    self.menuMonthTextFont = [UIFont systemFontOfSize:17.];
    self.weekDayTextFont = [UIFont systemFontOfSize:12];
    self.dayTextFont = [UIFont systemFontOfSize:17.0f];//[UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    self.menuMonthTextColor = [UIColor blackColor];
    self.weekDayTextColor = [UIColor colorWithRed:152./256. green:147./256. blue:157./256. alpha:1.];
    
    [self setDayDotColorForAll:[UIColor colorWithRed:43./256. green:88./256. blue:134./256. alpha:1.]];
    [self setDayTextColorForAll:[UIColor blackColor]];
    
    self.dayTextColorOtherMonth = [UIColor colorWithRed:152./256. green:147./256. blue:157./256. alpha:1.];

    self.dayCircleColorSelected = [UIColor colorWithRed:136/255.0f green:228/255.0f blue:251/255.0f alpha:0.5f];//[UIColor redColor];
    self.dayTextColorSelected = [UIColor whiteColor];
    self.dayDotColorSelected = self.dayDotColor;
    
    // dql
    [self setFeastTextColorForAll:[UIColor blackColor]];
    self.feastTextColorOtherMonth = self.dayTextColorOtherMonth;
    self.feastTextColorToday = self.dayTextColorToday;
    self.feastTextColorTodayOtherMonth = self.dayTextColorTodayOtherMonth;
    self.feastTextColorSelected = self.feastTextColor;
    self.feastTextColorSelectedOtherMonth = self.feastTextColor;
    
    self.dayCircleColorSelectedOtherMonth = self.dayCircleColorSelected;
    self.dayTextColorSelectedOtherMonth = self.dayTextColorSelected;
    self.dayDotColorSelectedOtherMonth = self.dayDotColorSelected;
    
    self.dayCircleColorToday = [UIColor colorWithRed:0 green:204/255.0f blue:1.0f alpha:1.0f]; // [UIColor whiteColor];
    self.dayTextColorToday = [UIColor whiteColor];
    self.dayDotColorToday = [UIColor colorWithRed:0 green:204/255.0f blue:1.0f alpha:1.0f];//[UIColor whiteColor];
    
    self.dayCircleColorTodayOtherMonth = self.dayCircleColorToday;
    self.dayTextColorTodayOtherMonth = self.dayTextColorToday;
    self.dayDotColorTodayOtherMonth = self.dayDotColorToday;
    
    self.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
        NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
        NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
        NSInteger currentMonthIndex = comps.month;
        
        static NSDateFormatter *dateFormatter;
        if(!dateFormatter){
            dateFormatter = [NSDateFormatter new];
            dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
        }
        
        while(currentMonthIndex <= 0){
            currentMonthIndex += 12;
        }
        
        return [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
    };
}

- (NSCalendar *)calendar
{
    static NSCalendar *calendar;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
#ifdef __IPHONE_8_0
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
#else
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
#endif
        calendar.timeZone = [NSTimeZone localTimeZone];
    });
    
    return calendar;
}

- (void)setDayDotColorForAll:(UIColor *)dotColor
{
    self.dayDotColor = dotColor;
    self.dayDotColorSelected = dotColor;
    
    self.dayDotColorOtherMonth = dotColor;
    self.dayDotColorSelectedOtherMonth = dotColor;
    
    self.dayDotColorToday = dotColor;
    self.dayDotColorTodayOtherMonth = dotColor;
}

- (void)setDayTextColorForAll:(UIColor *)textColor
{
    self.dayTextColor = textColor;
    self.dayTextColorSelected = textColor;
    
    self.dayTextColorOtherMonth = textColor;
    self.dayTextColorSelectedOtherMonth = textColor;
    
    self.dayTextColorToday = textColor;
    self.dayTextColorTodayOtherMonth = textColor;
}

- (void)setFeastTextColorForAll:(UIColor *)feastColor
{
    self.feastTextColor = feastColor;
    self.feastTextColorSelected = feastColor;
    
    self.feastTextColorOtherMonth = feastColor;
    self.feastTextColorSelectedOtherMonth = feastColor;
    
    self.feastTextColorToday = feastColor;
    self.feastTextColorTodayOtherMonth = feastColor;
}

@end
