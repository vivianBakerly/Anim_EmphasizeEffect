//
//  ViewController.m
//  isa_EmphasizeEffect
//
//  Created by isahuang on 16/3/2.
//  Copyright © 2016年 isahuang. All rights reserved.
//

#import "ViewController.h"
#import "ISAEmphasizeEffectWindow.h"

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *backGroundView = [[backgroundView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:backGroundView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation backgroundView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPoint=[[touches anyObject]locationInView:self];
    [[ISAEmphasizeEffectWindow shareInstance] beginAnimation:CGRectMake(touchPoint.x, touchPoint.y, 55, 55) inputStr:@"哪里不会点哪里!"];
}
@end