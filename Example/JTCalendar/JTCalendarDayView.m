//
//  JTCalendarDayView.m
//  JTCalendar
//
//  Created by Jonathan Tribouharet
//

#import "JTCalendarDayView.h"

#import "JTCircleView.h"

@interface JTCalendarDayView (){
    JTCircleView *circleView;
    UILabel *textLabel;
    UILabel *feastLabel;
    JTCircleView *dotView;
    
    BOOL isSelected;
    
    int cacheIsToday;
    NSString *cacheCurrentDateText;
    NSString *selectedDateText[2];
}
@end

static NSString *const kJTCalendarDaySelected = @"kJTCalendarDaySelected";

@implementation JTCalendarDayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

- (void)commonInit
{
    isSelected = NO;
    self.isOtherMonth = NO;
    
    {
        circleView = [JTCircleView new];
        [self addSubview:circleView];
    }
    
    {
        textLabel = [UILabel new];
        [self addSubview:textLabel];
    }
    
    {
        feastLabel = [UILabel new];
        [self addSubview:feastLabel];
    }
    
    {
        dotView = [JTCircleView new];
        [self addSubview:dotView];
        dotView.hidden = YES;
    }
    
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch)];

        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:gesture];
    }
    
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDaySelected:) name:kJTCalendarDaySelected object:nil];
    }
}

- (void)layoutSubviews
{
    [self configureConstraintsForSubviews];
    
    // No need to call [super layoutSubviews]
}

// Avoid to calcul constraints (very expensive)
- (void)configureConstraintsForSubviews
{
    textLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    CGFloat sizeCircle = MIN(self.frame.size.width, self.frame.size.height);
    CGFloat sizeDot = sizeCircle;
    
    sizeCircle = sizeCircle * self.calendarManager.calendarAppearance.dayCircleRatio;
    sizeDot = sizeDot * self.calendarManager.calendarAppearance.dayDotRatio;
    
    sizeCircle = roundf(sizeCircle);
    sizeDot = roundf(sizeDot);
    
    circleView.frame = CGRectMake(0, 0, sizeCircle, sizeCircle);
    circleView.center = CGPointMake(self.frame.size.width / 2., self.frame.size.height / 2.);
    circleView.layer.cornerRadius = sizeCircle / 2.;
    
    // dql
    feastLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) * 0.5);
    feastLabel.textAlignment = NSTextAlignmentCenter;
    feastLabel.font = [UIFont systemFontOfSize:8.0f];
    feastLabel.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.85);
    if (self.calendarManager.calendarAppearance.isWeekMode) {
        feastLabel.hidden = YES;
    }
    else {
        feastLabel.hidden = NO;
    }

    dotView.frame = CGRectMake(0, 0, sizeDot, sizeDot);
    dotView.center = CGPointMake(self.frame.size.width / 2., (self.frame.size.height / 2.) + sizeDot * 2.5 * 1.8);
    dotView.layer.cornerRadius = sizeDot / 2.;
}

- (void)setDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = self.calendarManager.calendarAppearance.calendar.timeZone;
        [dateFormatter setDateFormat:@"d"];
    }
    
    self->_date = date;
    
    textLabel.text = [dateFormatter stringFromDate:date];
    //dql
    NSString * feastString = [self getLunarHoliDayDate:date];
    if (feastLabel) {
        feastLabel.text = feastString;
    }
    
    cacheIsToday = -1;
    cacheCurrentDateText = nil;
}

- (NSString *)getLunarHoliDayDate:(NSDate *)date
{
    NSTimeInterval timeInterval_day = (float)(60*60*24);
    NSDate *nextDay_date = [NSDate dateWithTimeInterval:timeInterval_day sinceDate:date];
    //dql
    NSCalendar * feastCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierRepublicOfChina];
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:nextDay_date];
    
    NSString * resultString = nil;
    if ( 1 == localeComp.month && 1 == localeComp.day ) {
        resultString = @"除夕";
    }
    else {
        NSDictionary *chineseHoliDay = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"春节", @"1-1",
                                        @"元宵", @"1-15",
                                        @"端午", @"5-5",
                                        @"七夕", @"7-7",
                                        @"中元", @"7-15",
                                        @"中秋", @"8-15",
                                        @"重阳", @"9-9",
                                        @"腊八", @"12-8",
                                        @"小年", @"12-24",
                                        nil];
        
        localeComp = [localeCalendar components:unitFlags fromDate:date];
        NSString *key_str = [NSString stringWithFormat:@"%ld-%ld",(long)localeComp.month,(long)localeComp.day];
        resultString = [chineseHoliDay objectForKey:key_str];
    }
    //dql
    if (!resultString) {
        NSDictionary * feastDict = @{@"1-1" : @"元旦",
                                     @"3-8" : @"妇女节",
                                     @"3-12" : @"植树节",
                                     @"4-1" : @"愚人节",
                                     @"5-1" : @"劳动节",
                                     @"5-4" : @"青年节",
                                     @"6-1" : @"儿童节",
                                     @"7-1" : @"建党节",
                                     @"8-1" : @"建军节",
                                     @"9-10" : @"教师节",
                                     @"10-1" : @"国庆节",
                                     @"12-24" : @"平安夜",
                                     @"12-25" : @"圣诞节"};
        NSDateComponents * feastComp = [feastCalendar components:unitFlags fromDate:date];
        NSString * key = [NSString stringWithFormat:@"%ld-%ld", (long)feastComp.month, (long)feastComp.day];
        resultString = feastDict[key];
    }
    
    return resultString;
}

