//
//  ViewController.m
//  003---资源共享
//
//  Created by Cooci on 2018/6/19.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, assign) NSInteger tickets;
// atomic 只有一条线程可以读写
// nonatomic 性能强
@property (nonatomic, strong) NSMutableArray *mArray;
@property (nonatomic, copy)   NSString *name;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.tickets = 20;

    // 1. 开启一条售票线程
    NSThread *t1 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTickets) object:nil];
    t1.name = @"售票 A";
    [t1 start];
    
    // 2. 再开启一条售票线程
    NSThread *t2 = [[NSThread alloc] initWithTarget:self selector:@selector(saleTickets) object:nil];
    t2.name = @"售票 B";
    [t2 start];

}

// 售票接口
- (void)saleTickets {
    while (true) {
        // 0 .模拟延迟
        
//        NSObject *object = [[NSObject alloc] init];
//        object 是自己的临时对象，对其他访问该区域的无影响
//        可以锁self 那么访问该方法的时候所有的都锁住，可以根据需求特定锁
        
         // 不加这个，可能 [NSThread sleepForTimeInterval:1];间隔内有2个人都买了票，
        // self.tickets--操作，然后self.mArray添加的数据是一样的
        
        @synchronized (@(self.tickets)) {
            [NSThread sleepForTimeInterval:1];
            
            // 1. 判断是否还有票
            if (self.tickets > 0) {
                // 2. 如果还有票，卖一张，提示用户
                self.tickets--;
                NSLog(@"剩余票数 %zd %@",self.tickets,[NSThread currentThread]);
            }else{
                // 3. 如果没票，退出循环
                NSLog(@"没票了，来晚了 %@",[NSThread currentThread]);
                break;;
            }
            
            //在锁里面操作其他的变量的影响
            
            [self.mArray addObject:[NSDate date]];
            
            NSLog(@"%@ *** %@",[NSThread currentThread],self.mArray);
        }
    }
  
}


#pragma mark - lazy

- (NSMutableArray *)mArray{
    if (!_mArray) {
        _mArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _mArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
