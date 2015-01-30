//
//  CitiesTableViewController.m
//  MyWeatherSecond
//
//  Created by HeZitong on 14/12/21.
//  Copyright (c) 2014年 HeZitong. All rights reserved.
//

#import "CitiesTableViewController.h"
#import "WeatherViewController.h"
#import "WeatherNavController.h"
#import <AFNetworking/AFNetworking.h>


@interface CitiesTableViewController () <UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, strong) NSMutableArray *selectedCities;
@end


@implementation CitiesTableViewController
-(id)initWithCityList:(NSArray *)cityList{
    self = [self initWithStyle:UITableViewStyleGrouped];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Create a mutable array to contain cities for the search results table.
    self.title = @"Search";
    self.navigationController.navigationBarHidden = YES;
    NSString *cityPlistPath = [[NSBundle mainBundle] pathForResource:@"cityList" ofType:@"plist"];
    self.cityDic = [[NSDictionary alloc] initWithContentsOfFile:cityPlistPath];
    self.cities = [self.cityDic allKeys];
    [self setSearchCtrl];
    [self setViews];
    self.definesPresentationContext = YES;

    
}

#pragma mark view and search
-(void)setSearchCtrl{
    UITableViewController *searchResultsController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultsController.tableView.dataSource = self;
    searchResultsController.tableView.delegate = self;
    
//    searchResultsController.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    searchResultsController.tableView.separatorColor = [UIColor clearColor];
    searchResultsController.tableView.opaque = NO;
    searchResultsController.tableView.backgroundColor = [UIColor clearColor];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x,self.searchController.searchBar.frame.origin.y,searchResultsController.view.frame.size.width,44);
    self.tableView.tableHeaderView = self.searchController.searchBar;

}//include searchbar

-(void)setViews{
//    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.opaque = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    
}//存疑，为什么cell和search的tableview self的tableview都要设置透明那些

#pragma mark - table view datesource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    /*  If the requesting table view is the search controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
     */
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        return [self.searchResults count];
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CityCell";
    // Dequeue a cell from self's table view.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        // More initializations if needed.
    }
    /*  If the requesting table view is the search controller's table view, configure the cell using the search results array, otherwise use the city array.
     */
    NSString *cityName;
    if (tableView == ((UITableViewController *)self.searchController.searchResultsController).tableView) {
        cityName = [self.searchResults objectAtIndex:indexPath.row];

    } else {
        cityName = nil;

    }
    cell.textLabel.text = cityName;
    cell.opaque = NO;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cityName = [self.searchResults objectAtIndex:indexPath.row];
    NSInteger cityCode = [[self.cityDic valueForKey:[NSString stringWithFormat:@"%@",cityName]] integerValue];
    NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
    NSInteger selectedCtrl = 0;
    for (NSMutableDictionary *dic in array) {
        if ([[dic objectForKey:@"city"] isEqualToString:cityName]) {
            selectedCtrl = 1;
            break;
        }
    }
    if (selectedCtrl == 1) {
        UIAlertView *aleart = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"You have chose %@.",cityName] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [aleart show];
    }
    if (selectedCtrl == 0) {
        
        [self requestingAPI:cityCode];
    }
    
}

-(void)requestingAPI:(NSInteger)cityCode{
    WeatherViewController *weatherViewCtrl = [[WeatherViewController alloc] init];
    weatherViewCtrl.saveDic = [[NSMutableDictionary alloc] init];
    WeatherNavController *navCtrl = [[WeatherNavController alloc] initWithRootViewController:weatherViewCtrl];
    self.frostedViewController.contentViewController = navCtrl;
    __block NSInteger watingMsgCtrl = 0;
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    [manager GET:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?id=%ld",cityCode] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"111111111111111");
        [weatherViewCtrl reloadData:responseObject with:cityCode];
        watingMsgCtrl = watingMsgCtrl+1;
        if (watingMsgCtrl == 3) {
            NSLog(@">>>>>>>>>>>>>>>>>>>");
            [weatherViewCtrl dismissMessage];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Weather data cannot get");
        [weatherViewCtrl dismissMessage];
        [TSMessage showNotificationWithTitle:@"Network Error" subtitle:@"Cannot get data from server" type:TSMessageNotificationTypeError];
        return;
    }];
    [manager GET:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?id=%ld",cityCode] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"2222222222222222");
        [weatherViewCtrl reloadHourlyData:responseObject];
        watingMsgCtrl = watingMsgCtrl+1;
        if (watingMsgCtrl == 3) {
            NSLog(@">>>>>>>>>>>>>>>>>>>");
            [weatherViewCtrl dismissMessage];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Weather hourly data cannot get");
        [weatherViewCtrl dismissMessage];
        [TSMessage showNotificationWithTitle:@"Network Error" subtitle:@"Cannot get data from server" type:TSMessageNotificationTypeError];
        return;
    }];
    [manager GET:[NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?id=%ld",cityCode] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"33333333333333");
        [weatherViewCtrl reloadDailyData:responseObject];
        watingMsgCtrl = watingMsgCtrl+1;
        if (watingMsgCtrl == 3) {
            NSLog(@">>>>>>>>>>>>>>>>>>>");
            [weatherViewCtrl dismissMessage];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Weather daily data cannot get");
        [weatherViewCtrl dismissMessage];
        [TSMessage showNotificationWithTitle:@"Network Error" subtitle:@"Cannot get data from server" type:TSMessageNotificationTypeError];
        return;
    }];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [weatherViewCtrl waitingNetwork];
}


#pragma mark - UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [self.searchController.searchBar text];
    [self updateFilteredContentForCityName:searchString];
    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
}

#pragma mark - Content Filtering

- (void)updateFilteredContentForCityName:(NSString *)cityName{
  
    if ((cityName == nil) || [cityName length] == 0) {
        self.searchResults = nil;
        return;
    }
    self.searchResults = [NSMutableArray arrayWithCapacity:0];
    //[self.searchResults removeAllObjects]; // First clear the filtered array.
    for (NSString *cityNameOrigin in self.cities) {
        NSRange cityNameRange = NSMakeRange(0, cityNameOrigin.length);
        NSRange foundRange = [cityNameOrigin rangeOfString:cityName options:NSLiteralSearch|NSCaseInsensitiveSearch range:cityNameRange];
        if (foundRange.length > 0) {
            [self.searchResults addObject:cityNameOrigin];
        }
    }
    
}

@end
