//
//  SQLDatabase.m
//  BOOK
//
//  Created by iflashbuy on 16/8/29.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import "SQLDatabase.h"


@interface SQLDatabase(){

    NSString* _databaseName;
    sqlite3 * _database;

}

@end

@implementation SQLDatabase

-(instancetype)initWithName:(NSString*)name{
    
    self=[super init];
    
    _databaseName=name;
    
    return self;
}

-(sqlite3*)sqlite{
    return _database;
}

-(BOOL)open{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:_databaseName];
    int result=sqlite3_open([path UTF8String], &_database);
    if(result!=SQLITE_OK){
        const char *err=sqlite3_errmsg(_database);
        NSLog(@"%s",err);
    }
    return result==SQLITE_OK;
}

-(BOOL)close{
    int result=sqlite3_close_v2(_database);
    if(result!=SQLITE_OK){
       const char *err=sqlite3_errmsg(_database);
       NSLog(@"%s",err);
    }
    return result==SQLITE_OK;
}

-(BOOL)executeUpdate:(NSString*)sql{
    
    NSLog(@"SQL:%@",sql);
    
    char *err=NULL;
    
    int result=sqlite3_exec(_database, [sql UTF8String], NULL, NULL, &err);
    
    if (err!=NULL)
    {
        NSLog(@"%s",err);
        sqlite3_free(err);
    }
    
    return result==SQLITE_OK;
}

-(NSArray*)executeQuery:(NSString*)sql{
    
    NSLog(@"SQL:%@",sql);
    
    NSMutableArray* list=[[NSMutableArray alloc]init];

    sqlite3_stmt * stmt;

    if (sqlite3_prepare(_database, [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            int colCount=sqlite3_column_count(stmt);
            NSMutableArray* rowData=[[NSMutableArray alloc]init];
            for (int i=0; i<colCount; i++) {
                int colType = sqlite3_column_type(stmt, i);
                switch (colType)
                {
                    case SQLTYPE_INTEGER:{
                        //SQLITE_INTEGER
                        int intValue = sqlite3_column_int(stmt, i);
                        [rowData addObject:[NSNumber numberWithInt:intValue]];
                    }
                        break;
                    case SQLTYPE_FLOAT:{
                        //SQLITE_FLOAT
                        double doubleValue = sqlite3_column_double(stmt, i);
                        [rowData addObject:[NSNumber numberWithDouble:doubleValue]];
                    }
                        break;
                    case SQLTYPE_TEXT:{
                        //SQLITE_TEXT
                        char* textValue = (char*)sqlite3_column_text(stmt, i);
                        [rowData addObject:[NSString stringWithUTF8String:textValue]];
                    }
                        break;
                    case SQLTYPE_BLOB:
                    {
                        //SQLITE_BLOB
                        [rowData addObject:[NSData dataWithBytes:sqlite3_column_blob(stmt, i) length:sqlite3_column_bytes(stmt, 1)]];
                    }
                        break;
                    case SQLTYPE_NULL:
                        //SQLITE_NULL
                        [rowData addObject:[NSNull null]];
                        break;  
                }
            }
            [list addObject:rowData];
        }
    }else{
        const char *err=sqlite3_errmsg(_database);
        NSLog(@"%s",err);
    }
    
    sqlite3_finalize(stmt);
    
    return list;

}

-(id)executeQuerySingle:(NSString*)sql{

    NSArray* list=[self executeQuery:sql];
    
    if(list.count>0)
        return list[0][0];
    
    return nil;

}


-(NSArray*)tableNameList{
    
    NSArray* r=[self executeQuery:@"select name from sqlite_master where type='table'"];
    
    NSMutableArray * list=[[NSMutableArray alloc]init];
    
    for (NSArray* arr in r) {
        [list addObject:arr[0]];
    }

    return list;

}

//获取表信息
-(NSArray*)tableInfoList
{
    return [self executeQuery:@"select name,sql from sqlite_master where type='table' order by name"];
}


-(NSArray*)columnNameList:(NSString*)tablename{
    return [self columnNameListWithSQL:[NSString stringWithFormat:@"SELECT * FROM %@",tablename]];
}


-(NSArray*)columnNameListWithSQL:(NSString*)sql{
    
    NSMutableArray* list=[[NSMutableArray alloc]init];
    sql=[NSString stringWithFormat:@"%@ limit 0,1",sql];
    NSLog(@"SQL:%@",sql);
    char **res=NULL;
    int row=0, col=0;
    char *err=NULL;
    //第一行是列名称
    if(sqlite3_get_table(_database, [sql UTF8String], &res, &row, &col, &err)==SQLITE_OK){
        for (int j=0; j<col; j++)
        {
            char *pv = *(res+j);
            [list addObject:[NSString stringWithUTF8String:pv]];
        }
    }
    if (err!=NULL)
    {
        NSLog(@"%s",err);
        sqlite3_free(err);
    }
    sqlite3_free_table(res);
    return list;
}

@end
