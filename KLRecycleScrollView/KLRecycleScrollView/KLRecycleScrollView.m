//
//  KLRecycleScrollView.m
//  KLRecycleScrollView
//
//  Created by karos li on 2017/12/25.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "KLRecycleScrollView.h"

@class KLInfiniteScrollView;
@protocol KLInfiniteScrollViewDelegate <NSObject>

- (UIView *)infiniteScrollView:(KLInfiniteScrollView *)infiniteScrollView viewForItemAtIndex:(NSInteger)index;
- (void)infiniteScrollView:(KLInfiniteScrollView *)infiniteScrollView didSelectView:(UIView *)view forItemAtIndex:(NSInteger)index;

@end

@interface KLInfiniteScrollView : UIScrollView

@property (nonatomic, strong, readonly) NSMutableArray *visibleViews;
@property (nonatomic, weak) id<KLInfiniteScrollViewDelegate> infiniteDelegate;

- (void)reloadData:(NSInteger)numberOfItems;

// 获取子视图距离最左边的距离
- (CGFloat)getDistanceToLeftEdge:(UIView *)view;

@end

@interface KLInfiniteScrollView ()

@property (nonatomic, strong) NSMutableArray *visibleViews;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, assign) NSInteger numberOfItems;
@property (nonatomic, assign) NSInteger rightMostVisibleViewIndex;
@property (nonatomic, assign) NSInteger leftMostVisibleViewIndex;

@end

@implementation KLInfiniteScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.contentSize = CGSizeMake(5000, self.frame.size.height);
    self.visibleViews = [[NSMutableArray alloc] init];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    [self addSubview:self.containerView];
    
    self.bounces = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    return self;
}

#pragma mark - public
- (void)reloadData:(NSInteger)numberOfItems {
    self.numberOfItems = numberOfItems;
    [self setNeedsLayout];
}

- (CGFloat)getDistanceToLeftEdge:(UIView *)view {
    CGRect visibleBounds = [self convertRect:[self bounds] toView:self.containerView];
    return CGRectGetMinX(view.frame) - CGRectGetMinX(visibleBounds);
}

#pragma mark - gesture
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UIView *hitView;
    for (UIView *view in self.containerView.subviews) {
        CGPoint point = [touches.anyObject locationInView:view];
        BOOL hasHit = [view pointInside:point withEvent:event];
        if (hasHit) {
            hitView = view;
            break;
        }
    }
    
    if (hitView.tag >= 20000) {
        NSInteger index = hitView.tag - 20000;
        if ([self.infiniteDelegate respondsToSelector:@selector(infiniteScrollView:didSelectView:forItemAtIndex:)]) {
            [self.infiniteDelegate infiniteScrollView:self didSelectView:hitView forItemAtIndex:index];
        }
    }
}

#pragma mark - Layout

// recenter content periodically to achieve impression of infinite scrolling
- (void)recenterIfNecessary {
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentWidth = [self contentSize].width;
    CGFloat centerOffsetX = (contentWidth - [self bounds].size.width) / 2.0;
    CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
    
    if (distanceFromCenter > (contentWidth / 4.0)) {
        self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
        
        // move content by the same amount so it appears to stay still
        for (UIView *label in self.visibleViews) {
            CGPoint center = [self.containerView convertPoint:label.center toView:self];
            center.x += (centerOffsetX - currentOffset.x);
            label.center = [self convertPoint:center toView:self.containerView];
        }
    }
}

- (void)layoutSubviews {
    if (self.numberOfItems > 0) {
        [self recenterIfNecessary];
        
        // tile content in visible bounds
        CGRect visibleBounds = [self convertRect:[self bounds] toView:self.containerView];
        CGFloat minimumVisibleX = CGRectGetMinX(visibleBounds);
        CGFloat maximumVisibleX = CGRectGetMaxX(visibleBounds);
        
        [self tileViewsFromMinX:minimumVisibleX toMaxX:maximumVisibleX];
    }
    
    [super layoutSubviews];
}

#pragma mark - View Tiling

