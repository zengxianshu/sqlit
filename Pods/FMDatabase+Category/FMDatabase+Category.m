//
//  FMDatabase+Category.m
//  sqlitDemo
//
//  Created by 曾墨 on 15/7/10.
//  Copyright (c) 2015年 All rights reserved.
//

#import "FMDatabase+Category.h"

@implementation FMDatabase (Category)

// 获取数据库实例
+(FMDatabase *)databaseWithName:(NSString *)squliteName
{
    //获得沙盒中的数据库文件名(路径)
    NSString *filenamePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:squliteName];
    
    NSLog(@"路径 - > %@",filenamePath);
    
    // 获取数据库实例
    return [FMDatabase databaseWithPath:filenamePath];
}

// 没有的话会创建数据表
-(BOOL)createTablesSql:(NSString *)sqlCreateTable
{
    //    NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' INTEGER, '%@' TEXT)",TABLENAME,ID,NAME,AGE,ADDRESS];
    
    return [self dbToDoWork:^BOOL{
        
        return [self executeUpdate:sqlCreateTable];
    }];
}

// 插入数据库
-(BOOL)insertSql:(NSString *)insertSql
{
    //    NSString *insertSql1= [NSString stringWithFormat: @"INSERT INTO '%@' ('%@', '%@', '%@') VALUES ('%@', '%@', '%@')",TABLENAME, NAME, AGE, ADDRESS, @"张三", @"13", @"济南"];
    
    return [self dbToDoWork:^BOOL{
        
        return [self executeUpdate:insertSql];
    }];
}
// 插入数据
-(BOOL)insertSqlFromTableName:(NSString *)tableName keys:(NSString*)keys values:(NSString*)values
{
    return [self insertSql:INSERTAQL(tableName, keys, values)];
}

// 更改
-(BOOL)updateSql:(NSString *)updateSql
{
    //修改数据：[db executeUpdate:@"update t_student set age = ? where name = ?;", @20, @"jack"]
    
    return [self dbToDoWork:^BOOL{
        
        return [self executeUpdate:updateSql];
    }];
}
// 更改
-(BOOL)updateSqlFromTableName:(NSString *)tableName setKey:(NSString *)setKey setValue:(NSString *)setValue whereKey:(NSString *)whereKey whereValue:(NSString *)whereValue
{
    NSInteger rowCount = [self searchRowCountSql:SEARCHSQL_COUNT_KV(tableName,whereKey,whereValue)];
    
    if (rowCount) { // 存在数据则更新
        
        return [self updateSql:UPDATESQL(tableName, setKey, setValue, whereKey, whereValue)];
        
    } else {    // 不存在数据则插入
        
        if ( setKey != whereKey ) {
            
            return [self insertSqlFromTableName:tableName keys:[NSString stringWithFormat:@"'%@','%@'",whereKey, setKey] values:[NSString stringWithFormat:@"'%@','%@'",whereValue, setValue]];
        }else{
            
            return [self insertSqlFromTableName:tableName keys:[NSString stringWithFormat:@"'%@'", setKey] values:[NSString stringWithFormat:@"'%@'",setValue]];
        }
    }
}

// 删除
-(BOOL)deleteSql:(NSString *)deleteSql
{
    //    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",TABLENAME, NAME, @"张三"];
    
    return [self dbToDoWork:^BOOL{
        
        return [self executeUpdate:deleteSql];
    }];
}
// 删除
-(BOOL)deleteSqlFromTableName:(NSString *)tableName key:(NSString *)key value:(NSString *)value
{
    NSString *deleteSql = DELEATESQL(tableName, key, value);
    
    return [self deleteSql:deleteSql];
}

// 查询 操作完成后得关闭数据库 //!!!: 待改进
-(FMResultSet *)searchSql:(NSString*)sql
{
    //NSString * sql1 = [NSString stringWithFormat:@"select * from %@ where %@",TABLENAME,KEY_VALUE(IMID, chatter)];
    
    [self open];
    
    return [self executeQuery:sql] ;
}

/*!
 @brief  查询
 
 e.g.[db searchSql:sql1 queryResBlock:^(FMResultSet *set) {
 while ([set next]) {
 NSString * name = [set stringForColumn:NAME];
 }}];
 
 */
-(void)searchSql:(NSString *)sql queryResBlock:(void(^)(FMResultSet *set))queryResBlock
{
    [self dbToDoWork:^BOOL{
        
        queryResBlock([self executeQuery:sql]);
        
        return YES;
    }];
}

/**
 *  查询符合条件的数据有多少行
 *
 *  @param sql      SEARCHSQL_COUNT_KV(tableName,whereKey,whereValue)
 *
 *  @return 行数
 */
-(NSInteger)searchRowCountSql:(NSString *)sql
{
    FMResultSet *set = [self searchSql:sql];
    
    int rowCount = 0;
    
    while ([set next]){
        
        rowCount =[set intForColumn:@"rowCount"];
    }
    
    if (![self close]){ [self close]; }
    
    return rowCount;
}

// 删除表格
- (BOOL) deleteTable:(NSString *)tableName
{
    return [self dbToDoWork:^BOOL{
        
        return [self executeUpdate:@"DROP TABLE ?", tableName];
    }];
}

// 清空表 清除所有数据
- (BOOL) eraseTable:(NSString *)tableName
{
    return [self dbToDoWork:^BOOL{
        
        return [self executeUpdate:@"DELETE FROM ?", tableName];
    }];
}

// 清除表中所有符合条件的数据
- (BOOL) eraseTable:(NSString *)tableName where:(NSString*)where
{
    //where = KEY_VALUE(key, value)
    
    return [self dbToDoWork:^BOOL{
        
        return [self executeUpdate:@"DELETE FROM ? WHERE ?", tableName,where];
    }];
}

// 打开数据库 -> 执行操作 -> 关闭数据库 返回操作结果(BOOL)
- (BOOL) dbToDoWork:(BOOL (^)())toDoBlock
{
    if (![self open]){  [self open];  }
    
    BOOL flag = toDoBlock();
    
    if (![self close]){ [self close]; }
    
    return flag;
}
@end
