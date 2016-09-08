//
//  SQLQuery.m
//  BOOK
//
//  Created by youbenwu on 16/8/29.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import "SQLQuery.h"
#import <sqlite3.h>
#import <objc/runtime.h>

@interface SQLParameter : NSObject


@property (nonatomic) int index;
@property (nonatomic,strong) NSString* name;


@property (nonatomic) int type;
@property (nonatomic,strong) id value;

@end

@implementation SQLParameter
@end

@interface SQLQuery(){

    SQLDatabase* _db;
    
    sqlite3* _sqlite;
    sqlite3_stmt * _stmt;
    
    SQLEntity* _SQLEntity;
    NSString* _sql;
    int _firstResults;
    int _maxResults;
    NSMutableArray* _parameters;

}

@end

@implementation SQLQuery

-(instancetype)initWithDatabase:(SQLDatabase *)db sql:(NSString*)sql SQLEntity:(SQLEntity*)en{
    self=[super init];
    if(self){
        _db=db;
        _sql=sql;
        _SQLEntity=en;
        _sqlite=db.sqlite;
        _parameters=[[NSMutableArray alloc]init];
    }
    return self;
}



-(void)prepare{
    
    NSString* sql=_sql;
    
    if(_maxResults>0){
        sql=[NSString stringWithFormat:@"%@ limit %d,%d",_sql,_firstResults,_maxResults];
    }
    NSLog(@"SQL:%@",sql);

    int result=sqlite3_prepare(_sqlite, [sql UTF8String], -1, &_stmt, nil);
    
    if(result==SQLITE_OK){
        
        for (SQLParameter* p in _parameters) {
            
            if(p.name){
               p.index=sqlite3_bind_parameter_index(_stmt, [[NSString stringWithFormat:@":%@",p.name] UTF8String]);
            }
            
            int type=p.type;
            
            if(_SQLEntity){
                if(!p.name){
                    const char* _name=sqlite3_bind_parameter_name(_stmt, p.index);
                    if(_name!=NULL)
                    p.name=[NSString stringWithUTF8String:_name];
                }
                SQLTableColumn* col=_SQLEntity.columns[p.name];
                if(col){
                    if([col.datatype isEqual:SQL_INTEGER]){
                        type=SQLTYPE_INTEGER;
                    }else if([col.datatype isEqual:SQL_FLOAT]){
                        type=SQLTYPE_FLOAT;
                    }else if([col.datatype isEqual:SQL_TEXT]){
                        type=SQLTYPE_TEXT;
                    }else if([col.datatype isEqual:SQL_BLOB]){
                        type=SQLTYPE_BLOB;
                    }
                }
            }
            int r;
            switch (type) {
                case SQLTYPE_INTEGER:
                {
                   r=sqlite3_bind_int64(_stmt, p.index, [p.value integerValue]);
                }
                    break;
                case SQLTYPE_FLOAT:
                {
                    r=sqlite3_bind_double(_stmt, p.index, [p.value doubleValue]);
                }
                    break;
                case SQLTYPE_TEXT:
                {
                    r=sqlite3_bind_text(_stmt, p.index, [p.value UTF8String], -1, NULL);
                }
                    break;
                case SQLTYPE_BLOB:
                {
                    r=sqlite3_bind_blob(_stmt, p.index, [(NSData*)p.value bytes], (int)[(NSData*)p.value length], NULL);
                }
                    break;
                case SQLTYPE_NULL:
                {
                    
                }
                    break;
                default:
                    break;
            }
            
            if(r!=SQLITE_OK){
                const char *err=sqlite3_errmsg(_sqlite);
                NSLog(@"%s",err);
            }
            
        }
    }else{
        const char *err=sqlite3_errmsg(_sqlite);
        NSLog(@"%s",err);
    }

}


-(SQLQuery*)setFirstResults:(int)first{
    _firstResults=first;
    return self;
}

-(SQLQuery*)setMaxResults:(int)max{
    _maxResults=max;
    return self;
}

