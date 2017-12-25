//
//  KLRecycleScrollView.h
//  KLRecycleScrollView
//
//  Created by karos li on 2017/12/25.
//  Copyright © 2017年 karos. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KLRecycleScrollViewDirection) {
    KLRecycleScrollViewDirectionFromTopToBottom,
    KLRecycleScrollViewDirectionFromLeftToRight
};

@class KLRecycleScrollView;
@protocol KLRecycleScrollViewDelegate <NSObject>

- (UIView *)recycleScrollView:(KLRecycleScrollView *)recycleScrollView cachedView:(UIView *)cachedView forRowAtIndex:(NSInteger)index;
- (void)recycleScrollView:(KLRecycleScrollView *)recycleScrollView didSelectRowAtIndex:(NSInteger)index;

@end

@interface KLRecycleScrollView : UIView

- (instancetype)initWithFrame:(CGRect)frame direction:(KLRecycleScrollViewDirection)direction;

@property (nonatomic, weak) id<KLRecycleScrollViewDelegate> delegate;

// 滚动间隔时间，默认值是 3.5
@property (nonatomic, assign) CGFloat scrollInterval;

- (void)reloadData:(NSInteger)totalItemsCount;

@end
