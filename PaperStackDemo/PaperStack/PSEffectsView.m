//
//  PSEffectsView.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 09/06/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSEffectsView.h"
#import <QuartzCore/QuartzCore.h>

#define kPSEffectsViewScaleFactor           1.0
#define kPSEffectsViewScaleFactorInv        1/kPSEffectsViewScaleFactor


@interface PSEffectsView()

@property (nonatomic, assign) CGPathRef curlPath;
@property (nonatomic, assign) CGPathRef shadowPath;
@property (nonatomic, assign) CGFloat angleValue;
@property (nonatomic, assign) CGFloat thetaValue;
@property (nonatomic, assign) CGFloat radiusValue;
@property (nonatomic, assign) CGFloat timeValue;
@property (nonatomic, assign) CGPoint pointValue;
@property (nonatomic, retain) CAGradientLayer *shaderLayer;
@property (nonatomic, retain) CAShapeLayer *shaderMaskLayer;

- (void)drawEffects;

@end

@implementation PSEffectsView

@synthesize curlPath, shadowPath, angleValue, pointValue, timeValue, radiusValue, thetaValue;
@synthesize shaderLayer, shaderMaskLayer;

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectApplyAffineTransform( frame, CGAffineTransformMakeScale( kPSEffectsViewScaleFactor, kPSEffectsViewScaleFactor ) );
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.userInteractionEnabled = NO;
                        
        // create shader        
        CAGradientLayer *aGradient = [CAGradientLayer layer];
        aGradient.frame = self.bounds;
        aGradient.colors = [NSArray arrayWithObjects:
                            (id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor],
                            (id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor],
                            (id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor],
                            (id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor],
                            (id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor],
                            (id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor],
                            (id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor],
                            (id)[[[UIColor whiteColor] colorWithAlphaComponent:0.1] CGColor],
                            (id)[[[UIColor grayColor] colorWithAlphaComponent:0.2] CGColor],
                            (id)[[[UIColor whiteColor] colorWithAlphaComponent:0.6] CGColor],
                            (id)[[UIColor clearColor] CGColor],
                            nil];
        aGradient.startPoint = CGPointMake(0.6,0.5);
        aGradient.endPoint = CGPointMake(0.4,0.5);
        [self.layer addSublayer:aGradient];
        self.shaderLayer = aGradient;
        
        CAShapeLayer *aShape = [CAShapeLayer layer];
        aShape.fillColor = [UIColor blackColor].CGColor;
        
        self.shaderLayer.mask = aShape;
        self.shaderMaskLayer = aShape;
    }
    return self;
}

- (void)drawEffects
{
    [CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
    
    //shaderLayer.frame = frame;
      
//    CGMutablePathRef absolute = CGPathCreateMutable();
//    CGAffineTransform translate = CGAffineTransformMakeTranslation(-frame.origin.x, -frame.origin.y);
//    CGPathAddPath( absolute, &translate, curlPath);
    //shaderMaskLayer.position = CGPointMake(frame.origin.x, frame.origin.y);
    
    shaderLayer.startPoint = CGPointMake( pointValue.x+radiusValue*0.11*cos(angleValue-thetaValue), pointValue.y+radiusValue*0.11*sin(angleValue-thetaValue) );
    shaderLayer.endPoint = CGPointMake( pointValue.x+radiusValue*1.1*cos(angleValue-thetaValue), pointValue.y+radiusValue*1.1*sin(angleValue-thetaValue) );
    
    shaderMaskLayer.path = curlPath;
    
    [CATransaction commit];
}

- (void)updateCurlPath:(CGPathRef)path withShadow:(CGPathRef)shadow time:(CGFloat)time angle:(CGFloat)angle point:(CGPoint)point theta:(CGFloat)theta
{
    CGAffineTransform transformScale = CGAffineTransformMakeScale(kPSEffectsViewScaleFactor, kPSEffectsViewScaleFactor);
//    CGAffineTransform transformTranslateAndScale = CGAffineTransformConcat( transformScale, CGAffineTransformMakeTranslation(10.0*cos(angle), 10.0*sin(angle)) );
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGMutablePathRef path2 = CGPathCreateMutable();
    CGPathAddPath( path1, &transformScale, path);
    CGPathAddPath( path2, &transformScale, shadow);
    self.curlPath = path1;
    self.shadowPath = path2;    
    self.angleValue = angle;
    self.pointValue = CGPointMake( point.x + 0.5, -point.y + 0.5 );
    self.timeValue = time;
    self.radiusValue = time / M_PI;
    [self drawEffects];
}

- (void)dealloc
{
    [super dealloc];
}

@end
