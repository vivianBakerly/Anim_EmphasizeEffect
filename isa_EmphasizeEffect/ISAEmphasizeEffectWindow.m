//
//  ISAEmphasizeEffectWindow.m
//  isa_EmphasizeEffect
//
//  Created by isahuang on 16/3/3.
//  Copyright © 2016年 isahuang. All rights reserved.
//

#import "ISAEmphasizeEffectWindow.h"
#import "ISAEmphasizeEffectView.h"

@interface ISAEmphasizeEffectWindow()
@end

@implementation ISAEmphasizeEffectWindow

+ (instancetype)shareInstance
{
    static ISAEmphasizeEffectWindow *__animationWindow = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGRect frame = [UIScreen mainScreen].bounds;
        __animationWindow = [[ISAEmphasizeEffectWindow alloc] initWithFrame:frame];
        __animationWindow.windowLevel = UIWindowLevelStatusBar;
        __animationWindow.hidden = NO;
        __animationWindow.userInteractionEnabled = YES;
        __animationWindow.backgroundColor = [UIColor clearColor];
        __animationWindow.rootViewController = [UIViewController new];
    });
    return __animationWindow;
}

- (void)beginAnimation:(CGRect)target inputStr:(NSString *)text{
    __block ISAEmphasizeEffectView *beginView = [[ISAEmphasizeEffectView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    beginView.backgroundColor = [UIColor clearColor];
    __weak typeof(ISAEmphasizeEffectView *)weakBeginView = beginView;
    [beginView setEndGuideAnimation:^(FMEndAnimationType type){
        if(type == FMEndAnimationType_Break){
            self.windowLevel = -1;
            weakBeginView.hidden = YES;
            [weakBeginView removeAnimation];
            [weakBeginView removeFromSuperview];
        }else{
            if(!weakBeginView.isHidden){
                [UIView animateWithDuration:0.3 animations:^{
                    weakBeginView.alpha = 0;
                } completion:^(BOOL finished) {
                    [weakBeginView removeAnimation];
                    [weakBeginView removeFromSuperview];
                    self.windowLevel = -1;
                }];
            }
        }
    }];
    [self addSubview:beginView];
    [beginView startAnimation:target text:text];
    self.windowLevel = UIWindowLevelStatusBar;
}

- (void)dealloc
{
    
}

@end
