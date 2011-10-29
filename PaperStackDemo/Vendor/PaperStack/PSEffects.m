//
//  PSEffectsView.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 09/06/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSEffects.h"
#import <QuartzCore/QuartzCore.h>
#import "PSDrawings.h"

@interface PSEffects()

@property (nonatomic, assign) CGFloat angleValue;
@property (nonatomic, assign) CGFloat thetaValue;
@property (nonatomic, assign) CGFloat radiusValue;
@property (nonatomic, assign) CGFloat timeValue;
@property (nonatomic, assign) CGPoint pointValue;

@end

@implementation PSEffects

@synthesize bounds, pageRect, pageSize, shaderImage, innerShadowImage;
@synthesize angleValue, pointValue, timeValue, radiusValue, thetaValue;

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
    size.width = 128;
    size.height = 128;
    
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
    
    self.shaderImage = newImage;
    
    CGImageRelease( img );
    UIGraphicsEndImageContext();
    
    // draw inner shadow
    CGRect rect = self.pageRect;
    CGFloat ratio;
    rect.origin.y = round( rect.origin.y );
    rect.size.height = round( rect.size.height );
    
    UIGraphicsBeginImageContext( pageSize );
    context = UIGraphicsGetCurrentContext();
    
    UIImage *shadow_top = [UIImage imageNamed:@"shadow_tb.png"];
    UIImage *shadow_bottom = [UIImage imageNamed:@"shadow_bb.png"];
    UIImage *shadow_stretch = [UIImage imageNamed:@"shadow_m.png"];
    
    CGRect rtop = rect;
    ratio = shadow_top.size.width / rect.size.width;
    rtop.size.height = round( shadow_top.size.height / ratio );
    
    CGRect rmid = rect;
    rmid.origin.y = rtop.origin.y + rtop.size.height;
    rmid.size.height = rmid.size.height - rtop.size.height * 2;
    
    CGRect rbot = rect;
    rbot.origin.y = rmid.origin.y + rmid.size.height;
    rbot.size.height = round( shadow_bottom.size.height / ratio );
    
    CGContextDrawImage( context, rtop, shadow_bottom.CGImage );
    CGContextDrawImage( context, rbot, shadow_top.CGImage );
    CGContextDrawImage( context, rmid, shadow_stretch.CGImage );
     
    img = CGBitmapContextCreateImage( context );
    newImage = [UIImage imageWithCGImage:img];
    
    self.innerShadowImage = newImage;
    
    CGImageRelease( img );
    UIGraphicsEndImageContext();
}

- (void)updateCurlTime:(CGFloat)time angle:(CGFloat)angle point:(CGPoint)point theta:(CGFloat)theta
{
    self.angleValue = angle;
    self.pointValue = CGPointMake( point.x + 0.5, 1-fabs(-point.y+0.5));
    self.timeValue = time;
    self.radiusValue = time / M_PI;
}

- (const Vertex2f *)shaderVertices
{
    CGFloat angle = angleValue-thetaValue;
    CGFloat sinangle = sinf(angle);
    CGFloat cosangle = cosf(angle);
    CGPoint pv = pointValue;
    CGPoint pv1 = CGPointMake( (pv.x-2*sinangle)-0.5, pv.y-2*cosf(angle)-0.5);
    CGPoint pv2 = CGPointMake( pv1.x+radiusValue*cosangle, pv1.y-radiusValue*sinangle );
    CGPoint pv3 = CGPointMake( (pv.x+2*sinangle)-0.5, (pv.y+2*cosangle)-0.5 );
    CGPoint pv4 = CGPointMake( pv3.x+radiusValue*cosangle, pv3.y-radiusValue*sinangle);
    
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
    [shaderImage release];
    [super dealloc];
}

@end
