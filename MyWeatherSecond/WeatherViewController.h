//
//  WeatherViewController.h
//  MyWeatherSecond
//
//  Created by HeZitong on 14/12/21.
//  Copyright (c) 2014年 HeZitong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSMessage.h"
#import "CitiesTableViewController.h"

@interface WeatherViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,selectedCell>
@property(nonatomic,strong) NSMutableDictionary *weatherDetailDic;
@property(nonatomic,strong) NSMutableArray *weatherAllDetailArr;
@property(nonatomic,strong) NSMutableDictionary *saveDic;
@end

