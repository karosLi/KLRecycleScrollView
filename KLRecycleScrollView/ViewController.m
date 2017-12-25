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

@property (nonatomic, strong) KLRecycleScrollView *message;
@property (nonatomic, strong) KLRecycleScrollView *hmessage;
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
    
    self.message = [[KLRecycleScrollView alloc] initWithFrame:CGRectMake(20, 200, 200, 50) direction:KLRecycleScrollViewDirectionFromTopToBottom];
    self.message.delegate = self;
    self.message.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    
    [self.view addSubview:self.message];
    [self.message reloadData:self.datas.count];
    
    self.hmessage = [[KLRecycleScrollView alloc] initWithFrame:CGRectMake(20, 400, 200, 50) direction:KLRecycleScrollViewDirectionFromLeftToRight];
    self.hmessage.delegate = self;
    self.hmessage.scrollInterval = 2;
    self.hmessage.clipsToBounds = NO;
    self.hmessage.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    
    [self.view addSubview:self.hmessage];
    [self.hmessage reloadData:self.datas.count];
}

- (UIView *)recycleScrollView:(KLRecycleScrollView *)recycleScrollView cachedView:(UIView *)cachedView forRowAtIndex:(NSInteger)index {
    UILabel *label;
    
    if ([cachedView isKindOfClass:[UILabel class]]) {
        label = (UILabel *)cachedView;
        label.text = self.datas[index];
    } else {
        label = [UILabel new];
        label.text = self.datas[index];
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    if (index % 2 == 0) {
        label.backgroundColor = [UIColor redColor];
    } else {
        label.backgroundColor = [UIColor blueColor];
    }

    return label;
}

- (void)recycleScrollView:(KLRecycleScrollView *)recycleScrollView didSelectRowAtIndex:(NSInteger)index {
    NSLog(@"tap %@", self.datas[index]);
}

@end
