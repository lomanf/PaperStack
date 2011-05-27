//
//  PSPageView.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 25/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSPageView.h"
#import "UIImage+Scale.h"
#import <QuartzCore/QuartzCore.h>

CGMutablePathRef PSCreatePagePath( CGRect rect, CGFloat padding, CGFloat span ) {
    CGFloat radius = rect.size.height * 0.05;
    CGFloat sp = radius * 0.25;
    CGFloat dpadding = span;
    CGFloat ox = rect.origin.x;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint( path, NULL, 0.0, sp + padding );
    CGPathAddQuadCurveToPoint( path, NULL, ox, 0.0 + padding, radius + padding, 0.0 + padding );
    CGPathAddLineToPoint( path, NULL, rect.size.width - dpadding, 0.0 + padding );
    CGPathAddLineToPoint( path, NULL, rect.size.width - dpadding, rect.size.height - padding );
    CGPathAddLineToPoint( path, NULL, radius + padding, rect.size.height - padding );
    CGPathAddQuadCurveToPoint( path, NULL, ox, rect.size.height - padding, ox, rect.size.height - sp - padding );
    CGPathAddLineToPoint( path, NULL, ox, sp + padding );
    return path;
}

CGMutablePathRef PSCreatePageSquarePath( CGRect rect, CGFloat padding, CGFloat span ) {
    CGFloat dpadding = span;
    CGFloat ox = rect.origin.x;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint( path, NULL, ox, padding );
    CGPathAddLineToPoint( path, NULL, rect.size.width - dpadding, 0.0 + padding );
    CGPathAddLineToPoint( path, NULL, rect.size.width - dpadding, rect.size.height - padding );
    CGPathAddLineToPoint( path, NULL, ox, rect.size.height - padding );
    CGPathAddLineToPoint( path, NULL, ox, padding );
    return path;
}

@interface PSPageView()

@property (nonatomic, assign) BOOL skipAnimation;
@property (nonatomic, assign) CGFloat flipTargetValue;
@property (nonatomic, assign) CGFloat flipCurrentValue;
@property (nonatomic, assign) UIView *pageFlip;
@property (nonatomic, assign) CAGradientLayer *pageDark;

@end

@implementation PSPageView

@synthesize isLandscape, skipAnimation, pageContent, flipTargetValue, flipCurrentValue, pageFlip, pageDark, flipped;

static CATransform3D kFaceUpTransform, kFaceDownTransform, kFacePerspectiveTransform;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        self.clipsToBounds = NO;
        
        kFaceUpTransform = kFaceDownTransform = CATransform3DIdentity;
        kFaceDownTransform.m11 = kFaceDownTransform.m33 = -1;
        
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -2000;
        kFacePerspectiveTransform = transform;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [[UIImage imageNamed:@"cover.png"] drawInRect:rect];
    
    CGFloat pad = rect.size.width * 0.015;
    CGFloat side = rect.size.width * 0.04;
    
    CGMutablePathRef page1 = PSCreatePageSquarePath( rect, pad, side+pad );
    CGMutablePathRef page2 = PSCreatePageSquarePath( rect, pad*1.3, side*.78+pad );
    CGMutablePathRef page3 = PSCreatePageSquarePath( rect, pad*1.7, side*.58+pad );
    CGMutablePathRef page4 = PSCreatePageSquarePath( rect, pad*2.1, side*.43+pad );
    CGMutablePathRef page5 = PSCreatePageSquarePath( rect, pad*2.5, side*.30+pad );
    CGMutablePathRef page6 = PSCreatePageSquarePath( rect, pad*2.9, side*.20+pad );
    
    CGColorRef alphaBlack = [[UIColor blackColor] colorWithAlphaComponent:0.15].CGColor;
    CGColorRef alphaShadow = [[UIColor blackColor] colorWithAlphaComponent:0.40].CGColor;
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor( context, alphaBlack);
	CGContextSetLineWidth( context, 1.0 );
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetShadowWithColor( context, CGSizeMake( 1.5, 0 ), 2.0, alphaShadow );
    
    // fill & stroke
    
    CGContextSaveGState( context );
    
    CGContextAddPath( context, page6 );
    CGContextFillPath( context );
    CGContextAddPath( context, page6 );
    CGContextStrokePath( context );
    
    CGContextAddPath( context, page5 );
    CGContextFillPath( context );
    CGContextAddPath( context, page5 );
    CGContextStrokePath( context );
    
    CGContextAddPath( context, page4 );
    CGContextFillPath( context );
    CGContextAddPath( context, page4 );
    CGContextStrokePath( context );
    
    CGContextAddPath( context, page3 );
    CGContextFillPath( context );
    CGContextAddPath( context, page3 );
    CGContextStrokePath( context );
    
    CGContextAddPath( context, page2 );
    CGContextFillPath( context );
    CGContextAddPath( context, page2 );
    CGContextStrokePath( context );
    
    CGContextAddPath( context, page1 );
    CGContextFillPath( context );
    CGContextAddPath( context, page1 );
    CGContextStrokePath( context );
    
    CGContextRestoreGState( context );
    
}

