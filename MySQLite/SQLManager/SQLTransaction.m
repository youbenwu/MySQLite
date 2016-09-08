//
//  SQLTransaction.m
//  BOOK
//
//  Created by youbenwu on 16/8/31.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import "SQLTransaction.h"

@interface SQLTransaction(){

    __weak SQLDatabase* _db;
    
}

@end

@implementation SQLTransaction



-(instancetype)initWithSQLDatabase:(SQLDatabase*)db{

    self=[super init];
    
    if(self){
    
        _db=db;
    
    }
    
    return self;
}

-(BOOL)begin{
    
    NSLog(@"SQLTransaction begin in Thread %@",[NSThread currentThread]);
    
    if(_status>=1)
        return NO;
    
    _status=1;
    
    return [_db executeUpdate:@"BEGIN"];
    
//    char* err;
//    
//    int r=sqlite3_exec(_sqlite, "BEGIN", NULL, NULL, &err);
//
//    if(r!=SQLITE_OK){
//        NSLog(@"%s",err);
//    }
//    
//    sqlite3_free(err);
//    
//    return r==SQLITE_OK;
    
}
-(BOOL)commit{
    
     NSLog(@"SQLTransaction commit in Thread %@",[NSThread currentThread]);
    
    if(_status>=2)
        return NO;
    
    _status=2;
    
    return [_db executeUpdate:@"COMMIT"];
    
//    char* err;
    
//    int r=sqlite3_exec(_sqlite, "COMMIT", NULL, NULL, &err);
//    
//    if(r!=SQLITE_OK){
//        NSLog(@"%s",err);
//    }
//    
//    sqlite3_free(err);
//    
//    return r==SQLITE_OK;
    
    
}


-(BOOL)rollback{
    
    NSLog(@"SQLTransaction rollback in Thread %@",[NSThread currentThread]);
    
    if(_status>=3)
        return NO;
    
    _status=3;
    
    return [_db executeUpdate:@"ROLLBACK"];

//    char* err;
//    
//    int r=sqlite3_exec(_sqlite, "ROLLBACK", NULL, NULL, &err);
//    
//    if(r!=SQLITE_OK){
//        NSLog(@"%s",err);
//    }
//    
//    sqlite3_free(err);
//    
//    return r==SQLITE_OK;

}


-(void)dealloc{

    if(_status==1)
    {
        [self commit];
    }

}

@end
