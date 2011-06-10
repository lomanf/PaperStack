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

@synthesize currentImage;

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
    
    CGContextSaveGState( context );
    
    CGContextAddPath( context, page1 );
    CGContextFillPath( context );
    CGContextAddPath( context, page1 );
    CGContextStrokePath( context );
    
    CGContextRestoreGState( context );
    
}

#pragma mark -
#pragma mark Cache renderer

- (UIImage*)pageCacheWithImage:(UIImage*)image
{
    CGRect pageFrame = [self textureRect];
    
    UIImageView *iv = [[UIImageView alloc] initWithImage:image];
    iv.frame = pageFrame;
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:iv];
    
    UIGraphicsBeginImageContext( self.bounds.size );
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [iv removeFromSuperview];
    [iv release];
    
    CGImageRef CGImage = viewImage.CGImage;
    unsigned int potW = PSNextPOT( CGImageGetWidth( CGImage ) );
    unsigned int potH = PSNextPOT( CGImageGetHeight( CGImage ) );
    
    NSUInteger length = potW * potH * 4;
    void *data = malloc( length );
    
    NSLog( @"UIImage: %d, %d", potW, potH );
    
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
    CGRect pageFrame = CGPathGetPathBoundingBox( pagePath );
    pageFrame.origin.x += 1;
    pageFrame.size.width -= 2; 
    NSLog( @"Rect <--: %f, %f, %f, %f", pageFrame.origin.x, pageFrame.origin.y, pageFrame.size.width, pageFrame.size.height );
    return pageFrame;
}
 
- (void)dealloc
{
    [currentImage release];
    [super dealloc];
}

@end
