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

@property (nonatomic, strong) NSMutableArray *datas;

// 往上滚动
@property (nonatomic, strong) KLRecycleScrollView *vmessage;

// 往下滚动
@property (nonatomic, strong) KLRecycleScrollView *v1message;

// 往左滚动
@property (nonatomic, strong) KLRecycleScrollView *hmessage;

// 往右滚动
@property (nonatomic, strong) KLRecycleScrollView *h1message;

// banner
@property (nonatomic, strong) KLRecycleScrollView *banner;
@property (nonatomic, strong) UIPageControl *page;
@property (nonatomic, strong) NSMutableArray *bannerDatas;


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
    
    self.vmessage = [[KLRecycleScrollView alloc] initWithFrame:CGRectMake(20, 50, 200, 50)];
    self.vmessage.delegate = self;
    self.vmessage.direction = KLRecycleScrollViewDirectionTop;
    self.vmessage.pagingEnabled = YES;
    self.vmessage.timerEnabled = YES;
    self.vmessage.scrollInterval = 3;
    self.vmessage.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.view addSubview:self.vmessage];
    [self.vmessage reloadData:self.datas.count];
    
    self.v1message = [[KLRecycleScrollView alloc] initWithFrame:CGRectMake(20, 150, 200, 50)];
    self.v1message.delegate = self;
    self.v1message.direction = KLRecycleScrollViewDirectionBottom;
    self.v1message.pagingEnabled = YES;
    self.v1message.timerEnabled = YES;
    self.v1message.scrollInterval = 3;
    self.v1message.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.view addSubview:self.v1message];
    [self.v1message reloadData:self.datas.count];
    
    self.hmessage = [[KLRecycleScrollView alloc] initWithFrame:CGRectMake(20, 250, 200, 50)];
    self.hmessage.delegate = self;
    self.hmessage.direction = KLRecycleScrollViewDirectionLeft;
    self.hmessage.pagingEnabled = YES;
    self.hmessage.timerEnabled = YES;
    self.hmessage.scrollInterval = 3;
//    self.hmessage.clipsToBounds = NO;
    self.hmessage.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.view addSubview:self.hmessage];
    [self.hmessage reloadData:self.datas.count];
    
    self.h1message = [[KLRecycleScrollView alloc] initWithFrame:CGRectMake(20, 350, 200, 50)];
    self.h1message.delegate = self;
    self.h1message.direction = KLRecycleScrollViewDirectionRight;
    self.h1message.pagingEnabled = YES;
    self.h1message.timerEnabled = YES;
    self.h1message.scrollInterval = 3;
    //    self.hmessage.clipsToBounds = NO;
    self.h1message.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.view addSubview:self.h1message];
    [self.h1message reloadData:self.datas.count];
    
    self.bannerDatas = [NSMutableArray array];
    [self.bannerDatas addObject:@"1.jpg"];
    [self.bannerDatas addObject:@"2.jpg"];
    [self.bannerDatas addObject:@"3.jpg"];
    [self.bannerDatas addObject:@"4.jpg"];
    [self.bannerDatas addObject:@"5.jpg"];
    [self.bannerDatas addObject:@"6.jpg"];
    
    self.banner = [[KLRecycleScrollView alloc] initWithFrame:CGRectMake(0, 450, self.view.bounds.size.width, 200)];
    self.banner.delegate = self;
    self.banner.direction = KLRecycleScrollViewDirectionLeft;
    self.banner.pagingEnabled = YES;
    self.banner.timerEnabled = YES;
    self.banner.scrollInterval = 3;
    //    self.hmessage.clipsToBounds = NO;
    self.banner.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.view addSubview:self.banner];
    [self.banner reloadData:self.bannerDatas.count];
    
    self.page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.banner.frame) - 30, self.view.bounds.size.width, 10)];
    self.page.pageIndicatorTintColor = [UIColor orangeColor];
    self.page.numberOfPages = self.bannerDatas.count;
    [self.view addSubview:self.page];
}

- (UIView *)recycleScrollView:(KLRecycleScrollView *)recycleScrollView viewForItemAtIndex:(NSInteger)index {
    if (self.banner == recycleScrollView) {
        UIImageView *image = [UIImageView new];
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.image = [UIImage imageNamed:self.bannerDatas[index]];
        
        UILabel *label;
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
        label.text = self.bannerDatas[index];
        label.textColor = [UIColor redColor];
        label.textAlignment = NSTextAlignmentCenter;
        
        [image addSubview:label];
        
        return image;
    } else {
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
}

- (void)recycleScrollView:(KLRecycleScrollView *)recycleScrollView didSelectView:(UIView *)view forItemAtIndex:(NSInteger)index {
    if (self.banner == recycleScrollView) {
        NSLog(@"tap %@", self.bannerDatas[index]);
    } else {
        NSLog(@"tap %@", self.datas[index]);
    }
}

- (void)recycleScrollView:(KLRecycleScrollView *)recycleScrollView didScrollView:(UIView *)view forItemToIndex:(NSInteger)index {
    if (self.banner == recycleScrollView) {
        NSLog(@"%zd %@",index,  self.bannerDatas[index]);
        self.page.currentPage = index;
    }
}

@end
