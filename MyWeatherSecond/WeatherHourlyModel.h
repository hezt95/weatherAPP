//
//  WeatherHourlyModel.h
//  MyWeatherSecond
//
//  Created by HeZitong on 14/12/29.
//  Copyright (c) 2014年 HeZitong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherHourlyModel : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong) NSString *icon;

@property (nonatomic, strong) NSMutableArray *forecastArray;

-(WeatherHourlyModel *)initHourlyWithDic:(NSDictionary *)dic;

@end
