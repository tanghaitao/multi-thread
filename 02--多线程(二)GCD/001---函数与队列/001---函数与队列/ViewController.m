//
//  ViewController.m
//  001---函数与队列
//
//  Created by Cooci on 2018/6/21.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self textDemo2];
//    [self globalAsyncTest];

    __block int a = 0;
//    dispatch_group_t t = dispatch_get_main_queue();
    // dispatch_get_global_queue : 并发队列
//    while (a<1) { // 耗时足够长  ---  开辟线程能够调度回来  a++  线程不安全
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            a++;
//            NSLog(@"%@===%d",[NSThread currentThread],a);
//        });
//    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        while (a<5) {//声明在里面才正常
            NSLog(@"%@===%d",[NSThread currentThread],a);
            a++;
        }
    });
//
    
    NSLog(@"%@****%d",[NSThread currentThread],a);
//
////    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
////
////        NSLog(@"%@--------%d",[NSThread currentThread],a);
////
////    });
//
    // a > 5
    // a = 5
    // a < 5

}

/**
 主队列同步
 不会开线程
 */
- (void)mainSyncTest{
    
    // 主队列 存在任务就会执行到底
    // dispatch_get_main_queue() -->
    NSLog(@"0");
    // 等
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"1");
    });
    NSLog(@"2");
}
/**
 主队列异步
 不会开线程 顺序
 */
- (void)mainAsyncTest{
    NSLog(@"0");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"1");
    });
    NSLog(@"2");
    
    // 0 2 1
}


/**
 全局异步
 全局队列:一个并发队列
 */
- (void)globalAsyncTest{
    for (int i = 0; i<20; i++) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"%d-%@",i,[NSThread currentThread]);
        });
    }
    
    for (int i = 0; i<1000000; i++) {
    }
    NSLog(@"hello queue");
}

/**
 全局同步
 全局队列:一个并发队列
 */
- (void)globalSyncTest{
    for (int i = 0; i<20; i++) {
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"%d-%@",i,[NSThread currentThread]);
        });
    }
    
    for (int i = 0; i<1000000; i++) {
    }
    NSLog(@"hello queue");
}

#pragma mark - 队列函数的应用

/**
 函数 队列  ---> 死锁  线程 执行顺序
 主队列(serial)  全局队列 (concurrent)
 */

- (void)textDemo2{
    
    // 同步队列
    dispatch_queue_t queue = dispatch_queue_create("cooci", DISPATCH_QUEUE_SERIAL);
    NSLog(@"1");
    // 异步函数
    dispatch_async(queue, ^{
        NSLog(@"2");
        
        // 同步
        dispatch_sync(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
    
    // 1 5 2
    
}

- (void)textDemo1{
    
    dispatch_queue_t queue = dispatch_queue_create("cooci", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"1");
    dispatch_async(queue, ^{
        NSLog(@"2");
        dispatch_sync(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
    
    // 1 5 2 3 4
}

- (void)textDemo{
    
    dispatch_queue_t queue = dispatch_queue_create("haitao", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"1");
    dispatch_async(queue, ^{
        NSLog(@"2");
        dispatch_async(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
    
    //  1 5 2 4 3
}

/**
 同步并发 : 堵塞 同步锁  队列 : resume supend   线程 操作, 队列挂起 任务能否执行
 */
- (void)concurrentSyncTest{

    //1:创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("Cooci", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i<20; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%d-%@",i,[NSThread currentThread]);
        });
    }
    
    for (int i = 0; i<1000000; i++) {
 
    }
    NSLog(@"hello queue");
}


/**
 异步并发: 有了异步函数不一定开辟线程,要异步并发才会，异步串行，错的，同一个任务中使用一个新开辟的线程name = (null)
 */
- (void)concurrentAsyncTest{
    
    //1:创建并发队列
    dispatch_queue_t queue = dispatch_queue_create("Cooci", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i<20; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%d-%@",i,[NSThread currentThread]);
//            0-<NSThread: 0x600003dc5dc0>{number = 6, name = (null)}
//            1-<NSThread: 0x600003dc1000>{number = 5, name = (null)}
//            5-<NSThread: 0x600003d98700>{number = 4, name = (null)}
//            2-<NSThread: 0x600003d9cbc0>{number = 3, name = (null)}
        });
    }
    
//    for (int i = 0; i<1000000; i++) {
//
//    }
    
    NSLog(@"hello queue");
    
}


/**
 串行异步队列

 */
- (void)serialAsyncTest{
    //1:创建串行队列
    NSLog(@" %@",[NSThread currentThread]);//<NSThread: 0x6000024d41c0>{number = 1, name = main}
    dispatch_queue_t queue = dispatch_queue_create("Cooci", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i<20; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%d-%@",i,[NSThread currentThread]);//{number = 6, name = (null)}
        });
    }
    
    for (int i = 0; i<1000000; i++) {

    }
    
    NSLog(@"hello queue");
    
}

/**
 串行同步队列 : FIFO: 先进先出
 */
- (void)serialSyncTest{
    //1:创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("Cooci", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i<20; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%d-%@",i,[NSThread currentThread]);//1-<NSThread: 0x6000001e4900>{number = 1, name = main}
        });
    }

}


/**
 * 还原最基础的写法,很重要
 */

- (void)syncTest{
    
    //1:创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("Cooci", DISPATCH_QUEUE_SERIAL);
    //下面的方式也可以,但是用得少, DISPATCH_QUEUE_SERIAL 更加易懂
    //dispatch_queue_t queue = dispatch_queue_create("Cooci", NULL);
    
    //2:创建任务
    dispatch_block_t taskBlock = ^{
        NSLog(@"%@",[NSThread currentThread]);
    };
    //3:利用函数把任务放入队列
    dispatch_sync(queue, taskBlock);
    
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    

//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//        NSLog(@"%@",[NSThread currentThread]);
//    });
}


@end
