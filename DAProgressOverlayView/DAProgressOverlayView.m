//
//  DAProgressOverlayView.m
//  DAProgressOverlayView
//
//  Created by Daria Kopaliani on 8/1/13.
//  Updated by Roman Truba
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "DAProgressOverlayView.h"

typedef enum {
    DAProgressOverlayViewStateWaiting = 0,
    DAProgressOverlayViewStateOperationInProgress = 1,
    DAProgressOverlayViewStateOperationFinished = 2
} DAProgressOverlayViewState;

@interface DAProgressOverlayView ()
@property (strong, nonatomic) CABasicAnimation *startAnimation;
@property (assign, nonatomic) CGFloat pendingProgress;
@end

@interface DAProgressOverlayLayer : CALayer
@property (assign, nonatomic) DAProgressOverlayViewState state;
@property (weak, nonatomic)   DAProgressOverlayView *view;
@property (assign, nonatomic) CGFloat innerRadiusRatio;
@property (assign, nonatomic) CGFloat outerRadiusRatio;
@property (nonatomic) float animationProgress;
@end

@implementation DAProgressOverlayLayer
@synthesize animationProgress = _animationProgress;
+ (BOOL)needsDisplayForKey:(NSString*)key {
    if ([key isEqualToString:@"animationProgress"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}
- (id) initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];
    if (self) {
        DAProgressOverlayLayer *dLayer = (DAProgressOverlayLayer *)layer;
        self.innerRadiusRatio = dLayer.innerRadiusRatio;
        self.outerRadiusRatio = dLayer.outerRadiusRatio;
        self.view             = dLayer.view;
        self.state            = dLayer.state;
        self.animationProgress = dLayer.animationProgress;
    }
    self.contentsScale = [UIScreen mainScreen].scale;
    return self;
}
-(instancetype)init {
    self = [super init];
    self.contentsScale = [UIScreen mainScreen].scale;
    return self;
}
-(void)setAnimationProgress:(float)animationProgress {
    _animationProgress = animationProgress;
}
-(void)setContentsScale:(CGFloat)contentsScale {
    [super setContentsScale:[UIScreen mainScreen].scale];
}
- (CGFloat)innerRadius
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat radius = MIN(width, height) / 2. * self.innerRadiusRatio;
    switch (self.state) {
        case DAProgressOverlayViewStateWaiting: return radius * self.animationProgress;
        case DAProgressOverlayViewStateOperationFinished: return radius + (MAX(width, height) / sqrtf(2.) - radius) * self.animationProgress;
        default: return radius;
    }
}

- (CGFloat)outerRadius
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat radius = MIN(width, height) / 2. * self.outerRadiusRatio;
    switch (self.state) {
        case DAProgressOverlayViewStateWaiting: return radius * self.animationProgress;
        case DAProgressOverlayViewStateOperationFinished: return radius + (MAX(width, height) / sqrtf(2.) - radius) * self.animationProgress;
        default: return radius;
    }
}
-(void)drawInContext:(CGContextRef)context {
    if (fabs(self.contentsScale - [UIScreen mainScreen].scale) > 0.001) {
        self.contentsScale = [UIScreen mainScreen].scale;
    }
    [super drawInContext:context];
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat outerRadius = [self outerRadius];
    CGFloat innerRadius = [self innerRadius];
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, width / 2., height / 2.);
    CGContextScaleCTM(context, 1., -1.);
    CGContextSetRGBFillColor(context, 0., 0., 0., 0.5);
    CGContextSetFillColorWithColor(context, self.view.overlayColor.CGColor);
    
    CGMutablePathRef path0 = CGPathCreateMutable();
    CGPathMoveToPoint(path0, NULL, width / 2., 0.);
    CGPathAddLineToPoint(path0, NULL, width / 2., height / 2.);
    CGPathAddLineToPoint(path0, NULL, -width / 2., height / 2.);
    CGPathAddLineToPoint(path0, NULL, -width / 2., 0.);
    CGPathAddLineToPoint(path0, NULL, (cosf(M_PI) * outerRadius), 0.);
    CGPathAddArc(path0, NULL, 0., 0., outerRadius, M_PI, 0., 1.);
    CGPathAddLineToPoint(path0, NULL, width / 2., 0.);
    CGPathCloseSubpath(path0);
    
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGAffineTransform rotation = CGAffineTransformMakeScale(1., -1.);
    CGPathAddPath(path1, &rotation, path0);
    
    CGContextAddPath(context, path0);
    CGContextFillPath(context);
    CGPathRelease(path0);
    
    CGContextAddPath(context, path1);
    CGContextFillPath(context);
    CGPathRelease(path1);
    
    if (self.view.progress < 1.) {
        CGFloat angle = 360. - (360. * self.view.progress);
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
        CGMutablePathRef path2      = CGPathCreateMutable();
        CGPathMoveToPoint(path2, &transform, innerRadius, 0.);
        CGPathAddArc(path2, &transform, 0., 0., innerRadius, 0., angle / 180. * M_PI, 0.);
        CGPathAddLineToPoint(path2, &transform, 0., 0.);
        CGPathAddLineToPoint(path2, &transform, innerRadius, 0.);
        CGContextAddPath(context, path2);
        CGContextFillPath(context);
        CGPathRelease(path2);
    }
    CGContextRestoreGState(context);
}
@end

