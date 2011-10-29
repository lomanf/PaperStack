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

#define kPSSkinBookBaseLandscape             @"kPSSkinBookBase~Landscape"
#define kPSSkinBookBasePortrait              @"kPSSkinBookBase~Portrait"

@interface PSPageView()

@property (nonatomic, assign) PSPageCache *pageCache;
@property (nonatomic, assign) BOOL landscapeMode;
@property (nonatomic, retain) UIImage *backgroundLandscape;
@property (nonatomic, retain) UIImage *backgroundPortrait;
@property (nonatomic, assign) UIImageView *pageBackground;
@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, assign) UIView *pageContent;
@property (nonatomic, assign) CGFloat flipTargetValue;
@property (nonatomic, assign) CGFloat flipCurrentValue;

- (UIImage*)drawBackground;
- (void)loadPageContent;
- (void)adjustBackground;

@end

@implementation PSPageView

@synthesize datasource, delegate;
@synthesize flipped, properties;
@synthesize backgroundLandscape, backgroundPortrait;
@synthesize pageCache, landscapeMode, pageContent, pageBackground, contentView;
@synthesize flipTargetValue, flipCurrentValue;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        self.opaque = YES;
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        // content view
        UIView *cView = [[UIView alloc] initWithFrame:self.bounds];
        cView.backgroundColor = [UIColor yellowColor];
        [self addSubview:cView];
        self.contentView = cView;
        [cView release];
    }
    return self;
}


#pragma mark - Private

- (UIImage*)drawBackground
{
    CGRect rect = self.bounds;

    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // draw bg
    UIImage *bg = nil;
    if ( self.landscapeMode ) {
        bg = [UIImage imageNamed:[properties objectForKey:kPSSkinBookBaseLandscape]];
    } else {
        bg = [UIImage imageNamed:[properties objectForKey:kPSSkinBookBasePortrait]];
    }
    
    CGContextDrawImage( context, rect, bg.CGImage );
    
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
    
	CGContextSetStrokeColorWithColor( context, alphaBlack);
	CGContextSetLineWidth( context, 1.0 );
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetShadowWithColor( context, CGSizeMake( 1.5, 0 ), 2.0, alphaShadow );
    
    if ( flipped ) {
        CGContextScaleCTM(context, -1, 1);
        CGContextTranslateCTM(context, -rect.size.width, 0);
    }
    
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
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return viewImage;
}

- (void)adjustBackground
{
    if ( self.pageBackground == nil ) {
        UIImageView *bg = [[UIImageView alloc] initWithFrame:self.bounds];
        bg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:bg atIndex:0];
        self.pageBackground = bg;
        [bg release];
    }
    
    if ( self.landscapeMode ) {
        if ( self.backgroundLandscape == nil ) {
            self.backgroundLandscape = [self drawBackground];
        }
        self.pageBackground.image = self.backgroundLandscape;
    } else {
        if ( self.backgroundPortrait == nil ) {
            self.backgroundPortrait = [self drawBackground];
        }
        self.pageBackground.image = self.backgroundPortrait;
    }
}

- (void)loadPageContent
{
    self.pageContent = [datasource pageViewForPage:self];
    self.pageContent.frame = contentView.bounds;
    [pageCache pageCacheWithView:self.pageContent];
    [contentView addSubview:pageContent];
    if ( [delegate respondsToSelector:@selector(pageViewDidFinishLoadContentForPage:)] ) {
        [delegate pageViewDidFinishLoadContentForPage:self];
    }
}

- (void)setFlippedFlag
{
    self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //self.transform = CGAffineTransformMakeScale( -1, 1);
    //self.contentView.transform = CGAffineTransformMakeScale( -1, 1);
    self.flipped = YES;
}


#pragma mark - Public

- (void)layoutSubviews
{    
    //DLog(@"layoutSubviews %d", self.tag);
    CGRect rect = self.bounds;
    rect.origin.y = -rect.size.height;
    
    [self adjustBackground];
    
    if ( self.pageCache != nil ) {
        [pageCache removeFromSuperview];
        self.pageCache = nil;
    }
    
    PSPageCache *pc = [[PSPageCache alloc] initWithFrame:rect];
    pc.flipped = self.flipped;
    [self addSubview:pc];
    self.pageCache = pc;
    [pc release];
        
    self.contentView.frame = [pageCache contentRect];
    if ( flipped ) {
        rect = self.contentView.frame;
        rect.origin.x = self.frame.size.width - rect.size.width;
        self.contentView.frame = rect;
    }
    
    if ( self.pageContent != nil ) {
        [self.pageContent removeFromSuperview];
        self.pageContent = nil;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(loadPageContent) withObject:nil afterDelay:0.5];
}

- (void)pageDidRotateWithPageOrientation:(PSPagesViewPageOrientation)orientation
{
    self.landscapeMode = orientation == PSPagesViewPageOrientationLandscape;
    if ( self.pageContent != nil ) {
        [self.pageContent removeFromSuperview];
        self.pageContent = nil;
    }
    //DLog(@"Subviews:%d > %@",self.tag, self.contentView.subviews);
}

- (UIImage*)textureData
{
    return [self.pageCache textureData];
}

- (CGRect)textureRect
{
    return [self.pageCache textureRect];
}

- (CGRect)textureBounds
{
    return self.pageCache.bounds;
}


- (void)dealloc
{
    [contentView release];
    [backgroundPortrait release];
    [backgroundLandscape release];
    [super dealloc];
}

@end
