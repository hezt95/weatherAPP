//
//  WeatherDailyModel.m
//  MyWeatherSecond
//
//  Created by HeZitong on 14/12/29.
//  Copyright (c) 2014年 HeZitong. All rights reserved.
//

#import "WeatherDailyModel.h"

@implementation WeatherDailyModel

-(WeatherDailyModel *)initWithDailyDic:(NSDictionary *)dic{
    NSArray *array = [dic objectForKey:@"list"];
    self.forecastArray = [NSMutableArray arrayWithCapacity:7];
    NSInteger timeCtrl = 0;
    for (NSDictionary *dic in array) {
        NSString *tempMinStr = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"temp"] objectForKey:@"min"]];
        NSString *tempMaxStr = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"temp"] objectForKey:@"max"]];
        NSNumber *tempMin = [NSNumber numberWithInteger:[tempMinStr floatValue] - 273.15];
        NSNumber *tempMax = [NSNumber numberWithInteger:[tempMaxStr floatValue] - 273.15];
        NSString *icon = [NSString stringWithFormat:@"%@",[[[dic objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"]];
        NSString *condition = [NSString stringWithFormat:@"%@",[[[dic objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"main"]];
        NSDictionary *detail = [NSDictionary dictionaryWithObjectsAndKeys:tempMax,@"max",tempMin,@"min",icon,@"icon",condition,@"condition", nil];
        [self.forecastArray addObject:detail];
        timeCtrl++;
    }
    return self;
}


@end
