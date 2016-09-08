//
//  SQLTable.m
//  BOOK
//
//  Created by youbenwu on 16/9/2.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import "SQLTable.h"

@interface SQLTable(){

    NSString* _insertSQL;
    NSString* _deleteSQL;
    NSString* _createSQL;
    NSString* _findSQL;
    NSString* _updateSQL;

}

@end

@implementation SQLTable

-(instancetype)init{
    self=[super init];
    if(self){
        _columns=[[NSMutableDictionary alloc]init];
        
    }
    return self;
}


-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if(self){
        _tableName=[aDecoder decodeObjectForKey:@"tableName"];
        _columns=(NSMutableDictionary*)[aDecoder decodeObjectForKey:@"columns"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.tableName forKey:@"tableName"];
    [aCoder encodeObject:self.columns forKey:@"columns"];
}

-(void)setColumn:(SQLTableColumn *)column{
    _columns[column.columnName]=column;
}

-(SQLTableColumn*)primaryKey{
    for (NSString* name in _columns) {
        SQLTableColumn* c=_columns[name];
        if(c.PK)
            return c;
    }
    return nil;
}


-(NSString*)createSQL{
    
    if(!_createSQL){
        NSMutableString* sql=[[NSMutableString alloc]init];
        
        [sql appendFormat:@"CREATE TABLE IF NOT EXISTS %@ (",_tableName];
        
        for (NSString* c in _columns) {
            SQLTableColumn* col=_columns[c];
            
            [sql appendFormat:@"%@ %@ ",col.columnName,col.datatype];
            
            if(col.PK)
                [sql appendString:@"PRIMARY KEY "];
            if(col.AI)
                [sql appendString:@"AUTOINCREMENT "];
            if(col.UQ)
                [sql appendString:@"UNIQUE "];
            if(col.NN)
                [sql appendString:@"NOT NULL "];
            
            [sql appendString:@","];
            
        }
        [sql deleteCharactersInRange:NSMakeRange(sql.length-1, 1)];
        [sql appendString:@")"];
        _createSQL=sql;
    }
    
    
    return _createSQL;
}

-(NSString*)findSQL{
    
    if(!_findSQL){
        SQLTableColumn* keyCol=[self primaryKey];
        
        _findSQL= [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@=?",_tableName,keyCol.columnName];

    }
    
    return _findSQL;
    
}

-(NSString*)updateSQL{
    
    if(!_updateSQL){
        NSMutableString* sql=[[NSMutableString alloc]init];
        
        [sql appendFormat:@"UPDATE %@ SET ",_tableName];
        
        for (NSString* c in _columns) {
            SQLTableColumn* col=_columns[c];
            if(col.PK)
                continue;
            [sql appendFormat:@"%@=:%@ ,",col.columnName,col.columnName];
            
        }
        [sql deleteCharactersInRange:NSMakeRange(sql.length-1, 1)];
        SQLTableColumn* keyCol=[self primaryKey];
        [sql appendFormat:@" WHERE %@=:%@ ",keyCol.columnName,keyCol.columnName];
        
        _updateSQL=sql;
    }
    
    return _updateSQL;
    
}

-(NSString*)insertSQL{
    
    if(!_insertSQL){
    
        NSMutableString* sql=[[NSMutableString alloc]init];
        [sql appendFormat:@"INSERT INTO %@ ",_tableName];
        NSMutableString* csql=[[NSMutableString alloc]init];
        NSMutableString* vsql=[[NSMutableString alloc]init];
        [csql appendFormat:@"("];
        [vsql appendFormat:@"("];
        for (NSString* c in self.columns) {
            SQLTableColumn* col=_columns[c];
            [csql appendFormat:@"%@,",col.columnName];
            [vsql appendFormat:@":%@,",col.columnName];
        }
        [csql deleteCharactersInRange:NSMakeRange(csql.length-1, 1)];
        [vsql deleteCharactersInRange:NSMakeRange(vsql.length-1, 1)];
        [csql appendFormat:@")"];
        [vsql appendFormat:@")"];
        [sql appendString:csql];
        [sql appendString:@" VALUES "];
        [sql appendString:vsql];
        
        _insertSQL=sql;
        
    }
    
    return _insertSQL;
    
}

-(NSString*)deleteSQL{
    if(!_deleteSQL){
        SQLTableColumn* keyCol=[self primaryKey];
        _deleteSQL= [NSString stringWithFormat:@"DELETE %@ WHERE %@=?",_tableName,keyCol.columnName];
    
    }
    return _deleteSQL;
}


@end
