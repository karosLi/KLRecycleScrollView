//
//  KLRecycleScrollView.m
//  KLRecycleScrollView
//
//  Created by karos li on 2017/12/25.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "KLRecycleScrollView.h"

@interface KLRecycleScrollView() <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, assign) KLRecycleScrollViewDirection direction;

@property (strong, nonatomic) NSMutableArray *containerViews;
@property (strong, nonatomic) NSArray *imgs;
@property (strong, nonatomic) NSArray *urls;

@property (assign, nonatomic) NSInteger totalItemsCount;
@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation KLRecycleScrollView

- (instancetype)initWithFrame:(CGRect)frame direction:(KLRecycleScrollViewDirection)direction {
    self = [super initWithFrame:frame];
    self.direction = direction;
    self.scrollInterval = 3.5;
    [self setupView];
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    @throw [NSException exceptionWithName:@"KLRecycleScrollView" reason:@"Please use method initWithFrame:direction: to initialize object" userInfo:nil];
    
    return self;
}

- (void)setupView {
    self.scrollView.frame = self.bounds;
    [self addSubview:self.scrollView];
    
    self.containerViews = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i++) {
        UIView *containerView = [UIView new];
        
        if (self.direction == KLRecycleScrollViewDirectionFromTopToBottom) {
            containerView.frame = CGRectMake(0, self.bounds.size.height * i, self.bounds.size.width, self.bounds.size.height);
        } else if (self.direction == KLRecycleScrollViewDirectionFromLeftToRight) {
            containerView.frame = CGRectMake(self.bounds.size.width * i, 0, self.bounds.size.width, self.bounds.size.height);
        } else {
            containerView.frame = CGRectMake(0, self.bounds.size.height * i, self.bounds.size.width, self.bounds.size.height);
        }
        
        [self.scrollView addSubview:containerView];
        [self.containerViews addObject:containerView];
    }
    
    if (self.direction == KLRecycleScrollViewDirectionFromTopToBottom) {
        [self.scrollView setContentSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height * 3)];
        self.scrollView.contentOffset = CGPointMake(0, self.bounds.size.height);
    } else if (self.direction == KLRecycleScrollViewDirectionFromLeftToRight) {
        [self.scrollView setContentSize:CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height)];
        self.scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
    } else {
        [self.scrollView setContentSize:CGSizeMake(self.bounds.size.width, self.bounds.size.height * 3)];
        self.scrollView.contentOffset = CGPointMake(0, self.bounds.size.height);
    }
    
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapContainerView:)]];
}

#pragma mark - public methods
- (void)reloadData:(NSInteger)totalItemsCount {
    self.totalItemsCount = totalItemsCount;
    [self reloadSubViews];
}

#pragma mark - private methods
- (void)reloadSubViews {
    CGFloat offset;
    CGFloat pageWidth;
    
    if (self.direction == KLRecycleScrollViewDirectionFromTopToBottom) {
        offset = self.scrollView.contentOffset.y;
        pageWidth = self.bounds.size.height;
    } else if (self.direction == KLRecycleScrollViewDirectionFromLeftToRight) {
        offset = self.scrollView.contentOffset.x;
        pageWidth = self.bounds.size.width;
    } else {
        offset = self.scrollView.contentOffset.y;
        pageWidth = self.bounds.size.height;
    }
    
    if (offset > pageWidth) { // 向右
        self.index++;
    } else if (offset < pageWidth) { // 向左
        self.index--;
    } else {
        
    }
    
    // 修正当前索引
    if (self.index < 0) {
        self.index = self.totalItemsCount - 1;
    } else if (self.index > self.totalItemsCount - 1) {
        self.index = 0;
    }
    
    NSInteger preIndex = self.index - 1 >= 0 ? self.index - 1 : self.totalItemsCount - 1;
    NSInteger curIndex = self.index;
    NSInteger nextIndex = self.index + 1 < self.totalItemsCount ? self.index + 1 : 0;
    
    UIView *preContainerView = self.containerViews[0];
    UIView *centerContainerView = self.containerViews[1];
    UIView *nextContainerView = self.containerViews[2];
    
    [preContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [centerContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [nextContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if ([self.delegate respondsToSelector:@selector(recycleScrollView:viewForRowAtIndex:)]) {
        UIView *preSubView = [self.delegate recycleScrollView:self viewForRowAtIndex:preIndex];
        UIView *curSubView = [self.delegate recycleScrollView:self viewForRowAtIndex:curIndex];
        UIView *nextSubView = [self.delegate recycleScrollView:self viewForRowAtIndex:nextIndex];
        
        nextSubView.frame = self.bounds;
        curSubView.frame = self.bounds;
        nextSubView.frame = self.bounds;
        
        [preContainerView addSubview:preSubView];
        [centerContainerView addSubview:curSubView];
        [nextContainerView addSubview:nextSubView];
    }
    
    if (self.direction == KLRecycleScrollViewDirectionFromTopToBottom) {
        self.scrollView.contentOffset = CGPointMake(0, self.bounds.size.height);
    } else if (self.direction == KLRecycleScrollViewDirectionFromLeftToRight) {
        self.scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
    } else {
        self.scrollView.contentOffset = CGPointMake(0, self.bounds.size.height);
    }
    
    if (!self.timer) {
        [self startTimer];
    }
}

- (void)fireTimer {
    [UIView animateWithDuration:0.75 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.direction == KLRecycleScrollViewDirectionFromTopToBottom) {
            [self.scrollView setContentOffset:CGPointMake(0, self.bounds.size.height * 2) animated:NO];
        } else if (self.direction == KLRecycleScrollViewDirectionFromLeftToRight) {
            [self.scrollView setContentOffset:CGPointMake(self.bounds.size.width * 2, 0) animated:NO];
        } else {
            [self.scrollView setContentOffset:CGPointMake(0, self.bounds.size.height * 2) animated:NO];
        }
    } completion:^(BOOL finished) {
        [self reloadSubViews];
        [self startTimer];
    }];
}

- (void)startTimer {
    self.timer = [NSTimer timerWithTimeInterval:self.scrollInterval target:self selector:@selector(fireTimer) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark - gesture
- (void)onTapContainerView:(UIGestureRecognizer *)g {
    if ([self.delegate respondsToSelector:@selector(recycleScrollView:didSelectRowAtIndex:)]) {
        [self.delegate recycleScrollView:self didSelectRowAtIndex:self.index];
    }
}

#pragma mark - scroll view deleaget
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.scrollView) {
        if (!decelerate) {
            [self reloadSubViews];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        [self reloadSubViews];
    }
}

#pragma mark - getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
    }
    
    return _scrollView;
}



@end
