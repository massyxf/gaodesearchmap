//
//  UIScrollView+KFooterView.m
//  KYFooter
//
//  Created by yxf on 2019/7/9.
//  Copyright © 2019 k_yan. All rights reserved.
//

#import "UIScrollView+KFooterView.h"
#import <objc/runtime.h>
#import "KFooterView.h"

char *kf = "f";

@implementation UIScrollView (KFooterView)

-(void)setKf_footerView:(KFooterView *)kf_footerView{
    if (![kf_footerView isKindOfClass:[KFooterView class]]) {
        return;
    }
    //offset监听
    [self addObserver:kf_footerView forKeyPath:KOBOffsetPath options:NSKeyValueObservingOptionNew context:nil];
    
    if ([self isKindOfClass:[UITableView class]]) {
        ((UITableView *)self).tableFooterView = kf_footerView;
        return;
    }
    objc_setAssociatedObject(self, kf, kf_footerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(KFooterView *)kf_footerView{
    if ([self isKindOfClass:[UITableView class]]) {
        UIView *view = ((UITableView *)self).tableFooterView;
        return (KFooterView *)view;
    }
    return objc_getAssociatedObject(self, kf);
}


@end
