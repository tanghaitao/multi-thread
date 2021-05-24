//
//  ViewController.m
//  001----多线程的作用
//
//  Created by Cooci on 2018/6/17.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // thread
    [NSThread detachNewThreadSelector:@selector(threadTest) toTarget:self withObject:nil];
    //GCD
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
    });
    //pthread  --> _t ref C 代码 标识
    pthread_t threadId = NULL;
    
    /**
     1: 线程ID
     2: 线程属性
     3: 函数回调 IMP
     4: 参数
     */
    char *str = "Cooci";
    //pthread_create(threadId, NULL, pthreadDemo, str);
    

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"123");
}

- (void)threadTest{
    // 多核 CPU
    NSLog(@"begin");
    // 现象: 堵塞 <-> 死锁 (A 等待 C  C 等待 A)
    NSInteger count = 1000 * 100;
    // nslog IO 性能优化 : debug KCLOG realese
    for (NSInteger i = 0; i < count; i++) {
        // 文字常量区: 未初始化的全局变量 静态变量
        // 五大区: 堆  栈 常量区  文字常量区 代码区
        // 代码区 : 二进制代码
        // 栈 : study函数 栈帧 局部变量 函数参数 出栈 入栈  pop push nav
        NSInteger num = i;
        // 常量区 --
        NSString *name = @"HelloCode";
        NSString *myName = [NSString stringWithFormat:@"%@ - %zd", name, num];
        NSLog(@"%@", myName);
    }
    NSLog(@"over");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
