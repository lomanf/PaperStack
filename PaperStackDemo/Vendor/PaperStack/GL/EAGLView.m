//
//  EAGLView.m
//  ConeCurl
//
//  Created by W. Dana Nuon on 4/18/10.
//  Copyright lunaray 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "EAGLView.h"
#import "ES1Renderer.h"
#import "PSEffects.h"
#import "PSDrawings.h"
#import "PSKonstants.h"

@interface EAGLView()

- (void)startAnimation;
- (void)stopAnimation;
- (void)updateView:(id)sender;

@property (nonatomic, retain) PSPage* leftPage_;
@property (nonatomic, retain) PSPage* rightPage_;
@property (nonatomic, assign) PSPage* activePage_;
@property (nonatomic, retain) PSEffects* effects_;
@property (nonatomic, assign) CGPoint targetPoint_;
@property (nonatomic, assign) CGPoint targetVector_;
@property (nonatomic, assign) CGFloat targetTime_;
@property (nonatomic, assign) CGFloat currentTime_;

@end

@implementation EAGLView

@synthesize animating;
@dynamic animationFrameInterval;
@synthesize animationTime;
@synthesize datasource;

@synthesize leftPage_, rightPage_, activePage_, effects_, targetPoint_, targetVector_, targetTime_, currentTime_;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithFrame:(CGRect)frame
{    
    if ((self = [super initWithFrame:frame]))
    {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
            
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        self.backgroundColor = [UIColor clearColor];
        
        if ( !renderer ) {
            renderer = [[ES1Renderer alloc] init];
            if (!renderer) {
                [self release];
                return nil;
            }
        }
    
        animating = FALSE;
        displayLinkSupported = FALSE;
        animationFrameInterval = 1;
        displayLink = nil;
        animationTimer = nil;
    
        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
            displayLinkSupported = TRUE;
        }
        
        PSPage *aPage = [[PSPage alloc] init];
        aPage.currentFrame = 0;
        aPage.framesPerCycle = 120;
        aPage.width = 1.0f;
        aPage.height = 1.0f;
        aPage.columns = PAGE_COLUMNS;
        aPage.rows = PAGE_ROWS;
        aPage.delegate = self;
        [aPage createMesh];
        
        self.rightPage_ = aPage;
        
        aPage = [[PSPage alloc] init];
        aPage.currentFrame = 0;
        aPage.framesPerCycle = 120;
        aPage.width = 1.0f;
        aPage.height = 1.0f;
        aPage.columns = PAGE_COLUMNS;
        aPage.rows = PAGE_ROWS;
        aPage.delegate = self;
        aPage.hasReverseCurl = YES;
        [aPage createMesh];
        
        self.leftPage_ = aPage;
        
        self.clearsContextBeforeDrawing = YES;

        PSEffects *aEffects = [[PSEffects alloc] init];
        self.effects_ = aEffects;
        [aEffects release];
    }
    
  return self;
}

- (void)updateView:(id)sender
{
    PSPage *active = [self activePage];
    /*
    self.currentTime_ = self.currentTime_ + 1.0/60.0;
    CGFloat t = self.currentTime_ / self.targetTime_;
    if ( currentTime_ >= targetTime_ ) {
        t = 1.0;
        [self stopAnimation];
    }
    CGFloat tv = PSQuad( t, 0, 1 );
    active.P = CGPointMake( self.targetPoint_.x - self.targetVector_.x * tv, self.targetPoint_.y - self.targetVector_.y * tv );
    [self applyTransform];
     */
    CGFloat dx = ( active.SP.x - active.P.x ) * kPSPageAnimationFriction;
    CGFloat dy = ( active.SP.y - active.P.y ) * kPSPageAnimationFriction;
    if ( fabs(dx) < kPSPageAnimationThreshold && fabs(dy) < kPSPageAnimationThreshold ) {
        [self stopAnimation];
        active.P = active.SP;
    } else {
        active.P = CGPointMake(active.P.x+dx,active.P.y+dy);
    }
    [self applyTransform];
    
}

- (void)applyTransform
{
    [activePage_ deform];
    [renderer renderObject:activePage_ withEffects:effects_];    
}

- (void)loadLeftTextures 
{
    DLog(@"loadLeftTextures");
    
    [renderer loadTextures];
    
    // update texture coord
    
    UIImage *tex = [renderer.datasource rendererGetLeftFrontTexture];
    CGRect rect = [renderer.datasource rendererGetLeftFrontTextureRect];
    
    // correct width
    leftPage_.width = rect.size.width / self.frame.size.width;
    leftPage_.height = rect.size.height / self.frame.size.height;
    [leftPage_ createMesh];
        
    // interpolate texture rect
    rect.origin.x /= tex.size.width;
    rect.origin.y = ( tex.size.height - rect.size.height - rect.origin.y ) / tex.size.height;
    rect.size.width /= tex.size.width;
    rect.size.height /= tex.size.height;
    
    //DLog( @"RectPerc -->: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
    [leftPage_ updateTextureCoord:rect];
    
}

