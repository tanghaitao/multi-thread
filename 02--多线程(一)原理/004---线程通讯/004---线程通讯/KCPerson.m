//
//  KCPerson.m
//  004---线程通讯
//
//  Created by Cooci on 2018/8/26.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "KCPerson.h"

@interface KCPerson()<NSMachPortDelegate>
@property (nonatomic, strong) NSPort *vcPort;
@property (nonatomic, strong) NSPort *myPort;
@end

@implementation KCPerson


- (void)personLaunchThreadWithPort:(NSPort *)port{
    
    NSLog(@"VC 响应了Person里面");
    
    @autoreleasepool {
        
        self.vcPort = port;
        
        [[NSRunLoop currentRunLoop] run];//子线程runloop默认不开启，需要手动开启
        
        self.myPort = [NSMachPort port];
        
        self.myPort.delegate = self;
        
        [[NSRunLoop currentRunLoop] addPort:self.myPort forMode:NSDefaultRunLoopMode];
        
        [self sendPortMessage];
    }
    
   
}


/**
 *   完成向主线程发送port消息
 */

- (void)sendPortMessage {
    
    NSData *data = [@"玫瑰小镇" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data2 = [@"玫瑰小镇11" dataUsingEncoding:NSUTF8StringEncoding];

 
    [self.vcPort sendBeforeDate:[NSDate date] msgid:10086 components:@[data,data2].mutableCopy from:self.myPort reserved:0];
    
}





#pragma mark - NSMachPortDelegate

- (void)handlePortMessage:(NSPortMessage *)message{
    
    NSLog(@"person:handlePortMessage  == %@",[NSThread currentThread]);


    NSLog(@"从VC 传过来一些信息:");
    NSLog(@"components == %@",[message valueForKey:@"components"]);
    NSLog(@"receivePort == %@",[message valueForKey:@"receivePort"]);
    NSLog(@"sendPort == %@",[message valueForKey:@"sendPort"]);
    NSLog(@"msgid == %@",[message valueForKey:@"msgid"]);
}


@end
