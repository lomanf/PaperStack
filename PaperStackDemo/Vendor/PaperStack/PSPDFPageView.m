//
//  PSPDFPageView.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 15/09/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSPDFPageView.h"
#import "PSDrawings.h"

@interface PSPDFPageView()

@property (nonatomic, assign) CGPDFPageRef pdfPageRef;

@end

@implementation PSPDFPageView

@synthesize pdfPageRef;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithPDFPage:(CGPDFPageRef)pdfPage
{
    self = [super initWithFrame:CGRectZero];
    if ( self ) {
        self.backgroundColor = [UIColor whiteColor];
        self.pdfPageRef = pdfPage;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
    
    // Draw PDF (scaled to fit)
    CGAffineTransform transform = PSRectScaleAspectFit( CGPDFPageGetBoxRect(pdfPageRef, kCGPDFMediaBox), CGContextGetClipBoundingBox(context));
    CGContextConcatCTM(context, transform);
	CGContextDrawPDFPage(context, pdfPageRef);
}

- (void)dealloc
{
    [super dealloc];
}

@end
