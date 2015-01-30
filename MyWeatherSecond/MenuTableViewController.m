//
//  MenuTableViewController.m
//  MyWeatherSecond
//
//  Created by HeZitong on 14/12/28.
//  Copyright (c) 2014年 HeZitong. All rights reserved.
//

#import "MenuTableViewController.h"
#import "CitiesTableViewController.h"
#import "WeatherNavController.h"
#import "WeatherViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.0f)];
        view;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *selectedRow = [NSNumber numberWithInteger:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:selectedRow forKey:@"selected"];
    WeatherViewController *weatherViewCtrl = [[WeatherViewController alloc] init];
    WeatherNavController *navCtrl = [[WeatherNavController alloc] initWithRootViewController:weatherViewCtrl];
    self.frostedViewController.contentViewController = navCtrl;
    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSMutableArray *array = (NSMutableArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
    return [array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"]) {
        UIButton *deleteBtn = [[UIButton alloc] init];
        UIImage *delete = [UIImage imageNamed:@"x.png"];
        deleteBtn.tag = indexPath.row;
        deleteBtn.frame = CGRectMake(240.0f, 18.0f, 20.0f, 20.0f);
        [deleteBtn setBackgroundImage:delete forState:UIControlStateNormal];
        deleteBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [deleteBtn setTintColor:[UIColor whiteColor]];
        [deleteBtn addTarget:self action:@selector(deleteBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:deleteBtn];
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"] objectAtIndex:indexPath.row]) {
            NSString *cityName = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"] objectAtIndex:indexPath.row] objectForKey:@"city"];
            if (cityName) {
                cell.textLabel.text = cityName;
            }
        }
       
    }
    return cell;
}

-(void)deleteBtnPressed:(UIButton *)btn{
    NSArray *tempArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"weatherAll"];
    NSMutableArray *listMutableArray = [tempArray mutableCopy];
    [listMutableArray removeObjectAtIndex:btn.tag];
    [[NSUserDefaults standardUserDefaults] setObject:listMutableArray forKey:@"weatherAll"];
    [self.tableView reloadData];
}

@end
