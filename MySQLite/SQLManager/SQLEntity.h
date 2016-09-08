//
//  SQLEntity.h
//  BOOK
//
//  Created by youbenwu on 16/8/30.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLTable.h"
#import "SQLManager.h"

#define PRO_TYPE_CODING 1
#define PRO_TYPE_STRING 2
#define PRO_TYPE_INTEGER 3
#define PRO_TYPE_FLOAT 4
#define PRO_TYPE_DATA 5
#define PRO_TYPE_CLASS 6
#define PRO_TYPE_DATE 7
#define PRO_TYPE_IMAGE 8

@class SQLEntity;
@protocol SQLEntityMapped

+(SQLEntity*)SQLEntity;

@end

@interface SQLEntityProperty : SQLTableColumn

@property (nonatomic,strong) NSString* propertyName;//名称
@property (nonatomic) int propertyType;//类型

@end


@interface SQLEntity : SQLTable<SQLEntityMapped>

@property (nonatomic,strong) NSString* entityName;

-(instancetype)initWithEntityType:(Class)type tableName:(NSString*)tableName;

-(void)setProperty:(NSString*)name type:(int)type columnName:(NSString*)columnName datatype:(NSString*)datatype primaryKey:(BOOL)primaryKey autoIncrement:(BOOL)autoIncrement unique:(BOOL)unique notNull:(BOOL)notNull;


-(SQLEntityProperty*)propertyWithName:(NSString*)name;


@end






