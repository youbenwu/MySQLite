//
//  SQLTableColumn.h
//  BOOK
//
//  Created by youbenwu on 16/9/2.
//  Copyright © 2016年 youbenwu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLTableColumn : NSObject<NSCoding>

@property (nonatomic,strong) NSString* columnName;//列名
@property (nonatomic,strong) NSString* datatype;//列类型
@property (nonatomic) BOOL PK;//PrimaryKey
@property (nonatomic) BOOL NN;//NotNull
@property (nonatomic) BOOL UQ;//Unique
@property (nonatomic) BOOL BIN;//Binary
@property (nonatomic) BOOL UN;//Unsigned
@property (nonatomic) BOOL ZF;//ZeroFill
@property (nonatomic) BOOL AI;//AutoIncrement

@end
