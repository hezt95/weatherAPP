//
//  WeatherHourlyModel.m
//  MyWeatherSecond
//
//  Created by HeZitong on 14/12/29.
//  Copyright (c) 2014年 HeZitong. All rights reserved.
//

#import "WeatherHourlyModel.h"

@implementation WeatherHourlyModel

-(WeatherHourlyModel *)initHourlyWithDic:(NSDictionary *)dic{
    NSArray *array = [dic objectForKey:@"list"];
    self.forecastArray = [NSMutableArray arrayWithCapacity:8];
    NSInteger timeCtrl = 0;
    for (NSDictionary *dic in array) {
        NSString *tempStr =[NSString stringWithFormat:@"%@",[[dic objectForKey:@"main"] objectForKey:@"temp"]];
        NSNumber *temp = [NSNumber numberWithInteger:[tempStr floatValue] -273.15];
        NSString *icon = [[[dic objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"];
        NSString *time = [[[[dic objectForKey:@"dt_txt"] componentsSeparatedByString:@" "] objectAtIndex:1] substringToIndex:5];
        NSDictionary *detail = [NSDictionary dictionaryWithObjectsAndKeys:temp,@"temp",icon,@"icon",time,@"time", nil];
        timeCtrl++;
        [self.forecastArray addObject:detail];
        if (timeCtrl == 8) {
            break;
        }
    }
//    NSLog(@"%@",self.forecastArray);
    return self;
}

@end
