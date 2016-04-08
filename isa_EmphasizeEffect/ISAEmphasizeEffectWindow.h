//
//  ISAEmphasizeEffectWindow.h
//  isa_EmphasizeEffect
//
//  Created by isahuang on 16/3/3.
//  Copyright © 2016年 isahuang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ISAEmphasizeEffectWindow : UIWindow

+ (instancetype)shareInstance;
- (void)beginAnimation:(CGRect)target inputStr:(NSString *)text;
@end
