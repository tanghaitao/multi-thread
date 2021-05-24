//
//  ViewController.m
//  002---NSthread线程操作
//
//  Created by Cooci on 2018/6/19.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()
@property (nonatomic, strong) Person *p;
@property (nonatomic, strong) NSThread *t;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.p = [[Person alloc] init];
    
    [self testThreadProperty];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (self.t == nil) {
        //A: 1:开辟线程
        NSThread *t = [[NSThread alloc] initWithTarget:self selector:@selector(testThreadStatus) object:nil];
        // 2. 启动线程
        [t start];
        t.name = @"学习线程";
        
    }else{
        [self.t cancel];
    }
}

/**
 线程属性演练方法
 */

- (void)testThreadProperty{
    
    NSLog(@"%zd --- %@",[NSThread currentThread].stackSize/1024,[NSThread currentThread]);

    //A: 1:开辟线程
    NSThread *t = [[NSThread alloc] initWithTarget:self selector:@selector(testThreadStatus) object:nil];
    // 2. 启动线程
    [t start];
    t.name = @"泡妞线程";
//    t.stackSize = 128*1024;//子线程512k的，主线程1m

}


/**
 线程状态演练方法
 */

- (void)testThreadStatus{
    
    NSLog(@"%zd --- %@",[NSThread currentThread].stackSize,[NSThread currentThread]);


    NSLog(@"来了");

    if (self.t == nil || self.t.isCancelled || self.t.isFinished | self.t.isExecuting) {
        //点击后把之前的线程cancel然后重新开辟线程执行任务。
        //A: 1:开辟线程
        NSThread *t = [[NSThread alloc] initWithTarget:self selector:@selector(testThreadStatus) object:nil];
        // 2. 启动线程
        [t start];
        t.name = @"泡妞线程";
    }else{
//
        // 进程 exit
        for (int i = 0; i<10; i++) {
            if (i == 2) {
                [NSThread sleepForTimeInterval:1];
            }
            NSLog(@"%@---%d",[NSThread currentThread] , i);
        }
        
        NSLog(@"完成");
        [self.t cancel];
        self.t = nil;
    }
    
 
    
}




/**
 线程创建的方式
 */
- (void)creatThreadMethod{
    
    NSLog(@"%@", [NSThread currentThread]);
    
    //A: 1:开辟线程
    NSThread *t = [[NSThread alloc] initWithTarget:self.p selector:@selector(study:) object:@100];
    // 2. 启动线程
    [t start];
    t.name = @"学习线程";
    
    //B detach 分离，不需要启动，直接分离出新的线程执行
    [NSThread detachNewThreadSelector:@selector(study:) toTarget:self.p withObject:@10000];
    
    //NSObject (NSThreadPerformAdditions)的分类
    //C : `隐式`的多线程调用方法，没有thread，也没有 start
    [self.p performSelectorInBackground:@selector(study:) withObject:@5000];
    
    NSLog(@"%@", [NSThread currentThread]);
}




@end
