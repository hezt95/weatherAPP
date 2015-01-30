//
//  WeatherModel.m
//  MyWeatherSecond
//
//  Created by HeZitong on 14/12/28.
//  Copyright (c) 2014年 HeZitong. All rights reserved.
//

#import "WeatherModel.h"

@implementation WeatherModel

-(WeatherModel *)initWithDic:(NSDictionary *)dic{
    self.locationName = [dic objectForKey:@"name"];
    NSDictionary *weatherDicFromAPI = [[dic objectForKey:@"weather"] objectAtIndex:0];
    self.condition = [weatherDicFromAPI objectForKey:@"main"];
    self.icon = [weatherDicFromAPI objectForKey:@"icon"];
    NSDictionary *mainDicFromAPI = [dic objectForKey:@"main"];
    NSString *tempStr = [NSString stringWithFormat:@"%@",[mainDicFromAPI objectForKey:@"temp"]];
    self.temperature = [NSNumber numberWithInteger:[tempStr floatValue] - 273.15];
    
    NSString *tempHighStr = [NSString stringWithFormat:@"%@",[mainDicFromAPI objectForKey:@"temp_max"]];
    self.tempHigh = [NSNumber numberWithInteger:[tempHighStr floatValue] -273.15];
    
    NSString *tempLowStr = [NSString stringWithFormat:@"%@",[mainDicFromAPI objectForKey:@"temp_min"]];
    self.tempLow = [NSNumber numberWithInteger:[tempLowStr floatValue] -273.15];
    
    return self;
    
}



@end
