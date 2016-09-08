//
//  SQLEntity.m
//  BOOK
//
//  Created by youbenwu on 16/8/30.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import "SQLEntity.h"



@implementation SQLEntityProperty

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        self.propertyName=[aDecoder decodeObjectForKey:@"propertyName"];
        self.propertyType=[aDecoder decodeIntForKey:@"propertyType"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.propertyName forKey:@"propertyName"];
    [aCoder encodeInt:self.propertyType forKey:@"propertyType"];
}

@end




@implementation SQLEntity

-(instancetype)initWithEntityType:(Class)type tableName:(NSString*)tableName{

    self=[super init];
    
    _entityName=NSStringFromClass(type);
    self.tableName=tableName;


    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        _entityName=[aDecoder decodeObjectForKey:@"_entityName"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_entityName forKey:@"_entityName"];
}


-(void)setProperty:(NSString*)name type:(int)type columnName:(NSString*)columnName datatype:(NSString*)datatype primaryKey:(BOOL)primaryKey autoIncrement:(BOOL)autoIncrement unique:(BOOL)unique notNull:(BOOL)notNull{
    SQLEntityProperty* col=[[SQLEntityProperty alloc]init];
    col.propertyName=name;
    col.propertyType=type;
    col.columnName=columnName;
    col.datatype=datatype;
    col.PK=primaryKey;
    col.AI=autoIncrement;
    col.UQ=unique;
    col.UN=notNull;
    if(!datatype){
        if(type==PRO_TYPE_STRING){
            col.datatype=SQL_TEXT;
        }else if(type==PRO_TYPE_INTEGER){
            col.datatype=SQL_INTEGER;
        }else if(type==PRO_TYPE_FLOAT){
            col.datatype=SQL_FLOAT;
        }else if(type==PRO_TYPE_DATA){
            col.datatype=SQL_BLOB;
        }else if(type==PRO_TYPE_DATE){
            col.datatype=SQL_FLOAT;
        }else if(type==PRO_TYPE_CODING){
            col.datatype=SQL_BLOB;
        }else if(type==PRO_TYPE_IMAGE){
            col.datatype=SQL_BLOB;
        }else if(type==PRO_TYPE_CLASS){
            col.datatype=SQL_TEXT;
        }else{
            col.datatype=SQL_NULL;
        }
    }
    if(!columnName)
        col.columnName=name;
    
    [self setColumn:col];
}


+(SQLEntity*)SQLEntity{

    SQLEntity* en=[[SQLEntity alloc]initWithEntityType:self tableName:NSStringFromClass(self)];
    
    [en setProperty:@"entityName" type:PRO_TYPE_STRING columnName:@"entityName" datatype:SQL_TEXT primaryKey:YES autoIncrement:NO unique:NO notNull:NO];
    [en setProperty:@"tableName" type:PRO_TYPE_STRING columnName:@"tableName" datatype:SQL_TEXT primaryKey:NO autoIncrement:NO unique:YES notNull:YES];
    [en setProperty:@"columns" type:PRO_TYPE_CODING columnName:@"columns" datatype:SQL_BLOB primaryKey:NO autoIncrement:NO unique:NO notNull:YES];
    
    return en;
    
}

-(SQLEntityProperty*)propertyWithName:(NSString*)name{

    for (SQLEntityProperty* p in self.columns) {
        if([p.propertyName isEqualToString:name])
            return p;
    }
    
    return nil;

}

@end



