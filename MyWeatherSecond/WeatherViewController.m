//
//  WeatherViewController.m
//  MyWeatherSecond
//
//  Created by HeZitong on 14/12/21.
//  Copyright (c) 2014年 HeZitong. All rights reserved.
//

#import "WeatherViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "WeatherNavController.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "WeatherModel.h"
#import "WeatherDailyModel.h"
#import "WeatherHourlyModel.h"
#import "DBManager.h"
#import "MJRefresh.h"
#import <AFNetworking.h>

@interface WeatherViewController ()

@property (nonatomic,strong) UIImageView *backgroundImageView;
@property (nonatomic,strong) UIImageView *blurredImageView;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,assign) CGFloat screenHeight;
@property (nonatomic,strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic,strong) NSDateFormatter *dailyFormatter;
@property (nonatomic,strong) UIButton *openDrawerButton;
@property (nonatomic,strong) UIButton *addButton;
@property (nonatomic,strong) UILabel *temperatureLabel;
@property (nonatomic,strong) UILabel *hiloLabel;
@property (nonatomic,strong) UILabel *cityLabel;
@property (nonatomic,strong) UILabel *conditionLabel;
@property (nonatomic,strong) UIImageView *iconView;

@property(nonatomic,strong,readwrite) WeatherModel *currentModel;
@property(nonatomic,strong,readwrite) WeatherDailyModel *dailyModel;
@property(nonatomic,strong,readwrite) WeatherHourlyModel *hourlyModel;

@property(nonatomic) NSInteger saveDetailCtrl;
@property(nonatomic) NSInteger cityCode;

@end

@implementation WeatherViewController

#pragma mark -Manage view
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self setViews];
    NSInteger selected = [[[NSUserDefaults standardUserDefaults] objectForKey:@"selected"] integerValue];
    if (selected) {
        [self setDataAt:selected];
    }
    else{
        [self setDataAt:0];
    }
    [self setupRefresh];
}

-(void)setViews{
    //views config
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage *background = [UIImage imageNamed:@"10379802.jpg"];
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10.0 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];//分界线颜色
    self.tableView.pagingEnabled = YES;

    [self.view addSubview:self.tableView];
    
    CGRect headerFrame = [[UIScreen mainScreen] bounds];
    CGFloat inset = 20;
    
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    
    CGRect hiloFrame = CGRectMake(inset, headerFrame.size.height - hiloHeight, headerFrame.size.width - (2 * inset), hiloHeight);
    CGRect temperatureFrame = CGRectMake(inset, headerFrame.size.height - hiloHeight - temperatureHeight, headerFrame.size.width - (2*inset),temperatureHeight );
    CGRect iconFrame = CGRectMake(inset, temperatureFrame.origin.y - iconHeight, iconHeight, iconHeight);
    
    CGRect conditionFrame = iconFrame;
    conditionFrame.size.width = self.view.bounds.size.width - (((2*inset) + iconHeight) +10);
    conditionFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    self.temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    self.temperatureLabel.backgroundColor = [UIColor clearColor];
    self.temperatureLabel.textColor = [UIColor whiteColor];
    self.temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:self.temperatureLabel];
    
    self.hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    self.hiloLabel.backgroundColor = [UIColor clearColor];
    self.hiloLabel.textColor = [UIColor whiteColor];
    self.hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:self.hiloLabel];
    
    self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, self.view.bounds.size.width, 30)];
    self.cityLabel.backgroundColor = [UIColor clearColor];
    self.cityLabel.textColor = [UIColor whiteColor];
    self.cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:23];
    self.cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:self.cityLabel];
    
    self.conditionLabel = [[UILabel alloc] initWithFrame:conditionFrame];
    self.conditionLabel.backgroundColor = [UIColor clearColor];
    self.conditionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    self.conditionLabel.textColor = [UIColor whiteColor];
    [header addSubview:self.conditionLabel];
    
    self.iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    self.iconView.contentMode = UIViewContentModeScaleAspectFill;
    self.iconView.backgroundColor = [UIColor clearColor];
    [header addSubview:self.iconView];
    
    //drawer config
    UIImage *hamburger = [UIImage imageNamed:@"hamburger.png"];
