//
//  PSPlayerController.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 25/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSPlayerController.h"
#import <QuartzCore/QuartzCore.h>

@interface PSPlayerController()

@property (nonatomic, assign) BOOL landscapeMode;
@property (nonatomic, assign) NSInteger flipRatio;
@property (nonatomic, assign) CGFloat flipAngle;
@property (nonatomic, assign) PSPageView *pageTarget;
@property (nonatomic, retain) PSPageView *pageLeft;
@property (nonatomic, retain) PSPageView *pageRight;

- (void)deviceDidRotate;

@end

@implementation PSPlayerController

@synthesize landscapeMode, flipRatio, flipAngle, pageTarget, pageLeft, pageRight;

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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

    CGRect plRect, prRect;
    
    plRect = self.view.bounds;
    prRect = self.view.bounds;
        
    PSPageView *lp = [[PSPageView alloc] initWithFrame:plRect];
    PSPageView *rp = [[PSPageView alloc] initWithFrame:prRect];
    
    lp.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    rp.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    lp.transform = CGAffineTransformMakeScale( -1, 1);
    
    lp.flipped = YES;
    
    self.pageRight = rp;
    self.pageLeft = lp;
        
    [self.view addSubview:lp];
    [self.view addSubview:rp];
    
    [lp release];
    [rp release];
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
        [self.pageLeft pageWillRotate];
        [self performSelector:@selector(deviceDidRotate) withObject:nil afterDelay:1.0];
        landscapeMode = YES;
    } else {
        landscapeMode = NO;
        [self performSelector:@selector(deviceDidRotate) withObject:nil afterDelay:1.2];
    }
    [self.pageRight setNeedsDisplay];
    [self.pageRight pageWillRotate];
    self.pageLeft.isLandscape = landscapeMode;
    self.pageRight.isLandscape = landscapeMode;
    self.pageRight.frame = prRect;
    self.pageLeft.frame = plRect;

    
    // Return YES for supported orientations
    return YES;
}

- (void)deviceDidRotate 
{
    [self.pageLeft pageDidRotate];
    [self.pageRight pageDidRotate];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
    
    if ( landscapeMode ) {
        if ( touchPoint.x <= self.view.frame.size.width * 0.5 ) {
            self.pageTarget = pageLeft;
            flipRatio = 0;
            flipAngle = -M_PI;
        } else {
            self.pageTarget = pageRight;
            flipRatio = 1;
            flipAngle = M_PI;
        }
    } else {
        self.pageTarget = pageRight;
        flipRatio = 1;
        flipAngle = M_PI * 0.5;
    }
    CGFloat perc = flipRatio - ( touchPoint.x / self.view.bounds.size.width );
    [pageTarget pageFlipStartWithTarget:-fabs(flipAngle)];
    if ( fabsf( perc * flipAngle ) > M_PI * 0.12 ) {
        [pageTarget pageFlipEnd];
    }
    [self.view bringSubviewToFront:pageTarget];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [pageTarget pageFlipEnd];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self.view];
	
    CGFloat perc = flipRatio - ( touchPoint.x / self.view.bounds.size.width );
    CGFloat value = -perc * flipAngle;
    
    [pageTarget pageFlipTo:value];    
}


@end
