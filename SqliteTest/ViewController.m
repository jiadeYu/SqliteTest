//
//  ViewController.m
//  SqliteTest
//
//  Created by jiadeyu on 15/9/26.
//  Copyright (c) 2015年 jiadeyu. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>

#define TABLENAME   @"persion.sqlite"

@interface ViewController (){
    sqlite3 *db; //声明一个sqlite3数据库
}

@end

@implementation ViewController

- (void)timerTask{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:5];
    NSTimer* timer = [[NSTimer alloc] initWithFireDate:date interval:5 target:self selector:@selector(timerTask) userInfo:nil repeats:YES];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    [runLoop run];
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)!=SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"open database faid!");
        NSLog(@"数据库创建失败！");
    }
    
    NSString *ceateSQL = @"CREATE TABLE IF NOT EXISTS PERSIONINFO(ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, AGE INTEGER, SEX TEXT, WEIGHT INTEGER, ADDRESS TEXT)";
    
    char *ERROR;
    
    if (sqlite3_exec(database, [ceateSQL UTF8String], NULL, NULL, &ERROR)!=SQLITE_OK){
        sqlite3_close(database);
        NSAssert(0, @"ceate table faild!");
        NSLog(@"表创建失败");
    }
    
    char *update = "INSERT OR REPLACE INTO PERSIONINFO(NAME,AGE,SEX,WEIGHT,ADDRESS)""VALUES(?,?,?,?,?);";
    //上边的update也可以这样写：
    //NSString *insert = [NSString stringWithFormat:@"INSERT OR REPLACE INTO PERSIONINFO('%@','%@','%@','%@','%@')VALUES(?,?,?,?,?)",NAME,AGE,SEX,WEIGHT,ADDRESS];
    
    char *errorMsg = NULL;
    sqlite3_stmt *stmt;
    
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
        
        //【插入数据】在这里我们使用绑定数据的方法，参数一：sqlite3_stmt，参数二：插入列号，参数三：插入的数据，参数四：数据长度（-1代表全部），参数五：是否需要回调
        sqlite3_bind_text(stmt, 1, [@"yujiade" UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 2, [@"24" intValue]);
        sqlite3_bind_text(stmt, 3, [@"男" UTF8String], -1, NULL);
        sqlite3_bind_int(stmt, 4, [@"170" intValue]);
        sqlite3_bind_text(stmt, 5, [@"湖南岳阳" UTF8String], -1, NULL);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE){
        NSLog(@"数据更新失败");
        NSAssert(0, @"error updating :%s",errorMsg);
    }
    

    
    sqlite3_finalize(stmt);  
    sqlite3_close(database);
    [self findSqlInTab];
}

- (void)findSqlInTab{
    if (sqlite3_open([[self dataFilePath] UTF8String], &db)!=SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(0, @"open database faid!");
        NSLog(@"数据库创建失败！");
    }
    
    NSString *quary = @"SELECT * FROM PERSIONINFO";//SELECT ROW,FIELD_DATA FROM FIELDS ORDER BY ROW
    sqlite3_stmt *stmt;
    NSLog(@"%d",sqlite3_prepare_v2(db, [quary UTF8String], -1, &stmt, nil));
    if (sqlite3_prepare_v2(db, [quary UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            
            char *name = (char *)sqlite3_column_text(stmt, 1);
            NSString *nameString = [[NSString alloc] initWithUTF8String:name];
            
            char *sex = (char *)sqlite3_column_text(stmt, 3);
            NSString *sexString = [[NSString alloc] initWithUTF8String:sex];
            
            int weight = sqlite3_column_int(stmt, 4);
            
            
            
            char *address = (char *)sqlite3_column_text(stmt, 5);
            NSString *addressString = [[NSString alloc] initWithUTF8String:address];
        }
        
        sqlite3_finalize(stmt);  
    }  
    //用完了一定记得关闭，释放内存  
    sqlite3_close(db);
}

-(NSString *) dataFilePath{
    
    NSArray *path =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *document = [path objectAtIndex:0];
    
    return [document stringByAppendingPathComponent:TABLENAME];//'persion.sqlite'
    
}

////动态获取 对象的属性列表
//-(NSMutableDictionary *)attributeProrertyDic{
//    unsigned int count = 0;
//    Ivar *ivars = class_copyIvarList([self class], &count);
//    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    for (int i = 0; i<count; i++) {
//        
//        // 取出i位置对应的成员变量
//        Ivar ivar = ivars[i];
//        
//        // 查看成员变量
//        const char *name = ivar_getName(ivar);
//        // 归档
//        NSString *key = [NSString stringWithUTF8String:name];
//        id value = [self valueForKey:key];
//        if ([value isKindOfClass:[NSNull class]] || value == nil) {
//            value = @"";
//        }
//        [dic setObject:value forKey:key];
//    }
//    
//    free(ivars);
//    return dic;
//}

- (void)dealloc{

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
