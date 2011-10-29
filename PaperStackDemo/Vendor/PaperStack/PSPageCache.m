//
//  PSPageCache.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 28/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSPageCache.h"
#import "PSDrawings.h"
#import "PSKonstants.h"
#import <QuartzCore/QuartzCore.h>

@interface PSPageCache()

@property (nonatomic, retain) UIImage *currentImage;

@end

@implementation PSPageCache

@synthesize currentImage, flipped;

static CGMutablePathRef pagePath;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat pad = rect.size.width * kPSPagePaddingRatio;
    CGFloat side = rect.size.width * kPSPageSideRatio;
    
    CGMutablePathRef page1 = PSCreatePagePath( rect, pad, side+pad );
    pagePath = page1;
    
    CGColorRef alphaBlack = [[UIColor blackColor] colorWithAlphaComponent:0.15].CGColor;
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor( context, alphaBlack);
	CGContextSetLineWidth( context, 1.0 );
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // fill & stroke
    
    if ( flipped ) {
        CGContextTranslateCTM(context, rect.size.width, 0);
        CGContextScaleCTM(context, -1, 1);        
    }
    
    CGContextSaveGState( context );
    
    CGContextAddPath( context, page1 );
    CGContextFillPath( context );
    CGContextAddPath( context, page1 );
    CGContextStrokePath( context );
    
    CGContextRestoreGState( context );
    
}

#pragma mark -
#pragma mark Cache renderer

- (UIImage*)pageCacheWithView:(UIView*)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *iv = [[UIImageView alloc] initWithImage:image];
    iv.backgroundColor = [UIColor blueColor];
    iv.frame = [self contentRect];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:iv];
    
    UIGraphicsBeginImageContext( self.bounds.size );
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ( flipped ) {
        CGContextTranslateCTM(context, -iv.frame.origin.x, 0);
    }
    [self.layer renderInContext:context];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [iv removeFromSuperview];
    [iv release];
    
    CGImageRef CGImage = viewImage.CGImage;
    unsigned int potW = PSNextPOT( CGImageGetWidth( CGImage ) );
    unsigned int potH = PSNextPOT( CGImageGetHeight( CGImage ) );
    
    NSUInteger length = potW * potH * 4;
    void *data = malloc( length );
    
    //DLog( @"UIImage: %d, %d", potW, potH );
    
    CGContextRef contextRef = CGBitmapContextCreate( data, potW, potH, 8, potW * 4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast );
    CGRect rect = CGRectMake( 0, potH - self.frame.size.height, self.frame.size.width, self.frame.size.height );
    CGContextDrawImage( contextRef, rect, CGImage );
    CGImageRef img = CGBitmapContextCreateImage( contextRef );
    UIImage *newImage = [UIImage imageWithCGImage:img];
    
    CGImageRelease( img );
    CGContextRelease( contextRef );
    free( data );
    
    self.currentImage = newImage;
    
    return newImage;
}
                                                                   
- (UIImage*)textureData;
{
    return self.currentImage;
}

- (CGRect)textureRect 
{
    CGFloat pad = self.bounds.size.width * kPSPagePaddingRatio;
    CGFloat side = self.bounds.size.width * kPSPageSideRatio;
    
    CGMutablePathRef page1 = PSCreatePagePath( self.bounds, pad, side+pad );
    
    CGRect pageFrame = CGPathGetPathBoundingBox( page1 );
    pageFrame.origin.x = round(pageFrame.origin.x);
    pageFrame.origin.y = round(pageFrame.origin.y);
    pageFrame.size.width = floor(pageFrame.size.width);
    pageFrame.size.height = floor(pageFrame.size.height);
//    pageFrame.origin.x += 1;
//    pageFrame.size.width -= 2; 
    //DLog( @"Rect <--: %f, %f, %f, %f", pageFrame.origin.x, pageFrame.origin.y, pageFrame.size.width, pageFrame.size.height );
//    if ( flipped ) {
//        pageFrame.origin.x += self.bounds.size.width - pageFrame.size.width;
//    }
    return pageFrame;
}

- (CGRect)contentRect
{
    CGFloat pad = self.bounds.size.width * kPSPagePaddingRatio;
    CGFloat side = self.bounds.size.width * kPSPageSideRatio;
    
    CGMutablePathRef page1 = PSCreatePagePath( self.bounds, pad, side+pad );
    CGRect trect = CGPathGetPathBoundingBox( page1 );
    CGFloat radius = self.bounds.size.height * 0.05;
    CGFloat sp = radius * 0.25;
    trect.origin.y += sp;
    trect.size.height -= sp * 2;
    trect.origin.x = round(trect.origin.x);
    trect.origin.y = round(trect.origin.y);
    trect.size.width = floor(trect.size.width);
    trect.size.height = floor(trect.size.height);
    if ( flipped ) {
        trect.origin.x = self.bounds.size.width - trect.size.width;
    }
    return trect;
}
 
- (void)dealloc
{
    [currentImage release];
    [super dealloc];
}

@end
