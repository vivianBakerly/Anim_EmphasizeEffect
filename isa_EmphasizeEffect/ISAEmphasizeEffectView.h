//
//  ISAEmphasizeEffectView.h
//  isa_EmphasizeEffect
//
//  Created by isahuang on 16/3/3.
//  Copyright © 2016年 isahuang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum:NSUInteger {
    FMEndAnimationType_Break = 0,
    FMEndAnimationType_End = 1,
}FMEndAnimationType;

typedef void (^endAnimation)(FMEndAnimationType type);

@interface ISAEmphasizeEffectView : UIView
@property (nonatomic, copy)endAnimation endGuideAnimation;
/**
 *  开始动画的方法
 *
 *  @param target CGRect中的origin表示最终聚焦的圆心，size表示圆的半径
 *  @param str 需要在缩放圆旁显示的文字
 */
- (void)startAnimation:(CGRect)target text:(NSString *)str;
- (void)removeAnimation;
@end