-(SQLQuery*)setParameter:(id)value forName:(NSString*)name{
    
    if(!value)return self;

    [self setParameter:value forIndex:0];
    
    SQLParameter* p=[_parameters lastObject];
    
    p.name=name;

    return self;
}


-(SQLQuery*)setParameter:(id)value forIndex:(int)index{
    
   
    if([value isKindOfClass:[NSNumber class]]){
        
        return [self setNumberParameter:value forIndex:index];
    
    }else if([value isKindOfClass:[NSString class]]){
        
        return [self setStringParameter:value forIndex:index];
        
    }else if([value isKindOfClass:[NSData class]]){
        
        return [self setDataParameter:value forIndex:index];
        
    }else if([value isKindOfClass:[NSDate class]]){
        
        return [self setDateParameter:value forIndex:index];
        
    }else if([value isKindOfClass:[UIImage class]]){
        
        return [self setImageParameter:value forIndex:index];
        
    }else if(class_isMetaClass(object_getClass(value))){
        
        return [self setClassParameter:(Class)value forIndex:index];
        
    }else if(value){
        return [self setObjectParameter:value forIndex:index];
    }

    return self;
}

-(SQLQuery*)setObjectParameter:(id)value forIndex:(int)index{

    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=[NSKeyedArchiver archivedDataWithRootObject:value];
    p.index=index;
    p.type=SQLTYPE_BLOB;
    
    [_parameters addObject:p];
    
    return self;

}


-(SQLQuery*)setImageParameter:(UIImage*)value forIndex:(int)index{
    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=UIImagePNGRepresentation(value);
    p.index=index;
    p.type=SQLTYPE_BLOB;
    
    [_parameters addObject:p];
    
    return self;

}
-(SQLQuery*)setClassParameter:(Class)value forIndex:(int)index{

    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=NSStringFromClass(value);
    p.index=index;
    p.type=SQLTYPE_TEXT;
    
    [_parameters addObject:p];
    
    return self;


}

-(SQLQuery*)setNumberParameter:(NSNumber*)value forIndex:(int)index{
    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=value;
    p.index=index;
    p.type=SQLTYPE_FLOAT;
    
    [_parameters addObject:p];
    
    return self;
}

-(SQLQuery*)setStringParameter:(NSString*)value forIndex:(int)index;{
    
    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=value;
    p.index=index;
    p.type=SQLTYPE_TEXT;
    
    [_parameters addObject:p];

    return self;
    
}

-(SQLQuery*)setIntegerParameter:(NSInteger)value forIndex:(int)index{
    
    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=[NSNumber numberWithInteger:value];
    p.index=index;
    p.type=SQLTYPE_INTEGER;
    
    [_parameters addObject:p];
    
    return self;

}


-(SQLQuery*)setIntParameter:(int)value forIndex:(int)index{

    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=[NSNumber numberWithInt:value];
    p.index=index;
    p.type=SQLTYPE_INTEGER;
    
    [_parameters addObject:p];
    
    return self;

}



-(SQLQuery*)setBoolParameter:(BOOL)value forIndex:(int)index{

    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=[NSNumber numberWithBool:value];
    p.index=index;
    p.type=SQLTYPE_INTEGER;
    
    [_parameters addObject:p];
    
    return self;

}


-(SQLQuery*)setFloatParameter:(float)value forIndex:(int)index{
    
    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=[NSNumber numberWithFloat:value];
    p.index=index;
    p.type=SQLTYPE_FLOAT;
    
    [_parameters addObject:p];

    return self;

}

-(SQLQuery*)setDoubleParameter:(double)value forIndex:(int)index{
    
    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=[NSNumber numberWithDouble:value];
    p.index=index;
    p.type=SQLTYPE_FLOAT;
    
    [_parameters addObject:p];
    
    return self;

}
-(SQLQuery*)setDataParameter:(NSData*)value forIndex:(int)index{
    
    
    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=value;
    p.index=index;
    p.type=SQLTYPE_BLOB;
    
    [_parameters addObject:p];
    
    return self;

}

