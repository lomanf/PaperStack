//
//  PSPlayerController.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 25/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSPagesViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PSPage.h"
#import "PSDrawings.h"

@interface PSPagesViewController()

@property (nonatomic, retain) EAGLView *glView;
@property (nonatomic, retain) NSDictionary *properties;
@property (nonatomic, assign) BOOL landscapeMode;
@property (nonatomic, assign) PSPageView *pageTarget;
@property (nonatomic, retain) PSPageView *pageLeft;
@property (nonatomic, retain) PSPageView *pageRight;

@property (nonatomic, retain) UIViewController *leftPageViewController_;
@property (nonatomic, retain) UIViewController *rightPageViewController_;


- (void)deviceOrientationDidChange:(NSNotification*)notification;

// drawing elements

- (void)checkOrientation;
- (void)deviceDidRotateWithPageOrientation:(PSPagesViewPageOrientation)orientation;
- (void)adjustGLView;
- (CGPoint)convertPointToGL:(CGPoint)point;
- (void)pageCurlBeganWithPoint:(CGPoint)point;
- (void)pageCurlTrackWithPoint:(CGPoint)point;
- (void)pageCurlEndedWithPoint:(CGPoint)point;

@end

@implementation PSPagesViewController

@synthesize datasource, shouldUseInitialEmptyLeftPage;
@synthesize properties;
@synthesize landscapeMode, pageTarget, pageLeft, pageRight;
@synthesize glView, pageOrientation;
@synthesize leftPageViewController_, rightPageViewController_;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Custom initialization
        EAGLView *glv = [[EAGLView alloc] initWithFrame:CGRectMake(0, 0, 1024, 1024)];
        glv.autoresizingMask = UIViewAutoresizingNone;
        self.glView = glv;
        [glv release];
        
        self.properties = [NSDictionary dictionary];
        self.pageOrientation = PSPagesViewPageOrientationUnknow;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [leftPageViewController_ release];
    [rightPageViewController_ release];
    [properties release];
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
    
    //self.view.userInteractionEnabled = NO;
    self.view.multipleTouchEnabled = NO;
    
    pageIndex = 0;
    
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    self.view.frame = rect;
    
    [self.view addSubview:self.glView];
    self.glView.datasource = self;
    
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect plRect, prRect;
    
    plRect = self.view.bounds;
    prRect = self.view.bounds;
    
    PSPageView *lp = [[PSPageView alloc] initWithFrame:plRect];
    PSPageView *rp = [[PSPageView alloc] initWithFrame:prRect];
    
    lp.tag = 100;
    rp.tag = 200;
    
    lp.properties = self.properties;
    lp.datasource = self;
    lp.delegate = self;
    
    rp.properties = self.properties;
    rp.datasource = self;
    rp.delegate = self;
    
    [lp setFlippedFlag];
    
    self.pageRight = rp;
    self.pageLeft = lp;
    
    [self.view addSubview:lp];
    [self.view addSubview:rp];
    
    [lp release];
    [rp release];
    
    [self.view bringSubviewToFront:glView];
    
    // rotation notifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(deviceOrientationDidChange:) 
                                                 name:UIDeviceOrientationDidChangeNotification 
                                               object:nil];
    
    [self checkOrientation];
}

- (void)deviceOrientationDidChange:(NSNotification*)notification
{
    [self checkOrientation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)checkOrientation
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ( UIInterfaceOrientationIsLandscape(orientation) || UIInterfaceOrientationIsPortrait(orientation) ) {
        PSPagesViewPageOrientation newPageOrientation = UIInterfaceOrientationIsLandscape(orientation) ? PSPagesViewPageOrientationLandscape : PSPagesViewPageOrientationPortrait;
        if ( self.pageOrientation != newPageOrientation ) {
            [self deviceDidRotateWithPageOrientation:newPageOrientation];
        }
    }
}

