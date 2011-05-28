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
#import "PSDrawings.h"
#import "PSKonstants.h"
#import "PSPageCache.h"

@interface PSPageView()

@property (nonatomic, assign) PSPageCache *pageCache;
@property (nonatomic, assign) BOOL landscapeMode;
@property (nonatomic, assign) UIImageView *pageContent;
@property (nonatomic, assign) CGFloat flipTargetValue;
@property (nonatomic, assign) CGFloat flipCurrentValue;

@end

@implementation PSPageView

@synthesize flipped;
@synthesize pageCache, landscapeMode, pageContent;
@synthesize flipTargetValue, flipCurrentValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.opaque = YES;
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [[UIImage imageNamed:@"cover.png"] drawInRect:rect];
    
    CGFloat pad = rect.size.width * kPSPagePaddingRatio;
    CGFloat side = rect.size.width * kPSPageSideRatio;
    
    CGMutablePathRef page1 = PSCreatePagePath( rect, pad, side+pad );
    CGMutablePathRef page2 = PSCreatePagePath( rect, pad*1.3, side*.78+pad );
    CGMutablePathRef page3 = PSCreatePagePath( rect, pad*1.7, side*.58+pad );
    CGMutablePathRef page4 = PSCreatePagePath( rect, pad*2.1, side*.43+pad );
    CGMutablePathRef page5 = PSCreatePagePath( rect, pad*2.5, side*.30+pad );
    CGMutablePathRef page6 = PSCreatePagePath( rect, pad*2.9, side*.20+pad );
    
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
    
    [pageCache setNeedsDisplay];
}

- (void)setFlippedFlag
{
    self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.transform = CGAffineTransformMakeScale( -1, 1);
    self.flipped = YES;
}

- (void)layoutSubviews
{    
    CGRect rect = self.bounds;
    rect.origin.y = -rect.size.height;
    
    if ( self.pageCache == nil ) {
        PSPageCache *pc = [[PSPageCache alloc] initWithFrame:rect];
        [self addSubview:pc];
        
        self.pageCache = pc;
                
        [pc release];
    } else {
        self.pageCache.frame = rect;
    }
}

- (void)pageWillRotateToOrientation:(UIDeviceOrientation)orientation 
{
    self.landscapeMode = UIDeviceOrientationIsLandscape( orientation );
    if ( self.pageContent != nil ) {
        [self.pageContent removeFromSuperview];
        self.pageContent = nil;
    }
}

- (void)pageDidRotate 
{
    UIImage *img;
    
    if ( flipped ) {
        img = [UIImage imageWithCGImage:[UIImage imageNamed:@"page.png"].CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];
    } else {
        img = [UIImage imageNamed:@"page.png"];
    }
    
    UIImage *imageTotal = [pageCache pageCacheWithImage:img];
    UIImageView *iv = [[UIImageView alloc] initWithImage:imageTotal];
    [self addSubview:iv];
    
    self.pageContent = iv;
    
    [iv release];
}

#pragma mark -
#pragma Texture management

- (UIImage*)textureData
{
    return [self.pageCache textureData];
}

- (CGRect)textureRect
{
    return [self.pageCache textureRect];
}

#pragma mark -
#pragma mark Page Flip handlers

- (void)pageFlipStartWithTarget:(CGFloat)value
{

    
}

- (void)pageFlipEnd
{
    
}

- (void)pageFlipTo:(CGFloat)value 
{

}

#pragma mark -
#pragma mark CALayer Animation delegte

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
}

- (void)dealloc
{
    [super dealloc];
}

@end
