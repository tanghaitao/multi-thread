//
//  PortViewController.m
//  004---线程通讯
//
//  Created by Cooci on 2018/8/26.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "PortViewController.h"
#import <objc/runtime.h>
#import "KCPerson.h"

@interface PortViewController ()<NSMachPortDelegate>
@property (nonatomic, strong) NSPort *myPort;
@property (nonatomic, strong) KCPerson *person;

@end

@implementation PortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Port线程通讯";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.myPort = [NSMachPort port];
    
    self.myPort.delegate = self;
    
    [[NSRunLoop currentRunLoop] addPort:self.myPort forMode:NSDefaultRunLoopMode];

    self.person = [[KCPerson alloc] init];
    NSLog(@"PortViewController:sendPortMessage  == %@",[NSThread currentThread]);
    [NSThread detachNewThreadSelector:@selector(personLaunchThreadWithPort:) toTarget:self.person withObject:self.myPort];
    
}

#pragma mark - NSMachPortDelegate

- (void)handlePortMessage:(NSPortMessage *)message{
    //[message valueForKey:@""]; // runtime --- ivarlist pro
    NSLog(@"PortViewController:handlePortMessage  == %@",[NSThread currentThread]);
    NSLog(@"%@---",message);
    
    NSPort *port = [message valueForKey:@"remotePort"];
//    NSArray *components =  [message valueForKey:@"components"];
//    NSData *componentStr1 = (NSData *)(components.firstObject);
//    NSString *str1 = [[NSString alloc] initWithData:componentStr1 encoding:NSUTF8StringEncoding];
//    NSLog(@"str1 : %@",str1);
    
    [self getAllProperties:message];
    
    [[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
    
    [port sendBeforeDate:[NSDate date] msgid:10010 components:@[port].mutableCopy from:self.myPort reserved:0];

}









- (void)getAllProperties:(id)somebody{
    
    u_int count = 0;
    objc_property_t *properties = class_copyPropertyList([somebody class], &count);
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
         NSLog(@"%@",[NSString stringWithUTF8String:propertyName]);
    }
    
//        unsigned int count = 0;
//        Ivar* ivars = class_copyIvarList([message class], &count);
//        for (int i = 0; i < count; i++) {
//            Ivar var = ivars[i];
//            const char* name = ivar_getName(var);
//            NSString* key = [NSString stringWithUTF8String:name];
//            id value = [message valueForKey:key];
//            NSLog(@"key :%@, value :%@",key,value);
//        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