@implementation DAProgressOverlayView

+(Class)layerClass {
    return [DAProgressOverlayLayer class];
}
-(DAProgressOverlayLayer*) dlayer {
    DAProgressOverlayLayer *layer = (DAProgressOverlayLayer*)self.layer;
    layer.view = self;
    return layer;
}
#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp
{
    self.backgroundColor = [UIColor clearColor];
    self.progress = 0.;
    self.outerRadiusRatio = 0.7;
    self.innerRadiusRatio = 0.6;
    self.overlayColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.5];
    self.dlayer.animationProgress = 0.;
    self.triggersDownloadDidFinishAnimationAutomatically = YES;
}
#pragma mark - Public

- (CABasicAnimation *) makeProgressAnimation:(CGFloat) duration {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"animationProgress"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.duration  = duration;
    animation.fromValue = @(0);
    animation.toValue   = @(1);
    animation.delegate  = self;
    [self.layer addAnimation:animation forKey:@"makeAnimationFinish"];
    return animation;
}

- (void)displayOperationDidFinishAnimation
{
    self.dlayer.state = DAProgressOverlayViewStateOperationFinished;
    [self makeProgressAnimation:self.finishAnimationDuration];
    self.dlayer.animationProgress = 1.0f; //For successfull drawing animation finish
}

- (void)displayOperationWillTriggerAnimation
{
    self.dlayer.state   = DAProgressOverlayViewStateWaiting;
    self.startAnimation = [self makeProgressAnimation:self.beginAnimationDuration];
    self.dlayer.animationProgress = 1.0f; //For successfull drawing animation finish
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) return;
    if (self.startAnimation) {
        self.startAnimation = nil;
        self.progress = _pendingProgress;
        if (self.animationCompletionHandler) {
            self.animationCompletionHandler(DAProgressOverlayAnimationBegin);
        }
    } else if (self.animationCompletionHandler) {
        self.animationCompletionHandler(DAProgressOverlayAnimationFinish);
        [self removeFromSuperview];
    }
}

#pragma mark * Overwritten methods

- (void)setInnerRadiusRatio:(CGFloat)innerRadiusRatio
{
    self.dlayer.innerRadiusRatio = _innerRadiusRatio = (innerRadiusRatio < 0.) ? 0. : (innerRadiusRatio > 1.) ? 1. : innerRadiusRatio;
}

- (void)setOuterRadiusRatio:(CGFloat)outerRadiusRatio
{
    self.dlayer.outerRadiusRatio = _outerRadiusRatio = (outerRadiusRatio < 0.) ? 0. : (outerRadiusRatio > 1.) ? 1. : outerRadiusRatio;
}

- (void)setProgress:(CGFloat)progress
{
    if (self.startAnimation) {
        _pendingProgress = progress;
        return;
    }
    if (_progress != progress) {
        _progress = (progress < 0.) ? 0. : (progress > 1.) ? 1. : progress;
        if (progress > 0. && progress < 1.) {
            self.dlayer.state = DAProgressOverlayViewStateOperationInProgress;
            [self.layer setNeedsDisplayInRect:self.frame];
        } else if (progress == 1. && self.triggersDownloadDidFinishAnimationAutomatically) {
            [self displayOperationDidFinishAnimation];
        }
    }
}

-(CGFloat)beginAnimationDuration {
    return 1.f / 3.f;
}
-(CGFloat)finishAnimationDuration {
    return .4f;
}

@end