//    NSParameterAssert(clipboard);
    self.openDrawerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.openDrawerButton.frame = CGRectMake(15.0f, 25.0f, 30.0f, 30.0f);
    [self.openDrawerButton setBackgroundImage:hamburger forState:UIControlStateNormal];
    self.openDrawerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.openDrawerButton setTintColor:[UIColor whiteColor]];
    [self.openDrawerButton addTarget:self action:@selector(showCities) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:self.openDrawerButton];
    
    UIImage *add = [UIImage imageNamed:@"plus.png"];
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addButton.frame = CGRectMake(280.0f, 25.0f, 30.0f, 30.0f);
    [self.addButton setBackgroundImage:add forState:UIControlStateNormal];
    self.addButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.addButton setTintColor:[UIColor whiteColor]];
    [self.addButton addTarget:self action:@selector(enterSearch) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:self.addButton];
}

-(void)enterSearch{
    CitiesTableViewController *searchViewCtrl = [[CitiesTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:searchViewCtrl animated:YES];
}

- (void)showCities
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];//[self.navagationController.frostedViewController presentMenuViewController]
}

-(void)setDataAt:(NSInteger) row{
    self.weatherDetailDic = [[NSMutableDictionary alloc] init];
    self.weatherAllDetailArr = [[NSMutableArray alloc] init];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"]) {
        self.weatherAllDetailArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
        if (self.weatherAllDetailArr) {
            self.weatherDetailDic = [self.weatherAllDetailArr objectAtIndex:row];
            self.temperatureLabel.text = [NSString stringWithFormat:@"%@°",[self.weatherDetailDic objectForKey:@"temp"]];
            self.hiloLabel.text = [NSString stringWithFormat:@"%@° / %@°",[self.weatherDetailDic objectForKey:@"tempHigh"],[self.weatherDetailDic objectForKey:@"tempLow"]];
            self.cityLabel.text = [NSString stringWithFormat:@"%@",[self.weatherDetailDic objectForKey:@"city"]];
            self.conditionLabel.text = [NSString stringWithFormat:@"%@",[self.weatherDetailDic objectForKey:@"condition"]];
            [self.iconView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[self.weatherDetailDic objectForKey:@"icon"]]]];
            self.cityCode = [(NSNumber *)[self.weatherDetailDic objectForKey:@"cityCode"] integerValue];
        }
        else{
            self.temperatureLabel.text = @"0°";
            self.hiloLabel.text = @"0° / 0°";
            self.cityLabel.text = @"Loading";
            self.conditionLabel.text = @"Nighty";
            self.cityCode = 1786657;
        }
    }
    else{
        self.temperatureLabel.text = @"0°";
        self.hiloLabel.text = @"0° / 0°";
        self.cityLabel.text = @"Loading";
        self.conditionLabel.text = @"Nighty";
        self.cityCode = 1786657;
    }
}

#pragma mark - pull refresh
-(void)setupRefresh{
    [self.tableView addHeaderWithTarget:self action:@selector(headerRefreshing) dateKey:nil];
    self.tableView.headerPullToRefreshText = @"下拉刷新";
    self.tableView.headerReleaseToRefreshText = @"松开刷新";
    self.tableView.headerRefreshingText = @"正在刷新";
}

-(void)headerRefreshing
{
    [self requestingAPI];
}
-(void)requestingAPI{
    __block NSInteger watingMsgCtrl = 0;
    self.weatherDetailDic = [[NSMutableDictionary alloc] init];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    [manager GET:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%ld",self.cityCode] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"1111111111111");
        [self reloadDataSelf:responseObject with:self.cityCode];
        watingMsgCtrl = watingMsgCtrl+1;
        if (watingMsgCtrl == 3) {
            NSLog(@">>>>>>>>>>>>>>>>");
            [self.tableView headerEndRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView headerEndRefreshing];
        [TSMessage showNotificationWithTitle:@"Network Error" subtitle:@"Cannot get data from server" type:TSMessageNotificationTypeError];
        return;
    }];
    
    [manager GET:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?id=%ld",self.cityCode] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"2222222222222");
        [self reloadHourlyDataSelf:responseObject];
        watingMsgCtrl = watingMsgCtrl+1;
        if (watingMsgCtrl == 3) {
            NSLog(@">>>>>>>>>>>>>>>>");
            [self.tableView headerEndRefreshing];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView headerEndRefreshing];
        [TSMessage showNotificationWithTitle:@"Network Error" subtitle:@"Cannot get data from server" type:TSMessageNotificationTypeError];
        return;
    }];
    
    
    [manager GET:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?id=%ld",self.cityCode] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"33333333333333");
        [self reloadDailyDataSelf:responseObject];
        watingMsgCtrl = watingMsgCtrl+1;
        if (watingMsgCtrl == 3) {
            NSLog(@">>>>>>>>>>>>>>>>");
            [self.tableView headerEndRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView headerEndRefreshing];
        [TSMessage showNotificationWithTitle:@"Network Error" subtitle:@"Cannot get data from server" type:TSMessageNotificationTypeError];
        return;
    }];
}