- (void)layoutSubviews
{    
    CGFloat pad = self.frame.size.width * 0.015;
    CGFloat side = self.frame.size.width * 0.04;
    
    CGRect rect = self.bounds;
    CGMutablePathRef pagePath = PSCreatePageSquarePath( rect, pad+1, side+pad+1 );
        
    CGRect pageFrame = CGPathGetBoundingBox( pagePath );        
    //pageFrame.origin.x += 1;
    
    if ( self.pageContent != nil ) {
        self.pageContent.frame = pageFrame;
    } else {
        UIImageView *page = [[UIImageView alloc] initWithFrame:pageFrame];
        page.contentMode = UIViewContentModeScaleAspectFit;
        page.backgroundColor = [UIColor clearColor];
        page.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        [self addSubview:page];
        self.pageContent = page;
        [self pageWillRotate];
        [self performSelector:@selector(pageDidRotate) withObject:nil afterDelay:1.5];
        
        CGRect sf = pageFrame;
        CAGradientLayer *dark = [CAGradientLayer layer];
        dark.anchorPoint = CGPointMake( 0, 0.5 );
        dark.startPoint = CGPointMake(0, 0.5);
        dark.endPoint = CGPointMake(1.0, 0.5);
        dark.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor clearColor] CGColor],
                            (id)[[[UIColor blackColor] colorWithAlphaComponent:0.4] CGColor],
                            (id)[[[UIColor blackColor] colorWithAlphaComponent:0.4] CGColor],
                            (id)[[UIColor clearColor] CGColor],
                            nil];
        dark.frame = sf;
        dark.shouldRasterize = YES;
        [self.layer addSublayer:dark];
        self.pageDark = dark;
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        self.pageDark.hidden = YES;
        [CATransaction commit];
    }
}

- (void)pageWillRotate 
{
    self.pageContent.hidden = YES; 
}

