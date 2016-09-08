//
//  SQLQuery.h
//  BOOK
//
//  Created by youbenwu on 16/8/29.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SQLDatabase.h"
#import "SQLEntity.h"

@class SQLDatabase,SQLEntity;
@interface SQLQuery : NSObject

-(instancetype)initWithDatabase:(SQLDatabase *)db sql:(NSString*)sql SQLEntity:(SQLEntity*)en;

-(SQLQuery*)setParameter:(id)value forName:(NSString*)name;
-(SQLQuery*)setParameter:(id)value forIndex:(int)index;
-(SQLQuery*)setObjectParameter:(id)value forIndex:(int)index;
-(SQLQuery*)setImageParameter:(UIImage*)value forIndex:(int)index;
-(SQLQuery*)setClassParameter:(Class)value forIndex:(int)index;
-(SQLQuery*)setNumberParameter:(NSNumber*)value forIndex:(int)index;
-(SQLQuery*)setStringParameter:(NSString*)value forIndex:(int)index;
-(SQLQuery*)setIntegerParameter:(NSInteger)value forIndex:(int)index;
-(SQLQuery*)setIntParameter:(int)value forIndex:(int)index;
-(SQLQuery*)setBoolParameter:(BOOL)value forIndex:(int)index;
-(SQLQuery*)setFloatParameter:(float)value forIndex:(int)index;
-(SQLQuery*)setDoubleParameter:(double)value forIndex:(int)index;
-(SQLQuery*)setDataParameter:(NSData*)value forIndex:(int)index;
-(SQLQuery*)setDateParameter:(NSDate*)value forIndex:(int)index;

-(SQLQuery*)setFirstResults:(int)first;
-(SQLQuery*)setMaxResults:(int)max;

-(BOOL)reset;

-(NSInteger)count;
-(id)uniqueResult;
-(NSArray*)listResult;
-(BOOL)executeUpdate;


@end