#pragma mark -StatusBar
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden{
    return NO;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 9;
    }
    else{
        return 8;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier =@"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        }
        else{
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"]) {
                [self configHoulyCell:cell atRow:indexPath.row - 1];
            }
            else{
                cell.textLabel.text = @"Loading";
            }
        }
    }
    else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        else{
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"]) {
                [self configDailyCell:cell atRow:indexPath.row - 1];
            }
            else{
                cell.textLabel.text = @"Loading";
            }
        }
    }
    return cell;
}


#pragma mark - Messages
-(void)reloadData:(NSDictionary *)recieveDic with:(NSInteger)cityCode{
//    NSLog(@"%@",self.weatherDetailDic);
    self.currentModel = [[WeatherModel alloc] initWithDic:recieveDic];
    self.temperatureLabel.text = [NSString stringWithFormat:@"%@°",self.currentModel.temperature];
    self.hiloLabel.text = [NSString stringWithFormat:@"%@° / %@°",self.currentModel.tempHigh,self.currentModel.tempLow];
    self.cityLabel.text = [NSString stringWithFormat:@"%@",self.currentModel.locationName];
    self.conditionLabel.text = [NSString stringWithFormat:@"%@",self.currentModel.condition];
    [self.iconView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",self.currentModel.icon]]];
    NSNumber *cityCodeObj = [NSNumber numberWithInteger:cityCode];
    NSArray *tempArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
    NSMutableArray *mutableListArray = [tempArray mutableCopy];
    
    [self.saveDic setObject:self.currentModel.temperature forKey:@"temp"];
    [self.saveDic setObject:self.currentModel.tempHigh forKey:@"tempHigh"];
    [self.saveDic setObject:self.currentModel.tempLow forKey:@"tempLow"];
    [self.saveDic setObject:self.currentModel.locationName forKey:@"city"];
    
    [self.saveDic setObject:self.currentModel.condition forKey:@"condition"];
    [self.saveDic setObject:self.currentModel.icon forKey:@"icon"];
    [self.saveDic setObject:cityCodeObj forKey:@"cityCode"];
    self.cityCode = cityCode;
    
    self.saveDetailCtrl++;
    if (self.saveDetailCtrl == 3) {
        [mutableListArray addObject:self.saveDic];
        [[NSUserDefaults standardUserDefaults] setObject:mutableListArray forKey:@"weatherAll"];
        NSLog(@"save success");
        self.saveDetailCtrl = 0;
    }
}

-(void)reloadHourlyData:(NSDictionary *)recieveDic{
//    NSLog(@"%@",self.weatherDetailDic);
    WeatherHourlyModel *mod = [[WeatherHourlyModel alloc] initHourlyWithDic:recieveDic];
    [self.saveDic setObject:mod.forecastArray forKey:@"hourly"];
    NSArray *tempArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
    NSMutableArray *mutableListArray = [tempArray mutableCopy];
    self.saveDetailCtrl++;
    if (self.saveDetailCtrl == 3) {
        [mutableListArray addObject:self.saveDic];
        [[NSUserDefaults standardUserDefaults] setObject:mutableListArray forKey:@"weatherAll"];
        NSLog(@"save success");
        self.saveDetailCtrl = 0;
    }
}

-(void)reloadDailyData:(NSDictionary *)recieveDic{
//    NSLog(@"%@",self.weatherDetailDic);
    WeatherDailyModel *mod = [[WeatherDailyModel alloc] initWithDailyDic:recieveDic];
    
    [self.saveDic setObject:mod.forecastArray forKey:@"daily"];
    NSArray *tempArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
    NSMutableArray *mutableListArray = [tempArray mutableCopy];
    self.saveDetailCtrl++;
    if (self.saveDetailCtrl == 3 ) {
        [mutableListArray addObject:self.saveDic];
        [[NSUserDefaults standardUserDefaults] setObject:mutableListArray forKey:@"weatherAll"];
        NSLog(@"save success");
        self.saveDetailCtrl = 0;
    }
}


-(void)reloadDataSelf:(NSDictionary *)recieveDic with:(NSInteger)cityCode{
    //    NSLog(@"%@",self.weatherDetailDic);
    self.currentModel = [[WeatherModel alloc] initWithDic:recieveDic];
    self.temperatureLabel.text = [NSString stringWithFormat:@"%@°",self.currentModel.temperature];
    self.hiloLabel.text = [NSString stringWithFormat:@"%@° / %@°",self.currentModel.tempHigh,self.currentModel.tempLow];
    self.cityLabel.text = [NSString stringWithFormat:@"%@",self.currentModel.locationName];
    self.conditionLabel.text = [NSString stringWithFormat:@"%@",self.currentModel.condition];
    [self.iconView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",self.currentModel.icon]]];
    NSNumber *cityCodeObj = [NSNumber numberWithInteger:cityCode];
    
    [self.weatherDetailDic setObject:self.currentModel.temperature forKey:@"temp"];
    [self.weatherDetailDic setObject:self.currentModel.tempHigh forKey:@"tempHigh"];
    [self.weatherDetailDic setObject:self.currentModel.tempLow forKey:@"tempLow"];
    [self.weatherDetailDic setObject:self.currentModel.locationName forKey:@"city"];
    [self.weatherDetailDic setObject:self.currentModel.condition forKey:@"condition"];
    [self.weatherDetailDic setObject:self.currentModel.icon forKey:@"icon"];
    [self.weatherDetailDic setObject:cityCodeObj forKey:@"cityCode"];
    self.cityCode = cityCode;
    NSArray *tempArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
    NSMutableArray *mutableListArray = [tempArray mutableCopy];
    self.saveDetailCtrl++;
    NSInteger indexCtrl = 0;
    NSMutableArray *weatherAllDetailArrTemp = [NSMutableArray arrayWithArray:mutableListArray];
    if (self.saveDetailCtrl == 3) {
        for (NSMutableDictionary *dic in weatherAllDetailArrTemp) {
            if ([dic objectForKey:@"cityCode"] == cityCodeObj) {
                [mutableListArray replaceObjectAtIndex:indexCtrl withObject:self.weatherDetailDic];
            }
            indexCtrl++;
        }
        [[NSUserDefaults standardUserDefaults] setObject:mutableListArray forKey:@"weatherAll"];
        self.saveDetailCtrl = 0;
    }
}

-(void)reloadHourlyDataSelf:(NSDictionary *)recieveDic{
    //    NSLog(@"%@",self.weatherDetailDic);
    WeatherHourlyModel *mod = [[WeatherHourlyModel alloc] initHourlyWithDic:recieveDic];
    [self.weatherDetailDic setObject:mod.forecastArray forKey:@"hourly"];
    self.saveDetailCtrl++;
    NSInteger indexCtrl = 0;
    NSArray *tempArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
    NSMutableArray *mutableListArray = [tempArray mutableCopy];
    NSMutableArray *weatherAllDetailArrTemp = [NSMutableArray arrayWithArray:mutableListArray];
    if (self.saveDetailCtrl == 3) {
        for (NSMutableDictionary *dic in weatherAllDetailArrTemp) {
            if ([dic objectForKey:@"cityCode"] == [NSNumber numberWithInteger:self.cityCode]) {
                [mutableListArray replaceObjectAtIndex:indexCtrl withObject:self.weatherDetailDic];
            }
            indexCtrl++;
        }
        [[NSUserDefaults standardUserDefaults] setObject:mutableListArray forKey:@"weatherAll"];
        self.saveDetailCtrl = 0;
    }
}

-(void)reloadDailyDataSelf:(NSDictionary *)recieveDic{
    //    NSLog(@"%@",self.weatherDetailDic);
    WeatherDailyModel *mod = [[WeatherDailyModel alloc] initWithDailyDic:recieveDic];
    [self.weatherDetailDic setObject:mod.forecastArray forKey:@"daily"];
    NSInteger indexCtrl = 0;
    NSArray *tempArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
    NSMutableArray *mutableListArray = [tempArray mutableCopy];
    NSMutableArray *weatherAllDetailArrTemp = [NSMutableArray arrayWithArray:mutableListArray];
    if (self.saveDetailCtrl == 3) {
        for (NSMutableDictionary *dic in weatherAllDetailArrTemp) {
            if ([dic objectForKey:@"cityCode"] == [NSNumber numberWithInteger:self.cityCode]) {
                [mutableListArray replaceObjectAtIndex:indexCtrl withObject:self.weatherDetailDic];
            }
            indexCtrl++;
        }
        [[NSUserDefaults standardUserDefaults] setObject:mutableListArray forKey:@"weatherAll"];
        self.saveDetailCtrl = 0;
    }}


-(void)waitingNetwork{
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"Connecting", nil)
                                       subtitle:NSLocalizedString(@"Trying to get the weather data.", nil)
                                          image:nil
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationEndless
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:nil
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];
    
}

