//
//  KFooterView.m
//  KYFooter
//
//  Created by yxf on 2019/7/9.
//  Copyright © 2019 k_yan. All rights reserved.
//

#import "KFooterView.h"

#define IndiWidth 20

@interface KFooterView ()

/*indicator*/
@property (nonatomic,weak)UIActivityIndicatorView *indiView;


@property (nonatomic,assign)BOOL isLoading;

/*没有数据了*/
@property (nonatomic,assign)BOOL hasMore;

/*loading block*/
@property (nonatomic,copy)void (^taskBlock)(void);

/*current task */
@property (nonatomic,copy)void (^currentTaskBlock)(void);

/*tips label*/
@property (nonatomic,weak)UILabel *tipsLabel;

/*tips*/
@property (nonatomic,copy)NSString *tips;

@end

@implementation KFooterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIActivityIndicatorView *indiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:indiView];
        indiView.hidesWhenStopped = YES;
        indiView.color = [UIColor grayColor];
        _indiView = indiView;
        
        _hasMore = YES;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

+(instancetype)kf_footerViewWithLoadingActionBlock:(void (^)(void))actionBlock{
    KFooterView *view = [[KFooterView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, KFooterHeight)];
    view.taskBlock = actionBlock;
    return view;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    if (_tips.length > 0) {
        _tipsLabel.hidden = NO;
        _tipsLabel.center = CGPointMake(width / 2, KFooterHeight / 2);
    }else{
        _tipsLabel.hidden = YES;
    }
    _indiView.center = CGPointMake(width / 2, KFooterHeight / 2);
}

#pragma mark - setter
-(void)setTips:(NSString *)tips{
    _tips = tips;
    self.tipsLabel.text = tips;
    [self.tipsLabel sizeToFit];
    [self layoutIfNeeded];
}

#pragma mark - getter
-(void (^)(void))currentTaskBlock{
    if (!_currentTaskBlock) {
        _currentTaskBlock = [_taskBlock copy];
    }
    return _currentTaskBlock;
}

-(UILabel *)tipsLabel{
    if (!_tipsLabel) {
        UILabel *tipLabel = [[UILabel alloc] init];
        [self addSubview:tipLabel];
        tipLabel.textColor = [UIColor grayColor];
        tipLabel.font = [UIFont systemFontOfSize:13];
        _tipsLabel = tipLabel;
    }
    return _tipsLabel;
}

#pragma mark - control
-(void)startLoading{
    if (_isLoading) { return; }
    if (!_hasMore) { return; }
    self.tips = @"";
    _isLoading = YES;
    [_indiView startAnimating];
    if (self.currentTaskBlock) {
        self.currentTaskBlock();
    }
}

-(void)endLoading{
    if (!_isLoading) { return; }
    _isLoading = NO;
    [_indiView stopAnimating];
    self.currentTaskBlock = nil;
}

-(void)endWithNoMoreData{
    self.tips = @"没有更多数据了。";
    _hasMore = NO;
    [self endLoading];
}

- (void)reset{
    _hasMore = YES;
}


#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:KOBOffsetPath])
    {
        UIScrollView *scrollView = (UIScrollView *)object;
        if (![scrollView isKindOfClass:[UIScrollView class]]){ return; }
        
        CGFloat contentHeight = scrollView.contentSize.height;
        CGFloat height = scrollView.frame.size.height;
        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
//        NSLog(@"offsetY:%f,height:%f,contentHeight:%f,top:%f,bottom:%f",offset.y,height,contentHeight,scrollView.contentInset.top,scrollView.contentInset.bottom);
        
        if (height - scrollView.contentInset.top - scrollView.contentInset.bottom < contentHeight)
        {//内容超过一屏
            if (offset.y + height - scrollView.contentInset.bottom > contentHeight)
            {
                [self startLoading];
            }
            return;
        }
        
        //内容不超过一屏,由于offset.y的起始值为-scrollView.contentInset.top，因此只要offset.y > -scrollView.contentInset.top就是s上拉了
        if (offset.y > -scrollView.contentInset.top)
        {//此时向上拉就是在刷新
            [self startLoading];
        }
    }
}

@end
