//
//  DBManger.h
//  MyWeatherSecond
//
//  Created by HeZitong on 14/12/31.
//  Copyright (c) 2014年 HeZitong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBManager : NSObject

@property (nonatomic,strong) NSMutableArray *allColmnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(NSArray *)loadDataFromDB:(NSString *)query;
-(void)executeQuery:(NSString *)query;
-(instancetype)initWithDataBaseFileName:(NSString *)dbFileName;

@end