- (void)loadRightTextures
{
    DLog(@"loadRightTextures");
    
    [renderer loadTextures];
    
    // update texture coord
    
    UIImage *tex = [renderer.datasource rendererGetRightFrontTexture];
    CGRect rect = [renderer.datasource rendererGetRightFrontTextureRect];
       
    DLog( @"Rect -->: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
    DLog( @"Bounds -->: %f, %f", self.frame.size.width, self.frame.size.height );
    
    // correct width
    rightPage_.width = rect.size.width / self.frame.size.width;
    rightPage_.height = rect.size.height / self.frame.size.height;
    [rightPage_ createMesh];
    
    effects_.pageRect = rect;
    effects_.pageSize = tex.size;
    [effects_ buildEffects];
    [renderer loadEffects];
    
    // interpolate texture rect
    rect.origin.x /= tex.size.width;
    rect.origin.y = ( tex.size.height - rect.size.height - rect.origin.y ) / tex.size.height;
    rect.size.width /= tex.size.width;
    rect.size.height /= tex.size.height;
    
    DLog( @"RectPerc -->: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
    [rightPage_ updateTextureCoord:rect];
    
}

- (void)layoutSubviews
{ 
    if ( !setupCompleted ) {
        DLog(@"layoutSubviews");
        setupCompleted = YES;
        effects_.bounds = self.bounds;
        [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
        [renderer setupView:(CAEAGLLayer*)self.layer];
    }
}

- (NSInteger)animationFrameInterval
{
  return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
  // Frame interval defines how many display frames must pass between each time the
  // display link fires. The display link will only fire 30 times a second when the
  // frame internal is two on a display that refreshes 60 times a second. The default
  // frame interval setting of one will fire 60 times a second when the display refreshes
  // at 60 times a second. A frame interval setting of less than one results in undefined
  // behavior.
  if (frameInterval >= 1)
  {
    animationFrameInterval = frameInterval;
    
    if (animating)
    {
      [self stopAnimation];
      [self startAnimation];
    }
  }
}

- (void)startAnimation
{
  if (!animating)
  {
    if (displayLinkSupported )
    {
        DLog(@"displayLinkSupported");
      // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
      // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
      // not be called in system versions earlier than 3.1.
      displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(updateView:)];
      [displayLink setFrameInterval:animationFrameInterval];
      [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    } else {
      animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(updateView:) userInfo:nil repeats:TRUE];
    }
      
    animating = TRUE;
  }
}

- (void)stopAnimation
{
    NSLog(@"StopAnimation" );
  if (animating)
  {
    if (displayLinkSupported)
    {
      [displayLink invalidate];
      displayLink = nil;
    }
    else
    {
      [animationTimer invalidate];
      animationTimer = nil;
    }
    
    animating = FALSE;
  }
}

- (void)animateToEnd
{
    self.targetPoint_ = [self activePage].P;
    self.targetVector_ = PSVector( self.targetPoint_, CGPointMake( [self activePage].SP.x, [self activePage].SP.y ) );
    self.currentTime_ = 0.0;
    CGPoint vp = CGPointMake( self.targetPoint_.x+self.targetVector_.x, self.targetPoint_.y+self.targetVector_.y);
    self.targetTime_ = fminf( PSDistance( self.targetPoint_, vp ) * 0.66, 0.25 );
    [self startAnimation];
}

- (void)activateLeftPage
{
    DLog(@"activateLeftPage");
    self.activePage_ = leftPage_;
}

- (void)activateRightPage
{
    DLog(@"activateRightPage");
    self.activePage_ = rightPage_;
}

- (PSPage *)activePage
{
  return activePage_;
}

- (PSEffects *)activeEffects
{
    return effects_;
}

- (void)setDatasource:(id<ESRendererDataSource>)value
{
    renderer.datasource = value;
}

- (void)setOrthoTranslate:(CGFloat)value
{
    renderer.orthoTranslate = value;
}

#pragma mark -
#pragma mark CCPageDelegate

- (void)pageDidFinishDeformWithAngle:(CGFloat)angle andTime:(CGFloat)time point:(CGPoint)point theta:(CGFloat)theta
{
    [effects_ updateCurlTime:time angle:angle point:point theta:theta];
}

- (void)dealloc
{
    [rightPage_ release];
    [leftPage_ release];
    [effects_ release];
    [renderer release];
    [super dealloc];
}

@end