- (CGFloat)placeNewViewOnRight:(CGFloat)rightEdge {
    _rightMostVisibleViewIndex++;
    if (_rightMostVisibleViewIndex == self.numberOfItems) {
        _rightMostVisibleViewIndex = 0;
    }
    
    UIView *view;
    if ([self.infiniteDelegate respondsToSelector:@selector(infiniteScrollView:viewForItemAtIndex:)]) {
        view = [self.infiniteDelegate infiniteScrollView:self viewForItemAtIndex:_rightMostVisibleViewIndex];
    }
    
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    }
    
    view.tag = 20000 + _rightMostVisibleViewIndex;
    [_containerView addSubview:view];
    [_visibleViews addObject:view]; // add rightmost label at the end of the array
    
    CGRect frame = [view frame];
    frame.origin.x = rightEdge;
    frame.origin.y = 0;
    [view setFrame:frame];
    return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewViewOnLeft:(CGFloat)leftEdge {
    _leftMostVisibleViewIndex--;
    if (_leftMostVisibleViewIndex < 0) {
        _leftMostVisibleViewIndex = self.numberOfItems - 1;
    }

    UIView *view;
    if ([self.infiniteDelegate respondsToSelector:@selector(infiniteScrollView:viewForItemAtIndex:)]) {
        view = [self.infiniteDelegate infiniteScrollView:self viewForItemAtIndex:_leftMostVisibleViewIndex];
    }
    
    if (!view) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    }
    
    view.tag = 20000 + _leftMostVisibleViewIndex;
    [_containerView addSubview:view];
    [_visibleViews insertObject:view atIndex:0]; // add leftmost label at the beginning of the array
    
    CGRect frame = [view frame];
    frame.origin.x = leftEdge - frame.size.width;
    frame.origin.y = 0;
    [view setFrame:frame];
    
    return CGRectGetMinX(frame);
}

- (void)tileViewsFromMinX:(CGFloat)minimumVisibleX toMaxX:(CGFloat)maximumVisibleX {
    // the upcoming tiling logic depends on there already being at least one label in the visibleLabels array, so
    // to kick off the tiling we need to make sure there's at least one label
    if ([_visibleViews count] == 0) {
        _rightMostVisibleViewIndex = -1;
        _leftMostVisibleViewIndex = 0;
        [self placeNewViewOnRight:minimumVisibleX];
    }
    
    // add labels that are missing on right side
    UIView *lastView = [_visibleViews lastObject];
    CGFloat rightEdge = CGRectGetMaxX([lastView frame]);
    
    while (rightEdge < maximumVisibleX) {
        rightEdge = [self placeNewViewOnRight:rightEdge];
    }
    
    // add labels that are missing on left side
    UIView *firstView = _visibleViews[0];
    CGFloat leftEdge = CGRectGetMinX([firstView frame]);
    while (leftEdge > minimumVisibleX) {
        leftEdge = [self placeNewViewOnLeft:leftEdge];
    }
    
    // remove labels that have fallen off right edge
    lastView = [_visibleViews lastObject];
    while ([lastView frame].origin.x > maximumVisibleX) {
        [lastView removeFromSuperview];
        [_visibleViews removeLastObject];
        lastView = [_visibleViews lastObject];
        
        _rightMostVisibleViewIndex--;
        if (_rightMostVisibleViewIndex < 0) {
            _rightMostVisibleViewIndex = self.numberOfItems - 1;
        }
    }
    
    // remove labels that have fallen off left edge
    firstView = _visibleViews[0];
    while (CGRectGetMaxX([firstView frame]) < minimumVisibleX) {
        [firstView removeFromSuperview];
        [_visibleViews removeObjectAtIndex:0];
        firstView = _visibleViews[0];
        
        _leftMostVisibleViewIndex++;
        if (_leftMostVisibleViewIndex == self.numberOfItems) {
            _leftMostVisibleViewIndex = 0;
        }
    }
}

@end

@interface KLRecycleScrollView() <UIScrollViewDelegate, KLInfiniteScrollViewDelegate>

@property (strong, nonatomic) KLInfiniteScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *containerViews;

@property (assign, nonatomic) NSInteger totalItemsCount;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation KLRecycleScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.scrollInterval = 3.5;
    [self setupView];
    
    return self;
}

