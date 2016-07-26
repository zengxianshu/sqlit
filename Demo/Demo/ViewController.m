//
//  ViewController.m
//  sqlitDemo
//
//  Created by 曾墨 on 15/5/20.
//  Copyright (c) 2015年  All rights reserved.
//

#import "FMDatabase+Category.h"

#import "ViewController.h"

@interface ViewController ()
{
    FMDatabase *db;
  
  UITextView *textView;
}
@property (nonatomic , strong) NSArray  *btnTitleArray;
@property (nonatomic , strong) NSArray  *btnActionArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"第一步:实例化数据库");
  
    db = [FMDatabase databaseWithName:DATABASE];
    [self addSubview];
  
  textView.text = @"第一步:实例化数据库,\n点击建表";
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - fmdb

-(void)build
{
    NSLog(@"第二步:建表");
  textView.text = @"第二步:建表,\n点击查看结果,\n或者点击插入后点击查看结果";
    // 创建表格 INTEGER PRIMARY KEY AUTOINCREMENT 为自动增长整型
    NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' INTEGER, '%@' TEXT)",TABLENAME,ID,NAME,AGE,ADDRESS];
    [db createTablesSql:sqlCreateTable];
}

-(void)insertSql
{
#pragma mark 方式一
    NSString *insertSql1= [NSString stringWithFormat:
                           @"INSERT INTO '%@' ('%@', '%@', '%@') VALUES ('%@', '%@', '%@')",
                           TABLENAME, NAME, AGE, ADDRESS, @"张三", @"13", @"济南"];
   textView.text = ([db insertSql:insertSql1])? [NSString stringWithFormat: @"插入成功:%@\n",insertSql1] : [NSString stringWithFormat: @"插入失败:%@\n",insertSql1] ;
    
#pragma mark 方式二
    NSString *keys = [NSString stringWithFormat:@"'%@','%@','%@'",NAME, AGE, ADDRESS];
    NSString *values = [NSString stringWithFormat:@"'%@','%@','%@'",@"李四", @"19", @"北京"];
    insertSql1 = INSERTAQL(TABLENAME, keys, values);
  textView.text =  [textView.text stringByAppendingString:([db insertSql:insertSql1])?  [NSString stringWithFormat: @"插入成功:%@\n",insertSql1] : [NSString stringWithFormat: @"插入失败:%@\n",insertSql1]];
}

-(void)updateSql
{
    //修改数据：
#pragma mark 方式一
    NSString *updateSql = [NSString stringWithFormat:
                           @"update %@ set %@ = '%@' where %@ = '%@'",
                           TABLENAME,  AGE,  @18 ,NAME,  @"张三"];
#pragma mark 方式二
    updateSql = UPDATESQL(TABLENAME, AGE, @29, NAME, @"张三");
//    ([db updateSql:updateSql])? NSLog(@"更新成功%@",updateSql): NSLog(@"更新失败");
  textView.text = ([db updateSql:updateSql])?[NSString stringWithFormat: @"更新成功:%@",updateSql] : @"更新失败";
//#pragma mark 方式三
//    [db updateSqlFromTableName:TABLENAME setKey:AGE setValue:@"20" whereKey:NAME whereValue:@"张三"];
}


-(void)deleteSql_zangsan
{
//    ([db deleteSqlFromTableName:TABLENAME key:NAME value:@"张三"])? NSLog(@"删除成功"): NSLog(@"删除失败");
   textView.text = ([db deleteSqlFromTableName:TABLENAME key:NAME value:@"张三"])? @"删除张三成功\n" : @"删除张三失败\n" ;
}

-(void)deleteSql_lishi
{
  //    ([db deleteSqlFromTableName:TABLENAME key:NAME value:@"张三"])? NSLog(@"删除成功"): NSLog(@"删除失败");
  textView.text = ([db deleteSqlFromTableName:TABLENAME key:NAME value:@"李四"])? @"删除李四成功\n" : @"删除李四失败\n" ;
}


-(void)searchSql
{
    NSLog(@"查询");
  textView.text = @"查询";
#pragma mark 方式一
//    NSString * sql = [NSString stringWithFormat:@"select * from %@",TABLENAME];
//    
//    FMResultSet *set = [db searchSql:sql];
//    
//    while ([set next]) {
//        int Id = [set intForColumn:ID];
//        NSString * name = [set stringForColumn:NAME];
//        NSString * age = [set stringForColumn:AGE];
//        NSString * address = [set stringForColumn:ADDRESS];
//        NSLog(@"id = %d, name = %@, age = %@  address = %@", Id, name, age, address);
//    }
//    [db close]
#pragma mark 方式二
    NSString * sql1 = SEARCHSQL(TABLENAME);
#pragma mark 条件查询
//    sql1 = SEARCHSQL_KV(TABLENAME, ID, @"13");
  textView.text = @"结果:\n";
    [db searchSql:sql1 queryResBlock:^(FMResultSet *set) {
        while ([set next]) {
            int Id = [set intForColumn:ID];
            NSString * name = [set stringForColumn:NAME];
            NSString * age = [set stringForColumn:AGE];
            NSString * address = [set stringForColumn:ADDRESS];
            NSLog(@"id = %d, name = %@, age = %@  address = %@", Id, name, age, address);
          textView.text = [textView.text stringByAppendingString:[NSString stringWithFormat:@"id = %d, name = %@, age = %@  address = %@\n", Id, name, age, address]];
        }
    }];
}

#pragma mark - 构建子界面
-(void)addSubview
{
  CGFloat boundsWidth = [[UIScreen mainScreen]bounds].size.width;
  CGFloat boundsHeight = [[UIScreen mainScreen]bounds].size.height;
  
    for (int i = 0; i < self.btnTitleArray.count ; i++) {
        UIButton *btn = [[UIButton alloc]init];
        btn.backgroundColor = [UIColor redColor];
        btn.frame = CGRectMake(0, 40*(i+1), boundsWidth, 30);
        [btn setTitle:self.btnTitleArray[i] forState:UIControlStateNormal];
        [btn addTarget:self action:NSSelectorFromString(self.btnActionArray[i]) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }

  CGFloat originalY = 40* (self.btnTitleArray.count + 1);
  textView = [[UITextView alloc] initWithFrame:CGRectMake(0, originalY, boundsWidth, boundsHeight-originalY)];
  textView.editable = NO;
  [self.view addSubview:textView];
}

#pragma mark - getter
-(NSArray *)btnTitleArray
{
    if (_btnTitleArray == nil) {
        _btnTitleArray = @[@"建表",@"插入",@"修改",@"删除张三",@"删除李四",@"⬇️查看结果⬇️"];
        _btnActionArray = @[@"build",@"insertSql",@"updateSql",@"deleteSql_zangsan",@"deleteSql_lishi",@"searchSql"];
    }
    return _btnTitleArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
