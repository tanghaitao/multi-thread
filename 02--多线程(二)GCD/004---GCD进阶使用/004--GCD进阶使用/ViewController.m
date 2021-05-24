//
//  ViewController.m
//  004--GCD进阶使用
//
//  Created by Cooci on 2018/6/22.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"
#import "KC_ImageTool.h"
@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *mArray;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    UIImage *filterImage = [KC_ImageTool kc_filterImage:nil];
//    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[KC_ImageTool kc_WaterImageWithText:@"TZ_GCD多线程" backImage:filterImage]];
//    imageView1.frame = CGRectMake(20, 40, 300, 200);
//    [self.view addSubview:imageView1];
//
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 300, 300, 200)];
    self.imageView.image = [UIImage imageNamed:@"backImage"];
    [self.view addSubview:self.imageView];

    [self demo1];

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"start");

    NSLog(@"数组的个数:%zd",self.mArray.count);

}

//水印 栅栏函数影响
- (void)demo1{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("cooci", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(concurrentQueue, ^{
        NSString *logoStr = @"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3351002169,4211425181&fm=27&gp=0.jpg";
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:logoStr]];
        UIImage *image = [UIImage imageWithData:data];
        [self.mArray addObject:image];
    });
    
    dispatch_async(concurrentQueue, ^{
        NSString *logoStr = @"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3033952616,135704646&fm=27&gp=0.jpg";
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:logoStr]];
        UIImage *image = [UIImage imageWithData:data];
        [self.mArray addObject:image];
    });
    
    //加载完毕了 栅栏函数上
    UIImage *newImage = nil;
    
    for (int i = 0; i<self.mArray.count; i++) {
        UIImage *waterImage = self.mArray[i];
        newImage =[KC_ImageTool kc_WaterImageWithWaterImage:waterImage backImage:newImage waterImageRect:CGRectMake(20, 100*(i+1), 100, 40)];
    }
    
    

}

/**
 栅栏函数的演示说明:dispatch_barrier_sync/dispatch_barrier_async
 */
- (void)demo2{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("cooci", DISPATCH_QUEUE_CONCURRENT);
    /* 1.异步函数 */
    dispatch_async(concurrentQueue, ^{
        for (NSUInteger i = 0; i < 5; i++) {
            NSLog(@"download1-%zd-%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_async(concurrentQueue, ^{
        for (NSUInteger i = 0; i < 5; i++) {
            NSLog(@"download2-%zd-%@",i,[NSThread currentThread]);
        }
    });
    
    /* 2. 栅栏函数 */
    dispatch_barrier_sync(concurrentQueue, ^{
        NSLog(@"---------------------%@------------------------",[NSThread currentThread]);
    });
    NSLog(@"加载那么多,喘口气!!!");
    /* 3. 异步函数 */
    dispatch_async(concurrentQueue, ^{
        for (NSUInteger i = 0; i < 5; i++) {
            NSLog(@"日常处理3-%zd-%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"休尼MB,起来干!!");
    
    dispatch_async(concurrentQueue, ^{
        for (NSUInteger i = 0; i < 5; i++) {
            NSLog(@"日常处理4-%zd-%@",i,[NSThread currentThread]);
        }
    });
}

/**
 可变数组 线程不安全 解决办法
 */
- (void)demo3{
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("cooci", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(0, 0);

    dispatch_async(concurrentQueue, ^{
        for (int i = 0; i<10000; i++) {
            NSString *imageName = [NSString stringWithFormat:@"%d.jpg", (i % 10)];
            NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:nil];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:data];
            NSLog(@"%zd --- %@ ---- %d",self.mArray.count,[NSThread currentThread],i);
            [self.mArray addObject:image];

            if (i==1999) {
                NSLog(@"数组的个数:%zd",self.mArray.count);
            }
        }
    });
}


#pragma mark - 水印处理

- (void)demo{
    
    UIImage *filterImage = [KC_ImageTool kc_filterImage:nil];
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[KC_ImageTool kc_WaterImageWithText:@"TZ_GCD多线程" backImage:filterImage]];
    imageView1.frame = CGRectMake(20, 40, 300, 200);
    [self.view addSubview:imageView1];
    
    
    UIImage *logoImage = [UIImage imageNamed:@"tz_logo"];
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[KC_ImageTool kc_WaterImageWithWaterImage:logoImage backImage:nil waterImageRect:CGRectMake(20, 100, 100, 40)]];
    imageView2.frame = CGRectMake(20, 300, 300, 200);
    [self.view addSubview:imageView2];
    
    NSLog(@"end");
}

#pragma mark - lazy

- (NSMutableArray *)mArray{
    if (!_mArray) {
        _mArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _mArray;
}


@end