- (void)didTouch
{
    [self setSelected:isSelected animated:YES];
    
//    [self.calendarManager setCurrentDateSelected:self.date];

    // dql
    [self addDateForSelected:self.date];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kJTCalendarDaySelected object:self.date];
    [self didDaySelected:self.date];
    
    [self.calendarManager.dataSource calendarDidDateSelected:self.calendarManager date:self.date];
    
    if(!self.isOtherMonth || !self.calendarManager.calendarAppearance.autoChangeMonth){
        return;
    }
    
    NSInteger currentMonthIndex = [self monthIndexForDate:self.date];
    NSInteger calendarMonthIndex = [self monthIndexForDate:self.calendarManager.currentDate];
        
    currentMonthIndex = currentMonthIndex % 12;
    
    if(currentMonthIndex == (calendarMonthIndex + 1) % 12){
        [self.calendarManager loadNextMonth];
    }
    else if(currentMonthIndex == (calendarMonthIndex + 12 - 1) % 12){
        [self.calendarManager loadPreviousMonth];
    }
}

// dql
- (void)addDateForSelected:(NSDate *)date
{
    if (self.calendarManager.dateSelected.count == 0) {
        [self.calendarManager.dateSelected addObject:date];
    }
    else if (self.calendarManager.dateSelected.count < 2) {
        NSDate * startDate = [self.calendarManager.dateSelected firstObject];
        NSTimeInterval interval = [startDate timeIntervalSinceDate:date];
        if (interval < 0) {
            [self.calendarManager.dateSelected insertObject:date atIndex:0];
        }
        else if (interval > 0) {
            [self.calendarManager.dateSelected addObject:date];
        }
    }
    else if (self.calendarManager.dateSelected.count == 2 && ![self.calendarManager.dateSelected containsObject:date])
    {
//        NSDate * startDate = [self.calendarManager.dateSelected firstObject];
//        NSTimeInterval interval = [startDate timeIntervalSinceDate:date];
//        if (interval < 0) {
//            [self.calendarManager.dateSelected replaceObjectAtIndex:0 withObject:date];
//        }
//        else {
//            NSDate * secondDate = [self.calendarManager.dateSelected lastObject];
//            NSTimeInterval val = [secondDate timeIntervalSinceDate:date];
//            if (val > 0) {
//                [self.calendarManager.dateSelected replaceObjectAtIndex:1 withObject:date];
//            }
//        }
    }
}
// dql
- (void)didDaySelected:(NSDate *)dateSelected
{
    //    if([self isSameDate:dateSelected]){
    if ([self isContainDate:dateSelected]) {
        if(!isSelected){
            [self setSelected:YES animated:YES];
        }
        else {
            [self setSelected:NO animated:YES];
            [self.calendarManager.dateSelected removeObject:dateSelected];
        }
    }
    else if(isSelected){
        [self setSelected:NO animated:YES];
    }
}

