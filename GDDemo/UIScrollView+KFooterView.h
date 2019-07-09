//
//  UIScrollView+KFooterView.h
//  KYFooter
//
//  Created by yxf on 2019/7/9.
//  Copyright © 2019 k_yan. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 目前只做了tableview的footer，tableview需要遵守下面的方法
 if (@available(iOS 11.0,*)) {
 tabView.contentInsetAdjustmentBehavior =  UIScrollViewContentInsetAdjustmentNever;
 } else {
 self.automaticallyAdjustsScrollViewInsets = NO;
 }
 */

@class KFooterView;

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (KFooterView)

/*footer view*/
@property (nonatomic,strong)KFooterView *kf_footerView;

@end

NS_ASSUME_NONNULL_END
