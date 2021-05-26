//
//  ViewController.m
//  001---NSOperation初体验
//
//  Created by cooci on 2018/10/13.
//  Copyright © 2018 cooci. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self demo2];
}

- (void)demo2{
       
    // 操作优先级
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
       
        NSLog(@"NSThread == %@",[NSThread currentThread]);
        // 并发
        [NSThread sleepForTimeInterval:1];
        NSLog(@"123");
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:2];
            NSLog(@"更新UI");
        }];
        
    }];
    
    // CPU 调度的评率高
//    op.qualityOfService =
    
    [op addExecutionBlock:^{
        [NSThread sleepForTimeInterval:2];
        NSLog(@"456");
    }];
    
    op.completionBlock = ^{
        NSLog(@"完成");
    };
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 由系统调控
    [queue addOperation:op];
    
    // NSThread == <NSThread: 0x60000018c640>{number = 6, name = (null)}
    // 123
    // 456
    // 完成
    // 更新UI
    
}

- (void)demo1{
    
    // 不能直接用 --- 事务 () + queue = 把事务添加到队列 ---> 然后去执行
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(xixihha) object:nil];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 由系统调控
    [queue addOperation:op];
    
    // 手动吊起
    [op start];
    
}

// 操作
- (void)xixihha{
    NSLog(@"123");
}


@end