//- (void)didDaySelected:(NSNotification *)notification
//{
//    NSDate *dateSelected = [notification object];
//    
////    if([self isSameDate:dateSelected]){
//    if ([self isContainDate:dateSelected]) {
//        if(!isSelected){
//            [self setSelected:YES animated:YES];
//        }
//    }
//    else if(isSelected){
//        [self setSelected:NO animated:YES];
//    }
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if(isSelected == selected){
        animated = NO;
    }
    
    isSelected = selected;
    
    circleView.transform = CGAffineTransformIdentity;
    CGAffineTransform tr = CGAffineTransformIdentity;
    CGFloat opacity = 1.;
    
    if(selected){
        if(!self.isOtherMonth){
            circleView.color = [self.calendarManager.calendarAppearance dayCircleColorSelected];
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorSelected];
            //dql
            feastLabel.textColor = [self.calendarManager.calendarAppearance feastTextColorSelected];
            dotView.color = [self.calendarManager.calendarAppearance dayDotColorSelected];
        }
        else{
            circleView.color = [self.calendarManager.calendarAppearance dayCircleColorSelectedOtherMonth];
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorSelectedOtherMonth];
            feastLabel.textColor = [self.calendarManager.calendarAppearance feastTextColorSelectedOtherMonth];
            dotView.color = [self.calendarManager.calendarAppearance dayDotColorSelectedOtherMonth];
        }
        
        circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1);
        tr = CGAffineTransformIdentity;
    }
    else if([self isToday]){
        if(!self.isOtherMonth){
            circleView.color = [self.calendarManager.calendarAppearance dayCircleColorToday];
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorToday];
            feastLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorToday];
            dotView.color = [self.calendarManager.calendarAppearance dayDotColorToday];
        }
        else{
            circleView.color = [self.calendarManager.calendarAppearance dayCircleColorTodayOtherMonth];
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorTodayOtherMonth];
            feastLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorTodayOtherMonth];
            dotView.color = [self.calendarManager.calendarAppearance dayDotColorTodayOtherMonth];
        }
    }
    else{
        if(!self.isOtherMonth){
            // dql
            UIColor * color = self.isWeekend ? [UIColor colorWithRed:0 green:188/255.0f blue:254/255.0f alpha:1.0f] : [self.calendarManager.calendarAppearance dayTextColor];
            textLabel.textColor = color;
            feastLabel.textColor = color;
            dotView.color = [self.calendarManager.calendarAppearance dayDotColor];
        }
        else{
            textLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorOtherMonth];
            feastLabel.textColor = [self.calendarManager.calendarAppearance dayTextColorOtherMonth];
            dotView.color = [self.calendarManager.calendarAppearance dayDotColorOtherMonth];
        }
        
        opacity = 0.;
    }
    
    if(animated){
        [UIView animateWithDuration:.3 animations:^{
            circleView.layer.opacity = opacity;
            circleView.transform = tr;
        }];
    }
    else{
        circleView.layer.opacity = opacity;
        circleView.transform = tr;
    }
}

- (void)setIsOtherMonth:(BOOL)isOtherMonth
{
    self->_isOtherMonth = isOtherMonth;
    [self setSelected:isSelected animated:NO];
}

- (void)reloadData
{
    dotView.hidden = ![self.calendarManager.dataCache haveEvent:self.date];
    
//    BOOL selected = [self isSameDate:[self.calendarManager currentDateSelected]];
    BOOL selected = [self isContainDate:self.date];
    [self setSelected:selected animated:NO];
}

- (BOOL)isToday
{
    if(cacheIsToday == 0){
        return NO;
    }
    else if(cacheIsToday == 1){
        return YES;
    }
    else{
        if([self isSameDate:[NSDate date]]){
            cacheIsToday = 1;
            return YES;
        }
        else{
            cacheIsToday = 0;
            return NO;
        }
    }
}

- (BOOL)isSameDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = self.calendarManager.calendarAppearance.calendar.timeZone;
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    }
    
    if(!cacheCurrentDateText){
        cacheCurrentDateText = [dateFormatter stringFromDate:self.date];
    }
    
    NSString *dateText2 = [dateFormatter stringFromDate:date];
    
    if ([cacheCurrentDateText isEqualToString:dateText2]) {
        return YES;
    }
    
    return NO;
}

// dql
- (BOOL)isContainDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if(!dateFormatter){
        dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = self.calendarManager.calendarAppearance.calendar.timeZone;
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    }
    
//    if (!selectedDateText[0] && !selectedDateText[1]) {
//        selectedDateText[0] = [NSMutableString new];
//        selectedDateText[1] = [NSMutableString new];
//    }
//    
//    NSString * str1 = selectedDateText[0];
//    NSString *dateText2 = [dateFormatter stringFromDate:date];
//    static int count = 0;
////    if (![str1 isEqualToString:dateText2] && [selectedDateText[1] isEqualToString:dateText2]) {
////        selectedDateText[0] = dateText2;
////        return YES;
////    }
//    if (count < 2) {
//        count++;
//        return YES;
//    }
    NSString * dateText = [dateFormatter stringFromDate:date];
    
    for (NSDate * tmpDate in self.calendarManager.dateSelected) {
        NSString * dateString = [dateFormatter stringFromDate:tmpDate];
        if ([dateString isEqualToString:dateText]) {
            return YES;
        }
    }
    
    
    return NO;
}

- (NSInteger)monthIndexForDate:(NSDate *)date
{
    NSCalendar *calendar = self.calendarManager.calendarAppearance.calendar;
    NSDateComponents *comps = [calendar components:NSCalendarUnitMonth fromDate:date];
    return comps.month;
}

- (void)reloadAppearance
{
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = self.calendarManager.calendarAppearance.dayTextFont;
    
    
    [self configureConstraintsForSubviews];
    [self setSelected:isSelected animated:NO];

}

@end
