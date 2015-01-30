//
//  CitiesTableViewController.h
//  MyWeatherSecond
//
//  Created by HeZitong on 14/12/21.
//  Copyright (c) 2014年 HeZitong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
@interface CitiesTableViewController : UITableViewController<UISearchBarDelegate>

@property (nonatomic,strong) NSArray *cities;
@property (nonatomic,strong) NSDictionary *cityDic;


- (id)initWithCityList:(NSArray *)cityList;

@end

@protocol selectedCell

-(void)reloadData:(NSDictionary *)recieveDic with:(NSInteger) cityCode;
-(void)reloadHourlyData:(NSDictionary *)recieveDic;
-(void)reloadDailyData:(NSDictionary *)recieveDic;
-(void)waitingNetwork;
-(void)dismissMessage;
@end
