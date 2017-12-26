//
//  KLRecycleScrollView.h
//  KLRecycleScrollView
//
//  Created by karos li on 2017/12/25.
//  Copyright © 2017年 karos. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KLRecycleScrollViewDirection) {
    KLRecycleScrollViewDirectionFromLeftToRight,
    KLRecycleScrollViewDirectionFromTopToBottom,
    
};

@class KLRecycleScrollView;
@protocol KLRecycleScrollViewDelegate <NSObject>

- (UIView *)recycleScrollView:(KLRecycleScrollView *)recycleScrollView viewForItemAtIndex:(NSInteger)index;
- (void)recycleScrollView:(KLRecycleScrollView *)recycleScrollView didSelectView:(UIView *)view forItemAtIndex:(NSInteger)index;

@end

@interface KLRecycleScrollView : UIView

@property (nonatomic, weak) id<KLRecycleScrollViewDelegate> delegate;

// 是否需要分页
@property (nonatomic, assign) BOOL pagingEnabled;

// 是否需要开启定时器
@property (nonatomic, assign) BOOL timerEnabled;

// 滚动间隔时间，默认值是 3.5, timerEnabled 开启时，才起作用
@property (nonatomic, assign) CGFloat scrollInterval;

// 定时器自动滚动方向，默认从左到右, timerEnabled 开启时，才起作用
@property (nonatomic, assign) KLRecycleScrollViewDirection direction;

- (void)reloadData:(NSInteger)totalItemsCount;

@end
