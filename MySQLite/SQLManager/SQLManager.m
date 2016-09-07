//
//  SQLManager.m
//  BOOK
//
//  Created by iflashbuy on 16/8/29.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import "SQLManager.h"
#import "SQLDatabase.h"
#import "ClassInfo.h"

@interface SQLManager(){

    SQLDatabase * _database;
    
    NSMutableDictionary* _entityMap;
    
    BOOL done;

}

@end

@implementation SQLManager


+(instancetype)manager{
    static SQLManager* m;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        m=[[SQLManager alloc]initWithDatabaseName:@"def_database"];
        
    });
    
    return m;
}

-(instancetype)initWithDatabaseName:(NSString*)name{
    
    self=[super init];
    
    _entityMap=[[NSMutableDictionary alloc]init];
    
    _database=[[SQLDatabase alloc]initWithName:name];
    
    [_database open];
    
    [self loadEntityMapped];

    return self;
}


-(void)loadEntityMapped{
    

    SQLEntity* en=[SQLEntity SQLEntity];

    _entityMap[en.entityName]=en;
    
    NSArray* list=[[self createSQLQueryWithEntityType:[SQLEntity class]] listResult];
    
    [_entityMap removeAllObjects];
    for (SQLEntity* en in list) {
        
        [_entityMap setObject:en forKey:en.entityName];
    }

    [self registerSQLEntity:en];

}


