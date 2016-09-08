//
//  SQLTable.h
//  BOOK
//
//  Created by youbenwu on 16/9/2.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLTableColumn.h"

#define SQLDATE_FORMAT @"yyyyMMddHHmmss"

#define SQLTYPE_INTEGER 1
#define SQLTYPE_FLOAT 2
#define SQLTYPE_TEXT 3
#define SQLTYPE_BLOB 4
#define SQLTYPE_NULL 5

#define SQL_INTEGER @"INTEGER"
#define SQL_FLOAT @"REAL"
#define SQL_TEXT @"TEXT"
#define SQL_BLOB @"BLOB"
#define SQL_NULL @"NULL"

@interface SQLTable : NSObject<NSCoding>

@property (nonatomic,strong) NSString* tableName;
@property (nonatomic,strong,readonly) NSMutableDictionary* columns;
//@property (nonatomic,strong,readonly) NSString* SQL;


-(SQLTableColumn*)primaryKey;

-(void)setColumn:(SQLTableColumn *)column;

-(NSString *)createSQL;
-(NSString *)findSQL;
-(NSString *)updateSQL;
-(NSString *)insertSQL;
-(NSString *)deleteSQL;


@end
