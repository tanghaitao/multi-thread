//
//  ViewController.m
//  002---NSOperation深入浅出
//
//  Created by Cooci on 2018/7/4.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *pauseOrContinueBtn;
@property (nonatomic, strong) NSOperationQueue *queue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.queue = [[NSOperationQueue alloc] init];
    
//    [self demo1];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self demo2];
}


- (void)demo2{

    self.queue.maxConcurrentOperationCount = 2;
    NSBlockOperation *bo1 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:0.5];
        NSLog(@"请求token");
    }];

    NSBlockOperation *bo2 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.5];
        NSLog(@"拿着token,请求数据1");
    }];

    NSBlockOperation *bo3 = [NSBlockOperation blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:0.5];
        NSLog(@"拿着数据1,请求数据2");
    }];

    //依赖
    [bo2 addDependency:bo1];
    [bo3 addDependency:bo2];

    [self.queue addOperations:@[bo1,bo2,bo3] waitUntilFinished:NO];

    NSLog(@"执行完了?我要干其他事");
}

/**
 关于operationQueue的挂起,继续,取消
 */
- (void)demo1{
    
    // GCD ---> 信号量  :  对于线程操作更自如  -- suspend  cancel finish
    // 多线程世界
    self.queue.name = @"com.cooci.cn";
    self.queue.maxConcurrentOperationCount = 2;
    for (int i = 0; i<10; i++) {
        [self.queue addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:2];
            NSLog(@"%@--%d",[NSThread currentThread],i);
        }];
    }
    
}

- (IBAction)pauseOrContinue:(id)sender {
    
    // 下载任务 ---> task ---> 挂起
    // 继续 ---->
    // 打断  --->  后台
    
    self.queue.suspended = !self.queue.isSuspended;
    [self.pauseOrContinueBtn setTitle:self.queue.suspended?@"继续":@"暂停" forState:UIControlStateNormal];
    
    if (self.queue.operationCount == 0) {
        NSLog(@"没有操作执行");
        return;
    }
    
    if (self.queue.suspended) {
        NSLog(@"当前挂起来了");
    }else{
        NSLog(@"执行....");
    }
//    self.queue
    
    
}

- (IBAction)cancel:(id)sender {
    
    [self.queue cancelAllOperations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