- (void)deviceDidRotateWithPageOrientation:(PSPagesViewPageOrientation)orientation 
{
    DLog(@"deviceDidRotateWithOrientation:%d",orientation);
    
    self.pageOrientation = orientation;
    
    CGRect plRect, prRect;
    
    plRect = self.view.bounds;
    prRect = self.view.bounds;
    
    self.pageLeft.hidden = YES;
    
    needsAdjustGLView = YES;
    
    if ( orientation == PSPagesViewPageOrientationLandscape ) {
        prRect.size.width = prRect.size.width * 0.5;
        prRect.origin.x = prRect.size.width;
        plRect.size.width = plRect.size.width * 0.5;
        self.pageLeft.hidden = NO;
        [self.pageLeft pageDidRotateWithPageOrientation:orientation];
        landscapeMode = YES;
        self.pageLeft.frame = plRect;
    } else {
        landscapeMode = NO;
    }
    [self.pageRight pageDidRotateWithPageOrientation:orientation];
    
    self.pageRight.frame = prRect;
}

- (void)adjustGLView
{
    CGSize screen = [UIScreen mainScreen].bounds.size;
    CGSize size = self.view.bounds.size;
    CGFloat dimension = fmaxf(screen.width, screen.height);
    CGFloat x, y;
    if ( self.pageOrientation == PSPagesViewPageOrientationPortrait ) {
        x = (dimension-size.width)*-0.5;
        y = (dimension-size.height)*-0.5;
        self.glView.frame = CGRectMake( x, y, dimension, dimension );
        [self.glView setOrthoTranslate:size.width*0.5/dimension];
    } else {
        x = (dimension-size.width)*-0.5;
        y = (dimension-size.height)*-0.5;
        self.glView.frame = CGRectMake( x, y, dimension, dimension );
        [self.glView setOrthoTranslate:0.0];
    }
    DLog(@"GLViewFrame: %f %f %f %f", self.glView.frame.origin.x, self.glView.frame.origin.y, self.glView.frame.size.width, self.glView.frame.size.height );
}

#pragma mark -
#pragma mark - Public

- (UIViewController*)leftPageViewController
{
    return self.leftPageViewController_;
}

- (UIViewController*)rightPageViewController
{
    return self.rightPageViewController_;
}

#pragma mark -
#pragma ESRenderer Datasource

- (BOOL)rendererHasSinglePage
{
    return landscapeMode == NO;
}

- (BOOL)rendererisRightPage 
{
    return self.pageTarget == self.pageRight;
}

- (UIImage*)rendererGetRightFrontTexture
{
    return [self.pageRight textureData];
}

- (UIImage*)rendererGetRightBackTexture {
    return [self.pageRight textureData];
}

- (UIImage*)rendererGetLeftFrontTexture
{
    return [self.pageLeft textureData];
}

- (UIImage*)rendererGetLeftBackTexture {
    return [self.pageLeft textureData];
}

- (CGRect)rendererGetRightFrontTextureRect 
{
    return [self.pageRight textureRect];
}

- (CGRect)rendererGetRightBackTextureRect 
{
    return [self.pageRight textureRect];
}

- (CGRect)rendererGetLeftFrontTextureRect 
{
    return [self.pageLeft textureRect];
}

- (CGRect)rendererGetLeftBackTextureRect 
{
    return [self.pageLeft textureRect];
}

- (CGRect)rendererGetRightFrontTextureBounds
{
    return [self.pageRight textureBounds];
}

- (CGRect)rendererGetRightBackTextureBounds
{
    return [self.pageRight textureBounds];
}

- (CGRect)rendererGetLeftFrontTextureBounds
{
    return [self.pageLeft textureBounds];
}

- (CGRect)rendererGetLeftBackTextureBounds
{
    return [self.pageLeft textureBounds];
}

- (UIImage*)rendererGetShaderTexture
{
    return [glView activeEffects].shaderImage;
}

- (UIImage*)rendererGetInnerShadowTexture
{
    return [glView activeEffects].innerShadowImage;
}

#pragma mark -
#pragma mark Manipulating

