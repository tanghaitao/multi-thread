//
//  KCViewModel.h
//  003---自定义NSOperation
//
//  Created by Cooci on 2018/7/6.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCModel.h"
typedef void(^SuccessBlock)(id data);
typedef void(^FailBlock)(id data);

@interface KCViewModel : NSObject
@property (nonatomic, copy) SuccessBlock successBlock;
@property (nonatomic, copy) FailBlock failBlock;
//initwith是主线程分配内存，最好不要做load处理，延迟加载
- (instancetype)initWithBlock:(SuccessBlock)successBlock fail:(FailBlock)failBlock;
@end
