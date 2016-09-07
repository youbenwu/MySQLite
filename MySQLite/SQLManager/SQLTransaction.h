//
//  SQLTransaction.h
//  BOOK
//
//  Created by iflashbuy on 16/8/31.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLDatabase.h"

@class SQLDatabase;
@interface SQLTransaction : NSObject

//1 begin 2commit 3rollback
@property (nonatomic) NSInteger status;

-(instancetype)initWithSQLDatabase:(SQLDatabase*)db;

-(BOOL)begin;
-(BOOL)commit;
-(BOOL)rollback;

@end
