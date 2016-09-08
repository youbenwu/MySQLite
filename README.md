# MySQLite


# 简介：
     简单易用的sqlite3数据库封装框架。
     封装了大量的接口，可以在不使用或使用很少ＳＱＬ语句的情况下就能操作数据库数据。


# 特性：
     1、支持自动建立从实体类到数据库表之间的映射。使用时无需了解数据库表的建立过程。
     2、支持实体类的增删改查，无需使用ＳＱＬ语句。
     3、支持SQLite原生ＳＱＬ语句。
     4、支持事务。

# 注意：
     1､多线程，目前还没有考虑多线程的情况，请在单线程中使用。
     2､对于多表关联查询等复杂使用情况，请使用原生ＳＱＬ，本框架并不是万能。
     3､本框架是本人花了一个星期时间写出来，还没有经过严格测试验证，请慎用。


# 举例：
`````
   //假设有实体类 User
   @interface User : NSObject`
   @property (nonatomic,strong) NSNumber *userId;
   @property (nonatomic,strong) NSString *username;
   @property (nonatomic,strong) NSString *phone;
   @property (nonatomic,strong) NSDate *time;
   @end
`````
   1､先要注册要持久化的实体类型。只需要注册一次。
`````
    //注册实体类型，传入作为数据库ＩＤ的字段名称和是否自动递增ＩＤ值。autoIncrement如果为ＹＥＳ，则ＩＤ字段必需为整数类型。
    [[SQLManager manager]registerEntityType:[User class] primaryKey:@"userId" autoIncrement:YES];
`````
   2､插入一条数据
    如增加一条User记录
`````
   [[SQLManager manager] insert:user];
`````
   2､删除数据
    如删除一条User记录
`````
    [[SQLManager manager] remove:user.userId];
`````
    删除所有User记录
`````
    [[SQLManager manager] removeALL:[User class]];
`````  
    3､修改数据
    如修改一条User记录
`````
    [[SQLManager manager] update:user];
`````

     3､查找数据
    根据ＩＤ查找
`````
    User* user= [[SQLManager manager] select:userId entityType:[User class]];
`````
    查找列表
    
    反回User列表
`````
    NSArray* _list=[[[SQLManager manager] createSQLQueryWithEntityType:[User class]] listResult];
`````
    按时间倒序 通过设置参数orderBy
`````
   NSArray* _list=[[[SQLManager manager] createSQLQueryWithEntityType:[User class] where:nil orderBy:@"time desc"] listResult];
`````
   分页 通过设置setFirstResults setMaxResults
`````
  NSArray* _list=[[[[[SQLManager manager] createSQLQueryWithEntityType:[User class] where:nil orderBy:@"time desc"] setFirstResults:0] setMaxResults:10] listResult];
`````
 条件查找 设置参数where
`````
 NSArray* _list=[[[[[SQLManager manager] createSQLQueryWithEntityType:[User class] where:@"phone=1234556" orderBy:@"time desc"] setFirstResults:0] setMaxResults:10] listResult];
`````

 查找单个数据
`````
 User* user=[[[[[SQLManager manager] createSQLQueryWithEntityType:[User class] where:@"phone=1234556" orderBy:nil]uniqueResult];
`````

