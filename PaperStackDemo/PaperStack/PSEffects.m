//
//  PSEffectsView.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 09/06/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSEffects.h"
#import <QuartzCore/QuartzCore.h>

@interface PSEffects()

@property (nonatomic, assign) CGPathRef curlPath;
@property (nonatomic, assign) CGPathRef shadowPath;
@property (nonatomic, assign) CGFloat angleValue;
@property (nonatomic, assign) CGFloat thetaValue;
@property (nonatomic, assign) CGFloat radiusValue;
@property (nonatomic, assign) CGFloat timeValue;
@property (nonatomic, assign) CGPoint pointValue;

@end

@implementation PSEffects

@synthesize bounds, renderImage;
@synthesize curlPath, shadowPath, angleValue, pointValue, timeValue, radiusValue, thetaValue;

- (id)init
{
    self = [super init];
    if (self) {
        // init
    }
    return self;
}

- (void)buildEffects
{    
    CGSize size = bounds.size;
    size.width = 1024;
    size.height = 1024;
    
    UIGraphicsBeginImageContext( size );
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint startPoint = CGPointMake( 0.0, 0.0 );
    CGPoint endPoint = CGPointMake( size.width, 0 );
        
    CGColorSpaceRef colorSpace  = CGColorSpaceCreateDeviceRGB();
    
    CGFloat components [16] = {
        1.0, 1.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 0.055,
        0.9, 0.9, 0.9, 0.15,
        0.0, 0.0, 0.0, 0.05,
    };
    
    CGFloat locations[4] = {0.35, 0.82, 0.95, 1.0};
    
    CGGradientRef gradient =
    CGGradientCreateWithColorComponents(colorSpace,
                                        components,
                                        locations,
                                        (size_t)4);
    CGContextDrawLinearGradient(context,
                                gradient,
                                startPoint,
                                endPoint,
                                (CGGradientDrawingOptions)NULL);
    CGColorSpaceRelease(colorSpace);

    CGImageRef img = CGBitmapContextCreateImage( context );
    UIImage *newImage = [UIImage imageWithCGImage:img];
    
    self.renderImage = newImage;
    
    CGImageRelease( img );
    UIGraphicsEndImageContext();
}

- (void)updateCurlPath:(CGPathRef)path withShadow:(CGPathRef)shadow time:(CGFloat)time angle:(CGFloat)angle point:(CGPoint)point theta:(CGFloat)theta
{
    self.curlPath = path;
    self.shadowPath = shadow;    
    self.angleValue = angle;
    self.pointValue = CGPointMake( point.x + 0.5, 1-fabs(-point.y+0.5));
    self.timeValue = time;
    self.radiusValue = time / M_PI;
}

- (const Vertex2f *)shaderVertices
{
    CGFloat angle = angleValue-thetaValue;
    CGPoint pv = pointValue;
    CGPoint pv1 = CGPointMake( (pv.x-pv.y*sinf(angle))-0.5, pv.y-pv.y*cosf(angle)-0.5);
    CGPoint pv2 = CGPointMake( pv1.x+radiusValue*cosf(angle), pv1.y-radiusValue*sinf(angle) );
    CGPoint pv3 = CGPointMake( (pv.x+(1-pv.y)*sinf(angle))-0.5, (pv.y+(1-pv.y)*cosf(angle))-0.5 );
    CGPoint pv4 = CGPointMake( pv3.x+radiusValue*cosf(angle), pv3.y-radiusValue*sinf(angle));
    
    if (shaderVertices_ != NULL)
        free(shaderVertices_);
    shaderVertices_ = malloc(sizeof(Vertex2f)*4);
    shaderVertices_[0] = Vertex2fMake(pv1.x, pv1.y);
    shaderVertices_[1] = Vertex2fMake(pv2.x, pv2.y);
    shaderVertices_[2] = Vertex2fMake(pv3.x, pv3.y);
    shaderVertices_[3] = Vertex2fMake(pv4.x, pv4.y);
    return shaderVertices_;
}

- (const Vertex2f *)shaderCoords
{
    
    if (shaderCoords_ != NULL)
        free(shaderCoords_);
    shaderCoords_ = malloc(sizeof(Vertex2f)*4);
    shaderCoords_[0] = Vertex2fMake(0, 0);
    shaderCoords_[1] = Vertex2fMake(1, 0);
    shaderCoords_[2] = Vertex2fMake(0, 1);
    shaderCoords_[3] = Vertex2fMake(1, 1);
    return shaderCoords_;
}

- (void)dealloc
{
    [renderImage release];
    [super dealloc];
}

@end
