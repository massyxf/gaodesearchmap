//
//  KFooterView.h
//  KYFooter
//
//  Created by yxf on 2019/7/9.
//  Copyright © 2019 k_yan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KFooterHeight 40
#define KOBOffsetPath @"contentOffset"

NS_ASSUME_NONNULL_BEGIN

@interface KFooterView : UIView

+(instancetype)kf_footerViewWithLoadingActionBlock:(void(^)(void))actionBlock;

-(void)endLoading;

-(void)endWithNoMoreData;

-(void)reset;

@end

NS_ASSUME_NONNULL_END
