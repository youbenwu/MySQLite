//
//  SQLManager.h
//  BOOK
//
//  Created by iflashbuy on 16/8/29.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLEntity.h"
#import "SQLQuery.h"
#import "SQLTransaction.h"

@class SQLEntity,SQLTransaction,SQLQuery;
@protocol SQLEntityMapped;

@interface SQLManager : NSObject

+(instancetype)manager;

-(instancetype)initWithDatabaseName:(NSString*)name;

-(void)registerSQLEntity:(SQLEntity*)en;
-(void)registerEntityType:(Class<SQLEntityMapped>)type;
-(void)registerEntityType:(Class)type primaryKey:(NSString*)pk autoIncrement:(BOOL)ai;


-(BOOL)insert:(id)entity;
-(BOOL)remove:(id)entity;
-(BOOL)removeALL:(Class)entityType;
-(BOOL)update:(id)entity;
-(id)select:(id)entityId entityType:(Class)entityType;
-(SQLQuery*)createSQLQuery:(NSString*)sql;
-(SQLQuery*)createSQLQuery:(NSString*)sql entityType:(Class)entityType;

-(SQLQuery*)createSQLQueryWithEntityType:(Class)type;
-(SQLQuery*)createSQLQueryWithEntityType:(Class)type where:(NSString*)where orderBy:(NSString*)order;

-(void)close;

-(BOOL)isClose;

//执行ＳＱＬ
-(BOOL)executeUpdate:(NSString*)sql;
//执行查询
-(NSArray*)executeQuery:(NSString*)sql;
//执行查询
-(id)executeQuerySingle:(NSString*)sql;

-(SQLTransaction*)getTransaction;

//-(BOOL)beginTransaction;
//-(BOOL)commitTransaction;
//-(BOOL)rollbackTransaction;


@end
