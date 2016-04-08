//
//  ISAEmphasizeEffectView.m
//  isa_EmphasizeEffect
//
//  Created by isahuang on 16/3/3.
//  Copyright © 2016年 isahuang. All rights reserved.
//

#import "ISAEmphasizeEffectView.h"

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

#define maxBorderWidth 6
#define minBorderWidth 1
#define firstStepTotalTime 0.5
#define nontToMinTime 0.04
#define zoomOutTime 0.4
#define zoomInTime 0.2
#define stopTime 0.04

#define firstStepAnimation @"firstStepAnimation"
#define secondStepAnimation @"secondStepAnimation"
#define thirdStepAnimation @"thirdStepAnimation"
@interface ISAEmphasizeEffectView()

@property (nonatomic)CGFloat distance;
@property (nonatomic, strong)CALayer *lightColorLayer;
@property (nonatomic, strong)CALayer *darkColorLayer;
@property (nonatomic, strong)UILabel *textView;
@property (nonatomic, strong)CALayer *yellowCircleLayer;
@property (nonatomic)CGRect target;
@end

@implementation ISAEmphasizeEffectView

#pragma mark init & dealloc
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)dealloc
{
    
}

#pragma mark Touch Interaction
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endBeginnerGuideAnimation];
}

#pragma mark Animation Processing
- (void)startAnimation:(CGRect)target text:(NSString *)str{
    CGPoint centrePoint = target.origin;
    self.target = target;
    self.distance = [self distanceFrom:[self utmostPoint:centrePoint] toPoint:centrePoint];
    [self initAnimationSetting:str];
    [self firstAnimation];
}

- (void)firstAnimation
{
    CGFloat multiple = 1.1;
    CGFloat darkR = self.distance * multiple;
    CGFloat targetR = self.target.size.width / 2;
    [self addMask: self.distance inLayer:self.lightColorLayer atLocation:CGPointMake(self.lightColorLayer.bounds.size.width / 2,  self.lightColorLayer.bounds.size.width / 2)];
    [self addMask: self.distance * multiple inLayer:self.darkColorLayer atLocation:CGPointMake(self.darkColorLayer.bounds.size.width / 2,  self.darkColorLayer.bounds.size.width / 2)];
    
    [self.lightColorLayer addAnimation:[self scaleAnimation:firstStepTotalTime targetScale:(targetR/self.distance) beginTime:0] forKey:firstStepAnimation];
    [self.darkColorLayer addAnimation:[self scaleAnimation:firstStepTotalTime targetScale:(targetR/darkR) beginTime:0] forKey:firstStepAnimation];
}

- (void)secondAnimation
{
    self.yellowCircleLayer = [CALayer layer];
    CGFloat r = self.target.size.width / 2 + maxBorderWidth;
    self.yellowCircleLayer.frame = CGRectMake(self.target.origin.x - r, self.target.origin.y - r, r * 2, r * 2);
    self.yellowCircleLayer.backgroundColor = [UIColor clearColor].CGColor;
    self.yellowCircleLayer.borderColor = [UIColor yellowColor].CGColor;
    self.yellowCircleLayer.borderWidth = maxBorderWidth;
    self.yellowCircleLayer.cornerRadius = r;
    [self.layer addSublayer:self.yellowCircleLayer];
    CGFloat targetWidth = self.target.size.width ;
    CGRect frame = CGRectMake(self.yellowCircleLayer.bounds.size.width / 2 - targetWidth / 2 , self.yellowCircleLayer.bounds.size.width / 2 - targetWidth / 2  , targetWidth, targetWidth);
    UIView *blurMask = [[UIView alloc] initWithFrame:frame];
    blurMask.backgroundColor = [UIColor whiteColor];
    blurMask.layer.cornerRadius = blurMask.frame.size.width / 2;
    self.yellowCircleLayer.mask = blurMask.layer;
    [blurMask.layer addAnimation:[self noneToMinBorder] forKey:secondStepAnimation];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.lightColorLayer animationForKey:firstStepAnimation]){
        self.textView.hidden = NO;
        [self textViewAnimation];
        [self secondAnimation];
    }else if(anim == [self.yellowCircleLayer.mask animationForKey:thirdStepAnimation]){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(stopTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.endGuideAnimation){
                self.endGuideAnimation(FMEndAnimationType_End);
            }
        });
    }else if(anim == [self.yellowCircleLayer.mask animationForKey:secondStepAnimation]){
        CGFloat r1 = self.target.size.width / 2 + maxBorderWidth;
        [self.yellowCircleLayer.mask addAnimation:[self scaleGroups:(2 * r1 / self.yellowCircleLayer.mask.bounds.size.width) targetAlpha:0.4] forKey:thirdStepAnimation];
    }
}

