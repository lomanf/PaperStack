//
//  PSPlayerController.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 25/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSPlayerController.h"
#import <QuartzCore/QuartzCore.h>
#import "CCPage.h"

@interface PSPlayerController()

@property (nonatomic, assign) BOOL landscapeMode;
@property (nonatomic, assign) PSPageView *pageTarget;
@property (nonatomic, retain) PSPageView *pageLeft;
@property (nonatomic, retain) PSPageView *pageRight;

// drawing elements

- (void)deviceDidRotate;
- (void)pageCurlWithPoint:(CGPoint)point;

@end

@implementation PSPlayerController

@synthesize landscapeMode, pageTarget, pageLeft, pageRight;
@synthesize glView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [glView release];
    [pageLeft release];
    [pageRight release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    
    self.glView.datasource = self;
    
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect plRect, prRect;
    
    plRect = self.view.bounds;
    prRect = self.view.bounds;
        
    PSPageView *lp = [[PSPageView alloc] initWithFrame:plRect];
    PSPageView *rp = [[PSPageView alloc] initWithFrame:prRect];
    
    [lp setFlippedFlag];
    
    self.pageRight = rp;
    self.pageLeft = lp;
        
    [self.view addSubview:lp];
    [self.view addSubview:rp];
    
    [lp release];
    [rp release];
    
    [self.view bringSubviewToFront:glView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGRect plRect, prRect;
    
    plRect = self.view.bounds;
    prRect = self.view.bounds;
    
    self.pageLeft.hidden = YES;
    
    if ( UIInterfaceOrientationIsLandscape( interfaceOrientation ) ) {
        prRect.size.width = prRect.size.width * 0.5;
        prRect.origin.x = prRect.size.width;
        plRect.size.width = plRect.size.width * 0.5;
        self.pageLeft.hidden = NO;
        [self.pageLeft setNeedsDisplay];
        [self.pageLeft pageWillRotateToOrientation:interfaceOrientation];
        [self performSelector:@selector(deviceDidRotate) withObject:nil afterDelay:1.0];
        landscapeMode = YES;
        self.pageLeft.frame = plRect;
    } else {
        landscapeMode = NO;
        [self performSelector:@selector(deviceDidRotate) withObject:nil afterDelay:1.2];
    }
    [self.pageRight setNeedsDisplay];
    [self.pageRight pageWillRotateToOrientation:interfaceOrientation];

    self.pageRight.frame = prRect;
    
    // Return YES for supported orientations
    return YES;
}

- (void)deviceDidRotate 
{
    if ( landscapeMode ) {
        [self.pageLeft pageDidRotate];
    }
    [self.pageRight pageDidRotate];
}

#pragma mark -
#pragma ESRenderer Datasource

- (UIImage*)rendererGetFrontTexture
{
    return [self.pageTarget textureData];
}

- (UIImage*)rendererGetBackTexture {
    return [self.pageTarget textureData];
}

- (CGRect)rendererGetFrontTextureRect 
{
    return [self.pageTarget textureRect];
}

- (CGRect)rendererGetBackTextureRect 
{
    return [self.pageTarget textureRect];
}

#pragma mark -
#pragma mark Manipulating

- (void)pageCurlWithPoint:(CGPoint)point
{
    CGRect rect = self.view.frame;
    CGFloat halfw = rect.size.width * 0.5;
    CGFloat halfh = rect.size.height * 0.5;
    CGFloat dx = ( point.x - halfw ) / halfw; 
    CGFloat dy = ( point.y - halfh ) / halfh; 
    
    CGFloat pX = dx;
    CGFloat pY = -dy;
   
    /*
    CCPage *page = [glView activePage];
    page.Ax = aX;
    page.Ay = aY;
    page.rho = 0.0;
    page.theta = 0.3;
    */
    
    CCPage *page = [glView activePage];
    page.P = CGPointMake( pX, pY );
    
    [glView applyTransform:(point.x/rect.size.width)];
}

#pragma mark -
#pragma Touches handler

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
    
    if ( landscapeMode ) {
        if ( touchPoint.x <= self.view.frame.size.width * 0.5 ) {
            self.pageTarget = pageLeft;
        } else {
            self.pageTarget = pageRight;
        }
    } else {
        self.pageTarget = pageRight;
    }
    // update textures
    [glView loadTextures];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[self.glView stopAnimation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];        
	[self pageCurlWithPoint:touchPoint];
}

@end
