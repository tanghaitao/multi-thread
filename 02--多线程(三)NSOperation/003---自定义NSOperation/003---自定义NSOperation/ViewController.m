//
//  ViewController.m
//  003---自定义NSOperation
//
//  Created by Cooci on 2018/7/6.
//  Copyright © 2018年 Cooci. All rights reserved.
//

#import "ViewController.h"
#import "KCCollectionViewCell.h"
#import "NSString+KCAdd.h"
#import "KCViewModel.h"
#import "KCWebImageManager.h"
#import <UIImageView+WebCache.h>
#import "UIImageView+KCWebCache.h"

#define KCScreenW [UIScreen mainScreen].bounds.size.width
#define KCScreenH [UIScreen mainScreen].bounds.size.height

static NSString *reuseID = @"reuseID";


@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView      *collectionView;
@property (nonatomic, strong) NSMutableArray        *dataArray;
@property (nonatomic, strong) KCViewModel           *viewModel;
//下载队列
@property (nonatomic, strong) NSOperationQueue      *queue;
//缓存图片字典----可用数据库替换
@property (nonatomic, strong) NSMutableDictionary   *imageCacheDict;
//缓存操作字典
@property (nonatomic, strong) NSMutableDictionary   *operationDict;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"清除缓存" style:(UIBarButtonItemStyleDone) target:self action:@selector(deleteCacheData)];
    
    self.queue = [[NSOperationQueue alloc] init];
    //添加到视图
    [self.view addSubview:self.collectionView];
    __weak typeof(self) weakSelf = self;
    self.viewModel = [[KCViewModel alloc] initWithBlock:^(id data) {
        [weakSelf.dataArray addObjectsFromArray:data];
        [weakSelf.collectionView reloadData];
    } fail:nil];

}

#pragma mark - 清除缓存

- (void)deleteCacheData{
    // 清空缓存
    [self.imageCacheDict removeAllObjects];
    // 清空沙盒
    NSFileManager *fieldManager=[NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    if ([fieldManager fileExistsAtPath:cachePath]) {
        BOOL isDel = [fieldManager removeItemAtPath:cachePath error:nil];
        if (isDel) {
            NSLog(@"删除沙盒数据成功");
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KCCollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    KCModel *model        = self.dataArray[indexPath.row];
    cell.moneyLabel.text  = model.money;
    cell.titleLabel.text  = model.title;
    
    
    // 内存 , 磁盘  首先加载内存 (快)  ---> 磁盘 (保存一份到内存) ---> 下载 保存内存和磁盘
    // 从内存加载数据
    UIImage *cacheImage = self.imageCacheDict[model.imageUrl];
    if (cacheImage) {
        NSLog(@"从内存加载数据");
        cell.imageView.image  = cacheImage;
        return cell;
    }

    // 磁盘加载
    cacheImage = [UIImage imageWithContentsOfFile:[model.imageUrl getDowloadImagePath]];
    if (cacheImage) {
        NSLog(@"从磁盘加载数据");
        cell.imageView.image  = cacheImage;
        //磁盘找到后保存到内存，方便下次直接从内存中读取
        [self.imageCacheDict setObject:cacheImage forKey:model.imageUrl];
        return cell;
    }

//    // 从模型加载数据
//    if (model.image) {
//        NSLog(@"从模型加载数据");
//        cell.imageView.image  = model.image;
//        return cell;
//    }
    
    if (self.operationDict[model.imageUrl]) {
        NSLog(@"兄弟,稍微一等< %@已经提交下载了",model.title);
        return cell;
    }
    
    // 图片地址 -- SD AF
    NSBlockOperation *op  = [NSBlockOperation blockOperationWithBlock:^{
        // 重复下载
        NSLog(@"下载图片: %@",model.title);
        NSURL   *url    = [NSURL URLWithString:model.imageUrl];
        NSData  *data   = [NSData dataWithContentsOfURL:url];
        UIImage *image  = [UIImage imageWithData:data];//data为nil不会奔溃
       
        if (data && image) {
            // 保存内存
            [self.imageCacheDict setObject:image forKey:model.imageUrl];
            // 保存磁盘
            [data writeToFile:[model.imageUrl getDowloadImagePath] atomically:YES];
             // 下载完成操作 从记录清除
            [self.operationDict removeObjectForKey:model.imageUrl];
            // 更新UI
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                cell.imageView.image  = image;
                model.image           = image;
            }];
        }
    }];
    
    // 将下载事务添加到队列
    [self.queue addOperation:op];
    // 将下载事务l记录
    [self.operationDict setObject:op forKey:model.imageUrl];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate


- (void)didReceiveMemoryWarning{
    NSLog(@"收到内存警告,你要清理内存了!!!");

    // 清空内存
    [self.imageCacheDict removeAllObjects];

    // 清空沙盒
    NSFileManager *fieldManager=[NSFileManager defaultManager];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    if ([fieldManager fileExistsAtPath:cachePath]) {
        BOOL isDel = [fieldManager removeItemAtPath:cachePath error:nil];
        if (isDel) {
            NSLog(@"删除沙盒数据成功");
        }
    }
}

#pragma mark - lazy
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        //创建一个流水布局
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection              = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing      = 5;
        layout.minimumLineSpacing           = 5;
        layout.itemSize                     = CGSizeMake((KCScreenW-15)/2.0, 260);
        
        //初始化collectionView
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 0, KCScreenW-10, KCScreenH) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.scrollsToTop    = NO;
        _collectionView.pagingEnabled   = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.bounces         = YES;
        _collectionView.dataSource      = self;
        _collectionView.delegate        = self;
        [_collectionView registerClass:[KCCollectionViewCell class] forCellWithReuseIdentifier:reuseID];
        
    }
    return _collectionView;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        // 解释一波关于数组 capacity 每次都是开辟10单位内存
        _dataArray = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataArray;
}

- (NSMutableDictionary *)imageCacheDict{
    if (!_imageCacheDict) {
        _imageCacheDict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _imageCacheDict;
}

- (NSMutableDictionary *)operationDict{
    if (!_operationDict) {
        _operationDict = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _operationDict;
}

@end