-(void)dismissMessage{
    [TSMessage dismissActiveNotification];
}

#pragma mark - cell config
- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

-(void)configHoulyCell:(UITableViewCell *)cell atRow:(NSInteger)number{
    NSMutableArray *displayArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
    NSLog(@"%@",displayArray);
    if (displayArray) {
        NSMutableDictionary *displayDic = [displayArray objectAtIndex:[[[NSUserDefaults standardUserDefaults] objectForKey:@"selected"] integerValue]];
        if (displayDic) {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
            cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.textLabel.text = [[[displayDic objectForKey:@"hourly"] objectAtIndex:number] objectForKey:@"time"];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@°",[[[displayDic objectForKey:@"hourly"] objectAtIndex:number] objectForKey:@"temp"]];
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[[[displayDic objectForKey:@"hourly"] objectAtIndex:number] objectForKey:@"icon"]]];
        }
    }
    
}

-(void)configDailyCell:(UITableViewCell *)cell atRow:(NSInteger)number{
    NSMutableArray *displayArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
    NSLog(@"%@",displayArray);
    if (displayArray) {
        NSMutableDictionary *displayDic = [displayArray objectAtIndex:[[[NSUserDefaults standardUserDefaults] objectForKey:@"selected"] integerValue]];
        if (displayDic) {
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
            cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
            NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDate *now = [NSDate date];
            NSDateComponents *comps = [[NSDateComponents alloc] init];
            NSInteger unitFlags = NSCalendarUnitWeekday;
            comps = [calendar components:unitFlags fromDate:now];
            NSInteger week = [comps weekday];
            week = week + number;
            switch (week) {
                case 1:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Sunday"];
                    break;
                case 2:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Monday"];
                    break;
                case 3:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Tuesday"];
                    break;
                case 4:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Wednesday"];
                    break;
                case 5:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Thursday"];
                    break;
                case 6:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Friday"];
                    break;
                case 7:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Saturday"];
                case 8:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Sunday"];
                    break;
                case 9:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Monday"];
                    break;
                case 10:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Tuesday"];
                    break;
                case 11:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Wednesday"];
                    break;
                case 12:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Thursday"];
                    break;
                case 13:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Friday"];
                    break;
                case 14:
                    cell.textLabel.text = [NSString stringWithFormat:@"%@  %@",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"condition"],@"Saturday"];
                    break;
                default:
                    break;
            }
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@°/%@°",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"max"],[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"min"]];
            cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",[[[displayDic objectForKey:@"daily"] objectAtIndex:number] objectForKey:@"icon"]]];
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight/(CGFloat)cellCount;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGRect bounds = self.view.bounds;
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat persent = MIN(position/height, 1.0);
    self.blurredImageView.alpha = persent;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