- (void)removeAnimation
{
    [self.lightColorLayer removeAllAnimations];
    [self.darkColorLayer removeAllAnimations];
    [self.yellowCircleLayer.mask removeAllAnimations];
}

#pragma mark Layer Initializations
- (void)initAnimationSetting :(NSString *)text
{
    self.alpha = 1;
    self.lightColorLayer = [CALayer layer];
    //layer足够大缩小时也可盖住全屏
    CGFloat width = 2 * self.distance * self.distance / (self.target.size.width / 2);
    self.lightColorLayer.frame = [self layerFrame:width];
    self.lightColorLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor;
    
    self.darkColorLayer = [CALayer layer];
    CGFloat widthDark = width * 1.1;
    self.darkColorLayer.frame = [self layerFrame:widthDark];
    self.darkColorLayer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor;
    CGFloat r = self.target.size.width / 2;
    CGFloat textWidth = [self widthForText:text];
    CGFloat gap = 18;
    self.textView = [[UILabel alloc] initWithFrame:CGRectMake(self.target.origin.x - (r + maxBorderWidth + gap + textWidth) , self.target.origin.y - 16, 200, 32)];
    self.textView.textAlignment = NSTextAlignmentLeft;
    self.textView.textColor = [UIColor yellowColor];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.text = text;
    self.textView.hidden = YES;
    
    [self.layer addSublayer:self.lightColorLayer];
    [self.layer addSublayer:self.darkColorLayer];
    [self addSubview:self.textView];
}

#pragma mark Animation Creators
- (CAAnimationGroup *)noneToMinBorder
{
    CGFloat r1 = self.target.size.width / 2 + minBorderWidth;
    CGFloat duration = nontToMinTime;
    CABasicAnimation *scaleZoomIn = [self scaleAnimation: duration targetScale:r1 * 2 / self.yellowCircleLayer.mask.bounds.size.width beginTime:0];
    CABasicAnimation *alpha = [self alphaAnimation:duration targetAlpha:1.0 beginTime:0];
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:scaleZoomIn, alpha, nil];
    animGroup.duration = duration;
    animGroup.fillMode = kCAFillModeForwards;
    animGroup.removedOnCompletion = NO;
    animGroup.delegate = self;
    return animGroup;
}

- (CABasicAnimation *)scaleAnimation:(CGFloat)duration targetScale:(CGFloat)scale beginTime:(CGFloat)beginTime
{
    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnim.duration = duration;
    scaleAnim.beginTime = beginTime;
    scaleAnim.fillMode = kCAFillModeForwards;
    CGFloat a = scale;
    scaleAnim.delegate = self;
    scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(a ,a, 1.0)];
    scaleAnim.removedOnCompletion = NO;
    return scaleAnim;
}