-(SQLQuery*)setDateParameter:(NSDate*)value forIndex:(int)index{
    
    SQLParameter* p=[[SQLParameter alloc]init];
    p.value=[NSNumber numberWithDouble:[value timeIntervalSince1970]];
    p.index=index;
    p.type=SQLTYPE_FLOAT;
    
    [_parameters addObject:p];
    
    return self;

}


-(NSInteger)count{

    if(!_SQLEntity)
        return 0;
    
    NSArray *array = [_sql componentsSeparatedByString:_SQLEntity.tableName];
    
    NSString* _count_sql=[NSString stringWithFormat:@"select count(*) from %@ %@",_SQLEntity.tableName,array[1]];
    
    NSNumber* c=[_db executeQuerySingle:_count_sql];

    return [c integerValue];
}

-(id)uniqueResult{
    
    _firstResults=0;
    _maxResults=1;
    
    NSArray* list=[self listResult];
    
    if([list count]>0)
        return list[0];

    return nil;
}


-(NSArray*)listResult{
    
    if(!_stmt)
    {
        [self prepare];
    }
    
    if(_SQLEntity){
    
        return [self _listResult:_SQLEntity];
        
    }else{
        
        return [self _listResult];
        
    }
}

-(NSArray*)_listResult{
    
    NSMutableArray* list=[[NSMutableArray alloc]init];
    
    while (sqlite3_step(_stmt) == SQLITE_ROW) {
        int colCount=sqlite3_column_count(_stmt);
        NSMutableArray* rowData=[[NSMutableArray alloc]init];
        for (int i=0; i<colCount; i++) {

            int colType = sqlite3_column_type(_stmt, i);
            switch (colType)
            {
                case SQLTYPE_INTEGER:{
                    //SQLITE_INTEGER
                    int intValue = sqlite3_column_int(_stmt, i);
                    [rowData addObject:[NSNumber numberWithInt:intValue]];
                }
                    break;
                case SQLTYPE_FLOAT:{
                    //SQLITE_FLOAT
                    double doubleValue = sqlite3_column_double(_stmt, i);
                    [rowData addObject:[NSNumber numberWithDouble:doubleValue]];
                }
                    break;
                case SQLTYPE_TEXT:{
                    //SQLITE_TEXT
                    char* textValue = (char*)sqlite3_column_text(_stmt, i);
                    [rowData addObject:[NSString stringWithUTF8String:textValue]];
                }
                    break;
                case SQLTYPE_BLOB:
                {
                    //SQLITE_BLOB
                    [rowData addObject:[NSData dataWithBytes:sqlite3_column_blob(_stmt, i) length:sqlite3_column_bytes(_stmt, 1)]];
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
    
    return list;
    
}



-(NSArray*)_listResult:(SQLEntity*)en{
    
    NSMutableArray* list=[[NSMutableArray alloc]init];
    
    NSArray* cols=[_db columnNameListWithSQL:[NSString stringWithFormat:@"%@ %@",[_sql componentsSeparatedByString:_SQLEntity.tableName][0],en.tableName]];
    
    Class cls=NSClassFromString(en.entityName);
    
    while (sqlite3_step(_stmt) == SQLITE_ROW) {
        int colCount=sqlite3_column_count(_stmt);
        id rowObj=[cls new];
        for (int i=0; i<colCount; i++) {
            SQLEntityProperty* col=en.columns[cols[i]];
            if(!col)
                continue;
            int colType = sqlite3_column_type(_stmt, i);
            switch (colType)
            {
                case SQLTYPE_INTEGER:{
                    //SQLITE_INTEGER
                    int intValue = sqlite3_column_int(_stmt, i);
                    switch (col.propertyType) {
                        case PRO_TYPE_INTEGER:
                        case PRO_TYPE_FLOAT:
                        {
                            [rowObj setValue:[NSNumber numberWithInt:intValue] forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_STRING:
                        {
                            [rowObj setValue:[NSString stringWithFormat:@"%d",intValue] forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_DATE:
                        {
                            [rowObj setValue:[NSDate dateWithTimeIntervalSince1970:intValue] forKey:col.propertyName];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case SQLTYPE_FLOAT:{
                    //SQLITE_FLOAT
                    double doubleValue = sqlite3_column_double(_stmt, i);
                    switch (col.propertyType) {
                        case PRO_TYPE_FLOAT:
                        case PRO_TYPE_INTEGER:
                        {
                            [rowObj setValue:[NSNumber numberWithDouble:doubleValue] forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_STRING:
                        {
                            [rowObj setValue:[NSString stringWithFormat:@"%f",doubleValue] forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_DATE:
                        {
                            [rowObj setValue:[NSDate dateWithTimeIntervalSince1970:doubleValue] forKey:col.propertyName];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case SQLTYPE_TEXT:{
                    //SQLITE_TEXT
                    char* textValue = (char*)sqlite3_column_text(_stmt, i);
                    switch (col.propertyType) {
                        case PRO_TYPE_STRING:
                        {
                            [rowObj setValue:[NSString stringWithUTF8String:textValue] forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_CLASS:{
                            [rowObj setValue:NSClassFromString([NSString stringWithUTF8String:textValue]) forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_INTEGER:
                        {
                            [rowObj setValue:[NSNumber numberWithInteger:[[NSString stringWithUTF8String:textValue] integerValue]] forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_FLOAT:
                        {
                            [rowObj setValue:[NSNumber numberWithDouble:[[NSString stringWithUTF8String:textValue] doubleValue]] forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_DATA:
                        {
                            [rowObj setValue: [NSData dataWithBytes:textValue length:strlen(textValue)] forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_DATE:
                        {
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat: SQLDATE_FORMAT];
                            NSDate *date= [dateFormatter dateFromString:[NSString stringWithUTF8String:textValue]];
                            [rowObj setValue:date forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_CODING:{
                            id obj=[[[NSKeyedUnarchiver alloc] initForReadingWithData:[NSData dataWithBytes:textValue length:strlen(textValue)]] decodeObject];
                            [rowObj setValue:obj forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_IMAGE:{
                            [rowObj setValue:[UIImage imageWithData: [NSData dataWithBytes:textValue length:strlen(textValue)]] forKey:col.propertyName];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case SQLTYPE_BLOB:
                {
                    //SQLITE_BLOB
                    NSData* data=[NSData dataWithBytes:sqlite3_column_blob(_stmt, i) length:sqlite3_column_bytes(_stmt, i)];
                    switch (col.propertyType) {
                        case PRO_TYPE_CODING:
                        {
                            [rowObj setValue:[NSKeyedUnarchiver unarchiveObjectWithData:data] forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_IMAGE:
                        {
                            [rowObj setValue:[UIImage imageWithData: data] forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_DATA:
                        {
                            [rowObj setValue: data forKey:col.propertyName];
                        }
                            break;
                        case PRO_TYPE_STRING:
                        {
                            [rowObj setValue: [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding] forKey:col.propertyName];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                case SQLTYPE_NULL:
                    //SQLITE_NULL
                    break;
            }
        }
        [list addObject:rowObj];
    }
    
    return list;
    
}

-(BOOL)executeUpdate{
    
    if(!_stmt)
    {
        [self prepare];
    }
    
    if (sqlite3_step(_stmt) != SQLITE_DONE){
        const char *err=sqlite3_errmsg(_sqlite);
        NSLog(@"%s",err);
        return NO;
    }
    return YES;
}


-(BOOL)reset{
    
    if(sqlite3_reset(_stmt)!=SQLITE_OK){
        const char *err=sqlite3_errmsg(_sqlite);
        NSLog(@"%s",err);
        return NO;
    }
    
    return YES;

}


-(void)dealloc{
    if(sqlite3_finalize(_stmt)!=SQLITE_OK){
        const char *err=sqlite3_errmsg(_sqlite);
        NSLog(@"%s",err);
    }
}

@end