- (CGPoint)convertPointToGL:(CGPoint)point 
{
    CGFloat halfw, halfh, dx, dy, pX, pY;
    CGRect rect = self.glView.frame;
    if ( landscapeMode ) {
        halfw = rect.size.width * 0.5;
    } else {
        halfw = rect.size.width * 0.5 - self.view.frame.size.width * 0.5;
    }
    halfh = rect.size.height * 0.5;
    dx = ( point.x - halfw ) / rect.size.width; 
    dy = ( point.y - halfh ) / rect.size.height;
    pX = dx;
    pY = -dy;
    return CGPointMake( pX, pY );
}

- (void)pageCurlBeganWithPoint:(CGPoint)point
{
    // update textures
    //[glView loadTextures];
    PSPage *page = [glView activePage];
    page.SP = [self convertPointToGL:point];
    DLog(@"SP: %f %f", page.SP.x, page.SP.y );
}

- (void)pageCurlTrackWithPoint:(CGPoint)point
{  
    PSPage *page = [glView activePage];
    CGPoint np = [self convertPointToGL:point];
    if ( !CGPointEqualToPoint(np, page.P) ) {
        page.P = np;
        [glView applyTransform];
    }   
}

- (void)pageCurlEndedWithPoint:(CGPoint)point
{
    [glView animateToEnd];
}

#pragma mark -
#pragma Touches handler

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [event.allTouches anyObject];
    CGPoint testPoint = [touch locationInView:self.view];
    
    if ( landscapeMode ) {
        if ( testPoint.x <= self.view.bounds.size.width * 0.5 ) {
            self.pageTarget = pageLeft;
            [glView activateLeftPage];
            pageShouldCurl = testPoint.x < self.view.bounds.size.width * 0.1;
            testPoint.x = 0;
        } else {
            self.pageTarget = pageRight;
            [glView activateRightPage];
            pageShouldCurl = testPoint.x > self.view.bounds.size.width * 0.9;
            testPoint.x = self.view.bounds.size.width;
        }
    } else {
        self.pageTarget = pageRight;
        [glView activateRightPage];
        pageShouldCurl = testPoint.x > self.view.bounds.size.width * 0.9;
        testPoint.x = self.view.bounds.size.width;
    }
    // start curl
    if ( pageShouldCurl ) {
        CGPoint touchPoint = [self.glView convertPoint:testPoint fromView:self.view];
        [self pageCurlBeganWithPoint:touchPoint];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self.glView];        
    if ( pageShouldCurl ) {
        [self pageCurlTrackWithPoint:touchPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [event.allTouches anyObject];
	CGPoint touchPoint = [touch locationInView:self.glView];        
    if ( pageShouldCurl ) {
        [self pageCurlEndedWithPoint:touchPoint];
    }
    pageShouldCurl = NO;
}

#pragma mark -
#pragma mark PSPageViewDatasource

- (UIView*)pageViewForPage:(PSPageView *)pageView
{
    if ( self.landscapeMode ) {
        if ( pageView == self.pageLeft ) {
            if ( pageIndex == 0 && self.shouldUseInitialEmptyLeftPage ) {
                return nil;
            }
            self.leftPageViewController_ = [datasource pagesPageViewControllerAtIndex:pageIndex]; 
            return self.leftPageViewController_.view;
        } else {
            NSInteger rIndex = pageIndex + 1;
            if ( pageIndex == 0 && self.shouldUseInitialEmptyLeftPage ) {
                rIndex = pageIndex;
            }
            self.rightPageViewController_ = [datasource pagesPageViewControllerAtIndex:rIndex]; 
            return self.rightPageViewController_.view;
        }
    }
    self.rightPageViewController_ = [datasource pagesPageViewControllerAtIndex:pageIndex]; 
    return self.rightPageViewController_.view;
}

#pragma mark -
#pragma mark PSPageViewDelegate

- (void)pageViewDidFinishLoadContentForPage:(PSPageView *)pageView
{
    self.pageTarget = pageView;
    if (needsAdjustGLView) {
        DLog(@"AdjustGLView");
        needsAdjustGLView = NO;
        [self adjustGLView];
    }
    if ( pageView == pageLeft && landscapeMode ) {
        [glView loadLeftTextures];
    }
    if ( pageView == pageRight ) {
        [glView loadRightTextures];
    }
}

@end
