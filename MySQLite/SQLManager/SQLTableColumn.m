//
//  SQLTableColumn.m
//  BOOK
//
//  Created by youbenwu on 16/9/2.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import "SQLTableColumn.h"

@implementation SQLTableColumn

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if(self){
        self.columnName=[aDecoder decodeObjectForKey:@"columnName"];
        self.datatype=[aDecoder decodeObjectForKey:@"datatype"];
        self.PK=[aDecoder decodeBoolForKey:@"PK"];
        self.AI=[aDecoder decodeBoolForKey:@"AI"];
        self.UQ=[aDecoder decodeBoolForKey:@"UQ"];
        self.NN=[aDecoder decodeBoolForKey:@"NN"];
    }
    return self;
}


-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.columnName forKey:@"columnName"];
    [aCoder encodeObject:self.datatype forKey:@"datatype"];
    [aCoder encodeBool:self.PK forKey:@"PK"];
    [aCoder encodeBool:self.AI forKey:@"AI"];
    [aCoder encodeBool:self.UQ forKey:@"UQ"];
    [aCoder encodeBool:self.NN forKey:@"NN"];
}

-(BOOL)isEqual:(id)object{

    SQLTableColumn* other=object;
    
    if([_columnName isEqual:other.columnName]&&[_datatype isEqual:other.datatype]&&_PK==other.PK&&_AI==other.AI&&_UQ==other.UQ&&_NN==other.NN)
        return YES;

    return [super isEqual:object];
}

@end
