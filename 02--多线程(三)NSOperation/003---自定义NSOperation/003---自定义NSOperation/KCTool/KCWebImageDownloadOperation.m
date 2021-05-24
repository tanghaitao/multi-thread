//
//  KCWebImageDownloadOperation.m
//  003---自定义NSOperation
//
//  Created by Cooci on 2018/7/7.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "KCWebImageDownloadOperation.h"
#import "NSString+KCAdd.h"

@interface KCWebImageDownloadOperation()
@property (nonatomic, readwrite, getter=isExecuting) BOOL executing;
@property (nonatomic, readwrite, getter=isFinished) BOOL finished;
@property (nonatomic, readwrite, getter=isCancelled) BOOL cancelled;
@property (nonatomic, readwrite, getter=isStarted) BOOL started;
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) KCCompleteHandle completeHandle;
@property (nonatomic, copy) NSString *title;

@end

@implementation KCWebImageDownloadOperation
// 因为父类的属性是Readonly的，重载时如果需要setter的话则需要手动合成。
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize cancelled = _cancelled;

- (instancetype)initWithDownloadImageUrl:(NSString *)urlString completeHandle:(KCCompleteHandle)completeHandle title:(NSString *)title{
    if (self = [super init]) {
        _urlString = urlString;
        _executing = NO;
        _finished  = NO;
        _cancelled = NO;
        _lock      = [NSRecursiveLock new];
        _completeHandle = completeHandle;
        _title = title;
    }
    return self;
}

- (void)start{

}

- (void)done{
    self.finished = YES;
    self.executing = NO;
}

/**
 取消操作的方法 --- 需要进行判断
 */
- (void)cancel{
    
 
}

#pragma mark - setter -- getter

- (BOOL)isExecuting {
    [_lock lock];
    BOOL executing = _executing;
    [_lock unlock];
    return executing;
}

- (void)setFinished:(BOOL)finished {
    [_lock lock];
    if (_finished != finished) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = finished;
        [self didChangeValueForKey:@"isFinished"];
    }
    [_lock unlock];
}

- (BOOL)isFinished {
    [_lock lock];
    BOOL finished = _finished;
    [_lock unlock];
    return finished;
}

- (void)setCancelled:(BOOL)cancelled {
    [_lock lock];
    if (_cancelled != cancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        _cancelled = cancelled;
        [self didChangeValueForKey:@"isCancelled"];
    }
    [_lock unlock];
}

- (BOOL)isCancelled {
    [_lock lock];
    BOOL cancelled = _cancelled;
    [_lock unlock];
    return cancelled;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isAsynchronous {
    return YES;
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:@"isExecuting"] ||
        [key isEqualToString:@"isFinished"] ||
        [key isEqualToString:@"isCancelled"]) {
        return NO;
    }
    return [super automaticallyNotifiesObserversForKey:key];
}



@end