- (CABasicAnimation *)alphaAnimation:(CGFloat)duration targetAlpha:(CGFloat)alpha beginTime:(CGFloat)beginTime
{
    CABasicAnimation *opacityAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnim.toValue = [NSNumber numberWithFloat:alpha];
    opacityAnim.removedOnCompletion = NO;
    opacityAnim.fillMode = kCAFillModeForwards;
    opacityAnim.duration = duration;
    [opacityAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    opacityAnim.beginTime = beginTime;
    opacityAnim.delegate = self;
    return opacityAnim;
}

- (CAAnimationGroup *)scaleGroups :(CGFloat)targetScale targetAlpha:(CGFloat)alpha
{
    CGFloat beginTime = 0;
    NSMutableArray *temp = [NSMutableArray new];
    for(int i = 0; i < 3; i++){
        CABasicAnimation *scaleZoomIn = [self scaleAnimation:zoomInTime targetScale:targetScale beginTime:beginTime];
        CABasicAnimation *zoomInAlpha = [self alphaAnimation:zoomInTime targetAlpha:0.4 beginTime:beginTime];
        beginTime += (zoomInTime + stopTime);
        CGFloat r1 = self.target.size.width / 2 + minBorderWidth;
        CGFloat scale = 2 * r1 / self.yellowCircleLayer.mask.bounds.size.width;
        CABasicAnimation *scaleZoomOut = [self scaleAnimation:zoomOutTime targetScale:scale beginTime:beginTime];
        CABasicAnimation *zoomOutAlpha = [self alphaAnimation:zoomOutTime targetAlpha:scale beginTime:beginTime];
        beginTime += (zoomOutTime + stopTime);
        [temp addObjectsFromArray:[NSArray arrayWithObjects:scaleZoomIn, zoomInAlpha, scaleZoomOut, zoomOutAlpha, nil]];
    }
    
    CABasicAnimation *scaleZoomIn = [self scaleAnimation:zoomInTime targetScale:targetScale beginTime:beginTime];
    CABasicAnimation *zoomInAlpha = [self alphaAnimation:zoomInTime targetAlpha:0.4 beginTime:beginTime];
    beginTime += zoomInTime;
    [temp addObjectsFromArray:[NSArray arrayWithObjects:scaleZoomIn, zoomInAlpha, nil]];
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [temp copy];
    animGroup.duration = beginTime;
    animGroup.fillMode = kCAFillModeForwards;
    animGroup.removedOnCompletion = NO;
    animGroup.delegate = self;
    return animGroup;
}

- (void)addMask:(CGFloat)radius inLayer:(CALayer *)alayer atLocation:(CGPoint)centre{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, alayer.bounds.size.width, alayer.bounds.size.height)];
    [path appendPath:[UIBezierPath bezierPathWithArcCenter:centre radius:radius startAngle:0 endAngle:2 * M_PI clockwise:NO]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    [alayer setMask:shapeLayer];
}

- (void)endBeginnerGuideAnimation
{
    if(self.endGuideAnimation){
        self.endGuideAnimation(FMEndAnimationType_Break);
    }
}

#pragma TextView Animation
-(void)textViewAnimation {
    self.textView.alpha = 0;
    [UIView animateWithDuration:0.9 animations:^{
        self.textView.frame = CGRectMake(self.textView.frame.origin.x + 12, self.textView.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height);
        self.textView.alpha = 0.585;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.02 animations:^{
            self.textView.alpha = 0.742;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.12 animations:^{
                self.textView.frame = CGRectMake(self.textView.frame.origin.x - 2, self.textView.frame.origin.y, self.textView.frame.size.width, self.textView.frame.size.height);
                self.textView.alpha = 1.0;
            } completion:^(BOOL finished) {
                //nothing
            }];
        }];
    }];
}

#pragma calculations
- (CGPoint)utmostPoint:(CGPoint)centrePoint{
    CGFloat midX = SCREEN_WIDTH / 2.0;
    CGFloat midY = SCREEN_HEIGHT / 2.0;
    CGFloat resultX = 0;
    CGFloat resultY = 0;
    CGFloat x = centrePoint.x;
    CGFloat y = centrePoint.y;
    resultX = (x <= midX) ? SCREEN_WIDTH : 0;
    resultY = (y <= midY) ? SCREEN_HEIGHT : 0;
    return CGPointMake(resultX, resultY);
}

- (CGRect)layerFrame:(CGFloat)width
{
    return CGRectMake(self.target.origin.x - width / 2, self.target.origin.y - width / 2, width, width);
}

- (CGFloat)distanceFrom:(CGPoint)a toPoint:(CGPoint)b{
    double result = pow((a.x - b.x), 2) + pow((a.y - b.y), 2);
    return sqrt(result);
}

- (CGFloat)widthForText:(NSString *)item
{
    CGRect rect = [item boundingRectWithSize:CGSizeMake(INT_MAX, 33)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}
                                     context:nil];
    
    return rect.size.width + 5;
}
@end
