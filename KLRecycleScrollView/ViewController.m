//
//  ViewController.m
//  KLRecycleScrollView
//
//  Created by karos li on 2017/12/25.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "ViewController.h"
#import "KLRecycleScrollView.h"

@interface ViewController () <KLRecycleScrollViewDelegate>

// 往上滚动
@property (nonatomic, strong) KLRecycleScrollView *vmessage;

// 往下滚动
@property (nonatomic, strong) KLRecycleScrollView *v1message;

// 往左滚动
@property (nonatomic, strong) KLRecycleScrollView *hmessage;

// 往右滚动
@property (nonatomic, strong) KLRecycleScrollView *h1message;

@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datas = [NSMutableArray array];
    [self.datas addObject:@"1"];
    [self.datas addObject:@"2"];
    [self.datas addObject:@"3"];
    [self.datas addObject:@"4"];
    [self.datas addObject:@"5"];
    [self.datas addObject:@"6"];
    [self.datas addObject:@"7"];
    
    self.vmessage = [[KLRecycleScrollView alloc] initWithFrame:CGRectMake(20, 200, 200, 50)];
    self.vmessage.delegate = self;
    self.vmessage.direction = KLRecycleScrollViewDirectionTop;
    self.vmessage.pagingEnabled = YES;
    self.vmessage.timerEnabled = YES;
    self.vmessage.scrollInterval = 3;
    self.vmessage.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.view addSubview:self.vmessage];
    [self.vmessage reloadData:self.datas.count];
    
    self.v1message = [[KLRecycleScrollView alloc] initWithFrame:CGRectMake(20, 300, 200, 50)];
    self.v1message.delegate = self;
    self.v1message.direction = KLRecycleScrollViewDirectionBottom;
    self.v1message.pagingEnabled = YES;
    self.v1message.timerEnabled = YES;
    self.v1message.scrollInterval = 3;
    self.v1message.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.view addSubview:self.v1message];
    [self.v1message reloadData:self.datas.count];
    
    self.hmessage = [[KLRecycleScrollView alloc] initWithFrame:CGRectMake(20, 400, 200, 50)];
    self.hmessage.delegate = self;
    self.hmessage.direction = KLRecycleScrollViewDirectionLeft;
    self.hmessage.pagingEnabled = YES;
    self.hmessage.timerEnabled = YES;
    self.hmessage.scrollInterval = 3;
//    self.hmessage.clipsToBounds = NO;
    self.hmessage.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.view addSubview:self.hmessage];
    [self.hmessage reloadData:self.datas.count];
    
    self.h1message = [[KLRecycleScrollView alloc] initWithFrame:CGRectMake(20, 500, 200, 50)];
    self.h1message.delegate = self;
    self.h1message.direction = KLRecycleScrollViewDirectionRight;
    self.h1message.pagingEnabled = YES;
    self.h1message.timerEnabled = YES;
    self.h1message.scrollInterval = 3;
    //    self.hmessage.clipsToBounds = NO;
    self.h1message.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.view addSubview:self.h1message];
    [self.h1message reloadData:self.datas.count];
}

- (UIView *)recycleScrollView:(KLRecycleScrollView *)recycleScrollView viewForItemAtIndex:(NSInteger)index {
    UILabel *label;
    label = [UILabel new];
    label.text = self.datas[index];
    label.textAlignment = NSTextAlignmentCenter;
    
    if (index % 2 == 0) {
        label.backgroundColor = [UIColor redColor];
    } else {
        label.backgroundColor = [UIColor blueColor];
    }

    return label;
}

- (void)recycleScrollView:(KLRecycleScrollView *)recycleScrollView didSelectView:(UIView *)view forItemAtIndex:(NSInteger)index {
    NSLog(@"tap %@", self.datas[index]);
}

@end
