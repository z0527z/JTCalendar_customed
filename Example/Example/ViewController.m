//
//  ViewController.m
//  Example
//
//  Created by Jonathan Tribouharet.
//

#import "ViewController.h"

@interface ViewController (){
    NSMutableDictionary *eventsByDate;
//    NSMutableArray * selectedDateArray;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.calendar = [JTCalendar new];
    
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(200, 439, 115, 40);
    [btn setTitle:@"模式改变" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didChangeModeTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    // All modifications on calendarAppearance have to be done before setMenuMonthsView and setContentView
    // Or you will have to call reloadAppearance
    {
        NSDate * date = [NSDate date];
        NSDateFormatter * formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd";
        NSString * startDateString = [NSString stringWithFormat:@"%@ 00:00", [formatter stringFromDate:date]];
        NSString * endDateString = [NSString stringWithFormat:@"%@ 12:00", [formatter stringFromDate:date]];
        
        formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        NSDate * startDate = [formatter dateFromString:startDateString];
        NSDate * endDate = [formatter dateFromString:endDateString];
        [self.calendar.dateSelected addObject:endDate];
        [self.calendar.dateSelected addObject:startDate];
        
        
        float width = [UIScreen mainScreen].bounds.size.width;
        
        JTCalendarMenuView * menuView = [[JTCalendarMenuView alloc] initWithFrame:CGRectMake(0, 20, width, 50)];
        self.calendarMenuView = menuView;
        [self.view addSubview:menuView];
        
        JTCalendarContentView * contentView = [[JTCalendarContentView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(menuView.frame), width, 300)];
        self.calendarContentView = contentView;
        [self.view addSubview:contentView];
        
        
        self.calendar.calendarAppearance.calendar.firstWeekday = 1; // Sunday == 1, Saturday == 7
        self.calendar.calendarAppearance.dayCircleRatio = 6. / 10.;
        self.calendar.calendarAppearance.ratioContentMenu = 2.;
        self.calendar.calendarAppearance.dayDotColorSelected = [UIColor colorWithRed:0 green:204/255.0f blue:1.0f alpha:1.0f];
        
        self.calendar.calendarAppearance.monthBlock = ^NSString *(NSDate *date, JTCalendar *jt_calendar){
            NSCalendar *calendar = jt_calendar.calendarAppearance.calendar;
            NSDateComponents *comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date];
            NSInteger currentMonthIndex = comps.month;
            
            static NSDateFormatter *dateFormatter;
            if(!dateFormatter) {
                dateFormatter = [NSDateFormatter new];
                dateFormatter.timeZone = jt_calendar.calendarAppearance.calendar.timeZone;
            }
            
            while(currentMonthIndex <= 0){
                currentMonthIndex += 12;
            }
            
            NSString *monthText = [[dateFormatter standaloneMonthSymbols][currentMonthIndex - 1] capitalizedString];
            
            return [NSString stringWithFormat:@"%ld\n%@", comps.year, monthText];
        };
    }
    
    [self.calendar setMenuMonthsView:self.calendarMenuView];
    [self.calendar setContentView:self.calendarContentView];
    [self.calendar setDataSource:self];
    
    [self createRandomEvents];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.calendar reloadData]; // Must be call in viewDidAppear
}

#pragma mark - Buttons callback

- (IBAction)didGoTodayTouch
{
    [self.calendar setCurrentDate:[NSDate date]];
}

- (IBAction)didChangeModeTouch
{
    self.calendar.calendarAppearance.isWeekMode = !self.calendar.calendarAppearance.isWeekMode;
    
    [self transitionExample];
}

#pragma mark - JTCalendarDataSource

- (BOOL)calendarHaveEvent:(JTCalendar *)calendar date:(NSDate *)date
{
    NSString *key = [[self dateFormatter] stringFromDate:date];
    
    if(eventsByDate[key] && [eventsByDate[key] count] > 0){
        return YES;
    }
    
    return NO;
}

- (void)calendarDidDateSelected:(JTCalendar *)calendar date:(NSDate *)date
{
//    if (!selectedDateArray) {
//        selectedDateArray = [NSMutableArray new];
//        [selectedDateArray addObject:date];
//        return;
//    }
//    
//    if (![selectedDateArray containsObject:date]) {
//        NSComparisonResult result = [date compare:selectedDateArray.firstObject];
//        if (result == NSOrderedAscending) {
//            [selectedDateArray insertObject:date atIndex:0];
//        }
//        else {
//            if ([date compare:selectedDateArray.lastObject] == NSOrderedDescending) {
//                [selectedDateArray addObject:date];
//            }
//        }
//    }
//    
//    selectedDateArray;
    NSArray * dateSelected = self.calendar.dateSelected;
    NSLog(@"dateSelected:%@", dateSelected);
//    NSString *key = [[self dateFormatter] stringFromDate:date];
//    NSArray *events = eventsByDate[key];
//    
//    NSLog(@"Date: %@ - %ld events", date, [events count]);
}

- (void)calendarDidLoadPreviousPage
{
    NSLog(@"Previous page loaded");
}

- (void)calendarDidLoadNextPage
{
    NSLog(@"Next page loaded");
}

#pragma mark - Transition examples

- (void)transitionExample
{
    CGFloat newHeight = 300;
    CGRect rect = self.calendarContentView.frame;
    if(self.calendar.calendarAppearance.isWeekMode){
        newHeight = 75.;
        rect.size.height = 75.0f;
    }
    else {
        rect.size.height = 300.0f;
    }
    
    [UIView animateWithDuration:.5
                     animations:^{
//                         self.calendarContentViewHeight.constant = newHeight;
                        
                         self.calendarContentView.frame = rect;
                         [self.view layoutIfNeeded];
                     }];
    [UIView animateWithDuration:.25
                     animations:^{
                         self.calendarContentView.layer.opacity = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.calendar reloadAppearance];
                         
                         [UIView animateWithDuration:.25
                                          animations:^{
                                              self.calendarContentView.layer.opacity = 1;
                                          }];
                     }];

}

#pragma mark - Fake data

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"dd-MM-yyyy";
    }
    
    return dateFormatter;
}

- (void)createRandomEvents
{
    eventsByDate = [NSMutableDictionary new];
    
//    for(int i = 0; i < 30; ++i){
//        // Generate 30 random dates between now and 60 days later
//        NSDate *randomDate = [NSDate dateWithTimeInterval:(rand() % (3600 * 24 * 60)) sinceDate:[NSDate date]];
//        
//        // Use the date as key for eventsByDate
//        NSString *key = [[self dateFormatter] stringFromDate:randomDate];
//        
//        if(!eventsByDate[key]){
//            eventsByDate[key] = [NSMutableArray new];
//        }
//             
//        [eventsByDate[key] addObject:randomDate];
//    }
    NSDate * todayDate = [NSDate date];
    NSString * key = [[self dateFormatter] stringFromDate:todayDate];
    if (!eventsByDate[key]) {
        eventsByDate[key] = [NSMutableArray new];
    }
    
    [eventsByDate[key] addObject:todayDate];
    
//    [eventsByDate setObject:@[@"2015-01-11 10:55:18 +0000"] forKey:@"11-01-2015"];
//    [eventsByDate setObject:@[@"2015-01-25 10:55:18 +0000"] forKey:@"25-01-2015"];
}

@end