- (void)pageDidRotate 
{
    self.pageContent.hidden = NO; 
    
    UIImage *tim = nil; 
    if ( flipped ) {
        tim = [UIImage imageWithCGImage:[UIImage imageNamed:@"page.png"].CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
    } else {
        tim = [UIImage imageNamed:@"page.png"];
    }
    
    self.pageContent.image = tim;
}


- (void)pageFlipStartWithTarget:(CGFloat)value
{
    if ( self.pageFlip != nil ) {
        return;
    }
    skipAnimation = NO;
    self.flipTargetValue = value;
    self.flipCurrentValue = 0;
        
    UIImage *tim = nil; 
    UIImage *bim = nil; 
    if ( self.flipped ) {
        tim = [UIImage imageWithCGImage:[UIImage imageNamed:@"page.png"].CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
        bim = [UIImage imageWithCGImage:[UIImage imageNamed:@"page.png"].CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
    } else {
        tim = [UIImage imageNamed:@"page.png"];
        bim = [UIImage imageNamed:@"page.png"];
    }
	UIView *view = [[UIView alloc] initWithFrame:self.pageContent.frame];
    view.backgroundColor = [UIColor clearColor];
    view.layer.anchorPoint = CGPointMake( 0, 0.5 );
    view.layer.doubleSided = YES;
    view.layer.edgeAntialiasingMask = 0;
    view.layer.sublayerTransform = kFacePerspectiveTransform;
    view.frame = self.pageContent.frame;
    
    // back layer
    CALayer *back = [CALayer layer];
    back.contents = (id)bim.CGImage;
    back.backgroundColor = [UIColor whiteColor].CGColor;
    back.frame = view.bounds;
    back.contentsGravity = kCAGravityResizeAspect;
    back.doubleSided = YES;
    back.edgeAntialiasingMask = 0;
    if ( !self.flipped ) {
        back.transform = kFaceDownTransform;
    }
    [view.layer addSublayer:back];
    
    // front layer
    CALayer *front = [CALayer layer];
    front.backgroundColor = [UIColor whiteColor].CGColor;
    front.contents = (id)tim.CGImage;
    front.frame = view.bounds;
    front.contentsGravity = kCAGravityResizeAspect;
    front.doubleSided = NO;
    front.edgeAntialiasingMask = 0;
    front.zPosition = 1;
    if ( self.flipped ) {
        front.transform = kFaceDownTransform;
        front.doubleSided = YES;
    }
    [view.layer addSublayer:front];
    
    [self addSubview:view];
    self.pageFlip = view;
    [view release];
    
    [self bringSubviewToFront:self.pageFlip];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    CGRect pageFrame = self.pageContent.frame;
    if ( !isLandscape ) {
        pageFrame.size.width *= 3.0;
    }
    self.pageDark.frame = pageFrame;
    self.pageDark.hidden = NO;
    [CATransaction commit];
    
}

- (void)pageFlipEnd
{
    if ( skipAnimation ) {
        return;
    }
    skipAnimation = YES;
    CGFloat tv = 0.0;
    if ( fabs( flipCurrentValue ) >= fabs( flipTargetValue * 0.33 ) ||
         fabs( flipCurrentValue ) <= fabs( flipTargetValue * 0.05 ) ) {
        tv = flipTargetValue;
    }
    
    CGFloat ang = fabsf( tv ) /fabs( flipTargetValue );
    CGFloat ang2 = fabsf( flipCurrentValue ) / fabs( flipTargetValue );
    
    [self bringSubviewToFront:self.pageFlip];
    self.pageFlip.layer.sublayerTransform = CATransform3DConcat( CATransform3DMakeRotation( 0, 0, 1, 0 ), kFacePerspectiveTransform );
    
    //Rotation Animation:
    CABasicAnimation *rota = [CABasicAnimation animationWithKeyPath:@"sublayerTransform.rotation.y"];
    rota.duration = 0.5 * fabsf( flipCurrentValue - tv );
    rota.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    if ( rota.duration > 0.6 ) {
        if ( fabs( tv ) <= M_PI * 0.5 * 1.05 && fabs( tv ) > M_PI * 0.5 * 0.95 ) {
            rota.duration = 0.35;
            rota.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        }
        if ( fabs( tv ) <= M_PI * 1.05 && fabs( tv ) > M_PI * 0.95 ) {
            rota.duration = 0.6;
            rota.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        }
    }
    if ( rota.duration < 0.4 ) {
        rota.duration = 0.4;
    }
    
    rota.removedOnCompletion = NO;
    rota.fillMode = kCAFillModeBoth;
    rota.fromValue = [NSNumber numberWithFloat:flipCurrentValue];
    rota.toValue = [NSNumber numberWithFloat:tv];
    rota.delegate = self;
    [self.pageFlip.layer addAnimation:rota forKey: @"rotation"];
    self.flipCurrentValue = 0;
    
    // move shadow
    CGRect rect = pageDark.frame;
    rect.origin.x = -pageDark.frame.size.width * ang2;
    [CATransaction begin];
    [CATransaction setAnimationDuration:rota.duration];
    [CATransaction setValue:(id)kCFBooleanFalse
                     forKey:kCATransactionDisableActions];
    rect.origin.x = -pageDark.frame.size.width * ang;
    self.pageDark.frame = rect;
    [CATransaction commit];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    self.pageDark.hidden = YES;
    [CATransaction commit];
    skipAnimation = NO;
    [self.pageFlip.layer removeAllAnimations];
    [self.pageFlip removeFromSuperview];
    self.pageFlip = nil;
}

- (void)pageFlipTo:(CGFloat)value 
{
    if ( skipAnimation ) {
        return;
    }   
    if ( fabsf( value - self.flipCurrentValue ) > M_PI * 0.3 ) {
        [self pageFlipEnd];
        return;
    }
    CGFloat ang = fabsf( value ) / fabs( flipTargetValue );
    
    self.flipCurrentValue = value;
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.07];
    self.pageFlip.layer.sublayerTransform = CATransform3DConcat( CATransform3DMakeRotation( value, 0, 1, 0 ), kFacePerspectiveTransform );
    CGRect rect = pageDark.frame;
    rect.origin.x = -pageDark.frame.size.width * ang;
    self.pageDark.frame = rect;
    [CATransaction commit];
    
    // shadow
    CGFloat shadowAmount = 0.0;
    if ( ang < 0.5 ) {
        shadowAmount = ang;
    } else {
        shadowAmount = 0.5 - ( ang - 0.5 );
    }
    [self bringSubviewToFront:self.pageFlip];
}

- (void)dealloc
{
    [super dealloc];
}

@end
