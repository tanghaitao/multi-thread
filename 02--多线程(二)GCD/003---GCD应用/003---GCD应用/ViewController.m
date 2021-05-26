//
//  ViewController.m
//  003---GCD应用
//
//  Created by Cooci on 2018/6/21.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) id headData;
@property (nonatomic, strong) id listData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    __weak typeof(self) weakSelf = self;
    
//    [self requestToken:^(id value) {
//        weakSelf.token = value;
//
//        [weakSelf requestHeadDataWithToken:value handle:^(id value) {
//            NSLog(@"%@",value);
//            weakSelf.headData = value;
//        }];
//
//        [weakSelf requestListDataWithToken:value handle:^(id value) {
//            NSLog(@"%@",value);
//            weakSelf.listData = value;
//        }];
//    }];
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
   
//    dispatch_sync(queue, ^{
//        [self requestToken:^(id value) {
//            weakSelf.token = value;
//        }];
//    });
//
//    dispatch_async(queue, ^{
//        [weakSelf requestHeadDataWithToken:self.token handle:^(id value) {
//            NSLog(@"%@",value);
//            weakSelf.headData = value;
//        }];
//    });
//
//    dispatch_async(queue, ^{
//        [weakSelf requestListDataWithToken:self.token handle:^(id value) {
//            NSLog(@"%@",value);
//            weakSelf.listData = value;
//        }];
//    });
    
    dispatch_block_t task = ^{
        //堵塞等待，体验差
        dispatch_sync(queue, ^{
            [self requestToken:^(id value) {
                weakSelf.token = value;
            }];
        });
        //异步，不知道什么时候调用完成，想异步回调后执行其他任务.
        dispatch_async(queue, ^{
            [weakSelf requestHeadDataWithToken:self.token handle:^(id value) {
                NSLog(@"%@",value);
                weakSelf.headData = value;
            }];
        });
        
        dispatch_async(queue, ^{
            [weakSelf requestListDataWithToken:self.token handle:^(id value) {
                NSLog(@"%@",value);
                weakSelf.listData = value;
            }];
        });
    };
    
    dispatch_async(queue, task);
    
 
    NSLog(@"请求完毕了?我要去其他事情了");
}

/**
 token请求

 @param successBlock 请求回来的token保存 通常还有时效性
 */
- (void)requestToken:(void(^)(id value))successBlock{
    NSLog(@"开始请求token");
    [NSThread sleepForTimeInterval:1];
    successBlock(@"b2a8f8523ab41f8b4b9b2a79ff47c3f1");
}

/**
 头部数据的请求

 @param token token
 @param successBlock 成功数据回调
 */
- (void)requestHeadDataWithToken:(NSString *)token handle:(void(^)(id value))successBlock{
    if (token.length == 0) {
        NSLog(@"没有token,因为安全性无法请求数据");
        return;
    }
    [NSThread sleepForTimeInterval:1];
    successBlock(@"我是头,都听我的");
}
/**
 列表数据的请求
 
 @param token token
 @param successBlock 成功数据回调 --> 刷新列表
 */
- (void)requestListDataWithToken:(NSString *)token handle:(void(^)(id value))successBlock{
    if (token.length == 0) {
        NSLog(@"没有token,因为安全性无法请求数据");
        return;
    }
    [NSThread sleepForTimeInterval:1];
    successBlock(@"我是列表数据");
}


- (void)dealloc{
    NSLog(@"我走了");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
