//
//  SQLDatabase.h
//  BOOK
//
//  Created by youbenwu on 16/8/29.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "SQLEntity.h"



@interface SQLDatabase : NSObject

-(instancetype)initWithName:(NSString*)name;

-(sqlite3*)sqlite;

//打开数据库
-(BOOL)open;

//关闭数据库
-(BOOL)close;

//执行ＳＱＬ
-(BOOL)executeUpdate:(NSString*)sql;
//执行查询
-(NSArray*)executeQuery:(NSString*)sql;

-(id)executeQuerySingle:(NSString*)sql;

//获取所有表
-(NSArray*)tableNameList;
//获取所有表结构信息
-(NSArray*)tableInfoList;

//获取表列名称
-(NSArray*)columnNameList:(NSString*)tablename;

//获取列名称
-(NSArray*)columnNameListWithSQL:(NSString*)sql;

@end
