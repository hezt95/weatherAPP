//
//  WeatherNavController.m
//  MyWeatherSecond
//
//  Created by HeZitong on 14/12/27.
//  Copyright (c) 2014年 HeZitong. All rights reserved.
//

#import "WeatherNavController.h"
#import "CitiesTableViewController.h"
#import "UIViewController+REFrostedViewController.h"


@interface WeatherNavController ()

@property (strong,readwrite,nonatomic) CitiesTableViewController *citiesViewCtrl;


@end

@implementation WeatherNavController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Gesture recognizer

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController panGestureRecognized:sender];
}


@end