-(void)registerSQLEntity:(SQLEntity*)en{
    
    NSString* name=en.entityName;
    
    if(_entityMap[name]==nil){
        
        _entityMap[name]=en;
        
        SQLTransaction* t=[self getTransaction];
        
        [t begin];
        
        BOOL r;
    
       r=[self executeUpdate:en.createSQL];
        
        if(!r){
            [t rollback];
            return;
        }
        
       r=[self insert:en];
        
        if(!r){
            [t rollback];
            return;
        }
        
        r=[t commit];
        
        if(!r)
            return;
        
    }else{
    
        SQLEntity* old_en=_entityMap[name];
        
        if(old_en==en)
            return;
        
        
        if(![old_en.tableName isEqualToString:en.tableName]){
        
            SQLTransaction* t=[self getTransaction];
            
            [t begin];
            
            BOOL r=[self executeUpdate:[NSString stringWithFormat:@" ALTER TABLE %@ RENAME TO %@ ",old_en.tableName,en.tableName]];
            
            if(!r){
                [t rollback];
                return;
            }
            
            r=[t commit];
            
            if(!r)
                return;
            
            old_en.tableName=en.tableName;
        
        }
        
        
        BOOL create = NO;
        
        NSMutableArray* addCols=[[NSMutableArray alloc]init];
        
        for (NSString* cn in en.columns) {
            SQLTableColumn*col=en.columns[cn];
            SQLTableColumn* old_col=old_en.columns[col.columnName];
            
            if(!old_col){
                [addCols addObject:col];
            }else if(![old_col isEqual:col]){
                create=YES;
                break;
            }
            
        }
        
        if(create){
            
            SQLTransaction* t=[self getTransaction];
            
            [t begin];
            
            BOOL r;
            
            //将表名改为临时表
           
            NSString* _sql=[NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@_temp",old_en.tableName,old_en.tableName];
            
            r=[self executeUpdate:_sql];
            
            if(!r){
                [t rollback];
                return;
            }
            
             old_en.tableName=[NSString stringWithFormat:@"%@_temp",old_en.tableName];
            
            //创建新表
           
            r=[self executeUpdate:en.createSQL];
            
            if(!r){
                [t rollback];
                return;
            }

            //导入数据
            
            r=[self importDataTo:en from:old_en];
            
            if(!r){
                [t rollback];
                return;
            }
            
            //更新sqlite_sequence
            if(en.primaryKey.AI){
                _sql=[NSString stringWithFormat:@"UPDATE sqlite_sequence SET seq = 3 WHERE name = %@",old_en.tableName];
                
                r=[self executeUpdate:_sql];
                
                if(!r){
                    [t rollback];
                    return;
                }
            }
            
            _sql=[NSString stringWithFormat:@"DROP TABLE %@",old_en.tableName];
            
            r=[self executeUpdate:_sql];
            
            if(!r){
                [t rollback];
                return;
            }
        
            r=[t commit];
            
            if(!r)
                return;
        
        }else if(addCols.count>0){
            
            SQLTransaction* t=[self getTransaction];
            
            [t begin];

            BOOL r;
        
            for (SQLTableColumn* col in addCols) {
                
                NSMutableString* sql=[[NSMutableString alloc]init];
                
                [sql appendFormat:@"ALTER TABLE %@  ADD COLUMN %@ %@ ",en.tableName,col.columnName,col.datatype];

                if(col.PK)
                    [sql appendString:@"PRIMARY KEY "];
                if(col.AI)
                    [sql appendString:@"AUTOINCREMENT "];
                if(col.UQ)
                    [sql appendString:@"UNIQUE "];
                if(col.NN)
                    [sql appendString:@"NOT NULL "];
                
                r=[self executeUpdate:sql];
                
                if(!r){
                    [t rollback];
                    return;
                }
            }
            
            r=[t commit];
            
            if(!r)
                return;
            
        }
        
        [self update:en];
        
        _entityMap[name]=en;
    
    }

}

-(BOOL)importDataTo:(SQLEntity*)en from:(SQLEntity*)old_en{

    
    NSMutableArray* cols=[[NSMutableArray alloc]init];
    NSMutableArray* cols1=[[NSMutableArray alloc]init];
    
    for (NSString* name1 in old_en.columns) {
        
        SQLEntityProperty* col1=old_en.columns[name1];
        SQLEntityProperty* col=en.columns[col1.columnName];
        if(!col)
            col=[en propertyWithName:col1.propertyName];
        
        if(col){
        
            [cols addObject:col];
            [cols1 addObject:col1];
        
        }
    
    }
    
    if(cols.count>0){
        
        NSMutableString* vsql=[[NSMutableString alloc]init];
        NSMutableString* ssql=[[NSMutableString alloc]init];

        
        for (int i=0; i<cols.count; i++) {
            SQLEntityProperty* col=cols[i];
            SQLEntityProperty* col1=cols1[i];
            
             [vsql appendFormat:@"%@,",col.columnName];
            
             [ssql appendFormat:@"%@ as %@,",col1.columnName,col.columnName];
            
        }
        
        [vsql deleteCharactersInRange:NSMakeRange(vsql.length-1, 1)];
        [ssql deleteCharactersInRange:NSMakeRange(ssql.length-1, 1)];
        
        NSMutableString* sql=[[NSMutableString alloc]init];
        
        [sql appendFormat:@"INSERT INTO %@ (%@) SELECT %@ FROM %@",en.tableName,vsql,ssql,old_en.tableName];
        
        BOOL r=[self executeUpdate:sql];
        
        return r;
    
    }

    return YES;
}

-(void)registerEntityType:(Class<SQLEntityMapped>)type{

    SQLEntity* en=[type SQLEntity];
    
    if(!en)
        return;
    
    [self registerSQLEntity:en];

}

-(void)registerEntityType:(Class)type primaryKey:(NSString*)pk autoIncrement:(BOOL)ai{

    SQLEntity* en=[[SQLEntity alloc]init];
    
    en.entityName=NSStringFromClass(type);
    en.tableName=en.entityName;
    
    ClassInfo * cinfo=[ClassInfo classInfoWithClass:type];
    
    while (cinfo&&cinfo.cls!=[NSObject class]) {
        for (NSString* name in cinfo.propertyInfos) {
            PropertyInfo* pinfo=cinfo.propertyInfos[name];
            
            if(pinfo.getter&&pinfo.setter){
                
                NSLog(@"property:%@ type:%d",pinfo.name,(int)(pinfo.type& EncodingTypeMask));
                switch (pinfo.type& EncodingTypeMask) {
                    case EncodingTypeBool:
                    {
                        [en setProperty:pinfo.name type:PRO_TYPE_INTEGER columnName:pinfo.name datatype:SQL_INTEGER primaryKey:NO autoIncrement:NO unique:NO notNull:NO];
                    }
                        break;
                    case EncodingTypeInt8:
                    case EncodingTypeUInt8:
                    case EncodingTypeInt16:
                    case EncodingTypeInt32:
                    case EncodingTypeInt64:
                    case EncodingTypeUInt64:
                    {
                        [en setProperty:pinfo.name type:PRO_TYPE_INTEGER columnName:pinfo.name datatype:SQL_INTEGER primaryKey:NO autoIncrement:NO unique:NO notNull:NO];
                    }
                        break;
                    case EncodingTypeFloat:
                    case EncodingTypeDouble:
                    case EncodingTypeLongDouble:
                    {
                        [en setProperty:pinfo.name type:PRO_TYPE_FLOAT columnName:pinfo.name datatype:SQL_FLOAT primaryKey:NO autoIncrement:NO unique:NO notNull:NO];
                    }
                        break;
                    case EncodingTypeObject:
                    {
                        if([pinfo.cls isSubclassOfClass:[NSString class]]){
                            
                            [en setProperty:pinfo.name type:PRO_TYPE_STRING columnName:pinfo.name datatype:SQL_TEXT primaryKey:NO autoIncrement:NO unique:NO notNull:NO];
                            
                        }else if([pinfo.cls isSubclassOfClass:[NSData class]]){
                            [en setProperty:pinfo.name type:PRO_TYPE_DATA columnName:pinfo.name datatype:SQL_BLOB primaryKey:NO autoIncrement:NO unique:NO notNull:NO];
                        }else if([pinfo.cls isSubclassOfClass:[NSNumber class]]){
                            if([pinfo.name isEqual:pk]&&ai){
                                 [en setProperty:pinfo.name type:PRO_TYPE_INTEGER columnName:pinfo.name datatype:SQL_INTEGER primaryKey:NO autoIncrement:NO unique:NO notNull:NO];
                            }else{
                                [en setProperty:pinfo.name type:PRO_TYPE_FLOAT columnName:pinfo.name datatype:SQL_FLOAT primaryKey:NO autoIncrement:NO unique:NO notNull:NO];
                            }
                        }else if([pinfo.cls isSubclassOfClass:[NSDate class]]){
                            [en setProperty:pinfo.name type:PRO_TYPE_DATE columnName:pinfo.name datatype:SQL_FLOAT primaryKey:NO autoIncrement:NO unique:NO notNull:NO];
                        }else if([pinfo.cls isSubclassOfClass:[UIImage class]]){
                             [en setProperty:pinfo.name type:PRO_TYPE_IMAGE columnName:pinfo.name datatype:SQL_BLOB primaryKey:NO autoIncrement:NO unique:NO notNull:NO];
                        }else{
                            [en setProperty:pinfo.name type:PRO_TYPE_CODING columnName:pinfo.name datatype:SQL_BLOB primaryKey:NO autoIncrement:NO unique:NO notNull:NO];
                        }
                        
                    }
                        break;
                    case EncodingTypeClass:
                    {
                        [en setProperty:pinfo.name type:PRO_TYPE_CLASS columnName:pinfo.name datatype:SQL_TEXT primaryKey:NO autoIncrement:NO unique:NO notNull:NO];
                    }
                        break;
                        
                        
                    default:
                        break;
                }
                
            }
            
        }
        cinfo=cinfo.superClassInfo;
    }
    
    SQLEntityProperty* PK=en.columns[pk];
    PK.PK=YES;
    PK.AI=ai;
    
    if(PK.AI){
        PK.datatype=SQL_INTEGER;
    }
    
    [self registerSQLEntity:en];

}


-(BOOL)insert:(id)entity{

    SQLEntity* en=_entityMap[NSStringFromClass([entity class])];
    
    if(!en)
        return NO;
    
    SQLQuery* q=[[SQLQuery alloc]initWithDatabase:_database sql:en.insertSQL SQLEntity:en];
    
    for (NSString* c in en.columns) {
        SQLEntityProperty* col=en.columns[c];
        
        [q setParameter:[entity valueForKey:col.propertyName] forName:col.columnName];
        
    }
    
    BOOL r= [q executeUpdate];

    if(r){
        
        SQLEntityProperty* idCol=(SQLEntityProperty* )en.primaryKey;
        
        id idValue=[entity valueForKey:idCol.propertyName];
        
        if(!idValue){
            
            idValue=[self executeQuerySingle:@"select last_insert_rowid()"];
            
            [entity setValue:idValue forKey:idCol.propertyName];
            
        }
    
    }

    return r;
}


-(BOOL)remove:(id)entity{
    
    SQLEntity* en=_entityMap[NSStringFromClass([entity class])];
    
    if(!en)
        return NO;

    SQLEntityProperty* idCol=(SQLEntityProperty*)en.primaryKey;
    
    id idValue=[entity valueForKey:idCol.propertyName];
    
    if(!idValue)
        return NO;
    
    SQLQuery* q=[[SQLQuery alloc]initWithDatabase:_database sql:en.deleteSQL SQLEntity:en];
    
    BOOL r=[[q setParameter:idValue forIndex:1] executeUpdate];
    
    return r;

}


-(BOOL)update:(id)entity{
    
    SQLEntity* en=_entityMap[NSStringFromClass([entity class])];
    
    if(!en)
        return NO;
    
    SQLQuery* q=[[SQLQuery alloc]initWithDatabase:_database sql:en.updateSQL SQLEntity:en];

    for (NSString* c in en.columns) {
        SQLEntityProperty* col=en.columns[c];
        
        [q setParameter:[entity valueForKey:col.propertyName] forName:col.columnName];
        
    }

    return [q executeUpdate];
}


-(BOOL)removeALL:(Class)entityType{

    SQLEntity* en=_entityMap[NSStringFromClass(entityType)];
    
    if(!en)
        return NO;

    NSString* sql=[NSString stringWithFormat:@"delete %@",en.tableName];
    
    return [self executeUpdate:sql];
    
}


-(id)select:(id)entityId entityType:(Class)entityType;{
    
    SQLEntity* en=_entityMap[NSStringFromClass(entityType)];
    
    if(!en)
        return nil;
    
    SQLQuery* q=[[SQLQuery alloc]initWithDatabase:_database sql:en.findSQL SQLEntity:en];
    
    id r=[q setParameter:entityId forIndex:1].uniqueResult;

    return r;
    
}


-(SQLQuery*)createSQLQuery:(NSString*)sql{
    
    SQLQuery* q=[[SQLQuery alloc]initWithDatabase:_database sql:sql SQLEntity:nil];

    return q;
}

-(SQLQuery*)createSQLQuery:(NSString*)sql entityType:(Class)entityType{

    SQLEntity* en=_entityMap[NSStringFromClass(entityType)];
    
    SQLQuery* q=[[SQLQuery alloc]initWithDatabase:_database sql:sql SQLEntity:en];
    
    return q;

}


-(SQLQuery*)createSQLQueryWithEntityType:(Class)type{

    return [self createSQLQueryWithEntityType:type where:nil orderBy:nil];

}
-(SQLQuery*)createSQLQueryWithEntityType:(Class)type where:(NSString*)where orderBy:(NSString*)order{

    SQLEntity* en=_entityMap[NSStringFromClass(type)];
    
    if(!en)
        return nil;
    
    NSString* sql=[NSString stringWithFormat:@"SELECT * FROM %@",en.tableName];
    
    if(where){
       sql=[NSString stringWithFormat:@"%@ where %@",sql,where];
    }
    
    if(order){
        sql=[NSString stringWithFormat:@"%@ order by %@",sql,order];
    }
    
    SQLQuery* q=[[SQLQuery alloc]initWithDatabase:_database sql:sql SQLEntity:en];

    return q;
}


//执行ＳＱＬ
-(BOOL)executeUpdate:(NSString*)sql{

    return [_database executeUpdate:sql];
}
//执行查询
-(NSArray*)executeQuery:(NSString*)sql{
    
    return [_database executeQuery:sql];

}
//执行查询
-(id)executeQuerySingle:(NSString*)sql{
   return [_database executeQuerySingle:sql];
}

-(SQLTransaction*)getTransaction{

    SQLTransaction* t=[[SQLTransaction alloc]initWithSQLDatabase:_database];
    
    return t;
    
}

//-(BOOL)beginTransaction{
//    
//    if(!_transaction||_transaction.status!=1){
//        SQLTransaction* t=[[SQLTransaction alloc]initWithSQLDatabase:_database];
//        _transaction=t;
//        return [t begin];
//    }
//
//    return YES;
//}
//-(BOOL)commitTransaction{
//    SQLTransaction* t=_transaction;
//    if(t){
//        return [t commit];
//    }
//    
//    return YES;
//
//}
//-(BOOL)rollbackTransaction{
//
//    SQLTransaction* t=_transaction;
//    if(t){
//        return [t rollback];
//    }
//    
//    return YES;
//}


-(void)close{

    if(!done){
        done=YES;
        [_database close];
    }

}

-(BOOL)isClose{

    return done;
}

-(void)dealloc{

    [self close];
    
}

@end