- (void)setupView {
    self.scrollView = [[KLInfiniteScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    self.scrollView.infiniteDelegate = self;
    [self addSubview:self.scrollView];
}

#pragma mark - public methods
- (void)reloadData:(NSInteger)totalItemsCount {
    self.totalItemsCount = totalItemsCount;
    [self.scrollView reloadData:totalItemsCount];
    
    [self startTimer];
}

- (void)setPagingEnabled:(BOOL)pagingEnabled {
    _pagingEnabled = pagingEnabled;
    self.scrollView.decelerationRate = pagingEnabled ? UIScrollViewDecelerationRateFast : UIScrollViewDecelerationRateNormal;
}

#pragma mark - timer
- (void)fireTimer {
    [UIView animateWithDuration:0.75 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        if (self.direction == KLRecycleScrollViewDirectionFromTopToBottom) {
//            [self.scrollView setContentOffset:CGPointMake(0, self.bounds.size.height * 3) animated:NO];
//        } else if (self.direction == KLRecycleScrollViewDirectionFromLeftToRight) {
//            [self.scrollView setContentOffset:CGPointMake(self.bounds.size.width * 3, 0) animated:NO];
//        } else {
//            [self.scrollView setContentOffset:CGPointMake(0, self.bounds.size.height * 3) animated:NO];
//        }
        CGPoint contentOffset = self.scrollView.contentOffset;
        [self.scrollView setContentOffset:CGPointMake(contentOffset.x + self.bounds.size.width, 0) animated:NO];
    } completion:^(BOOL finished) {
    }];
}

- (void)configTimer {
    self.timer = [NSTimer timerWithTimeInterval:self.scrollInterval target:self selector:@selector(fireTimer) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)startTimer {
    if (self.timerEnabled && !self.timer) {
        [self configTimer];
    }
}

- (void)stopTimer {
    if (self.timerEnabled) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - KLInfiniteScrollViewDelegate
- (UIView *)infiniteScrollView:(KLInfiniteScrollView *)infiniteScrollView viewForItemAtIndex:(NSInteger)index {
    UIView *subview;
    if ([self.delegate respondsToSelector:@selector(recycleScrollView:viewForItemAtIndex:)]) {
        subview = [self.delegate recycleScrollView:self viewForItemAtIndex:index];
    }
    
    subview.frame = self.bounds;
    return subview;
}

- (void)infiniteScrollView:(KLInfiniteScrollView *)infiniteScrollView didSelectView:(UIView *)view forItemAtIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(recycleScrollView:didSelectView:forItemAtIndex:)]) {
        [self.delegate recycleScrollView:self didSelectView:view forItemAtIndex:index];
    }
}

#pragma mark - override
- (void)setClipsToBounds:(BOOL)clipsToBounds {
    [super setClipsToBounds:clipsToBounds];
    self.scrollView.clipsToBounds = clipsToBounds;
}

#pragma mark - scroll view deleaget
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.pagingEnabled) {
        NSInteger width = self.bounds.size.width;
        NSInteger extra = 0;
        if (velocity.x != 0) {
            extra = velocity.x > 0 ? width : -width;
        }
        
        CGPoint targetOffset = [self getLeftestViewToLeftEdge];
        targetContentOffset->x = targetOffset.x + extra;
        targetContentOffset->y = targetOffset.y;
    }
}

- (CGPoint)getLeftestViewToLeftEdge {
    CGPoint offset = self.scrollView.contentOffset;

    __block CGFloat minDistanceFromLeftEdge = MAXFLOAT;
    __block UIView *minDistanceFromLeftEdgeView;

    __weak typeof(self) weakSelf = self;
    [self.scrollView.visibleViews enumerateObjectsUsingBlock:^(id  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat distanceToLeftEdge = [weakSelf.scrollView getDistanceToLeftEdge:view];
        if (distanceToLeftEdge < fabs(minDistanceFromLeftEdge)) {
            minDistanceFromLeftEdge = distanceToLeftEdge;
            minDistanceFromLeftEdgeView = view;
        }
    }];

    CGFloat targetX = offset.x + minDistanceFromLeftEdge;
    CGPoint targetOffset = CGPointMake(targetX, offset.y);

    return targetOffset;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.scrollView) {
        if (!decelerate) {
            [self startTimer];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        [self startTimer];
    }
}

@end
