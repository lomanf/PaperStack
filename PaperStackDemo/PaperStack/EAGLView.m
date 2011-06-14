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

@interface EAGLView()

- (void)drawView:(id)sender;

@property (nonatomic, retain) PSPage* leftPage_;
@property (nonatomic, retain) PSPage* rightPage_;
@property (nonatomic, retain) PSEffects* effects_;

@end

@implementation EAGLView

@synthesize animating;
@dynamic animationFrameInterval;
@synthesize animationTime;
@synthesize datasource;

@synthesize leftPage_, rightPage_, effects_;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
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
        
        self.clearsContextBeforeDrawing = YES;

        PSEffects *aEffects = [[PSEffects alloc] init];
        self.effects_ = aEffects;
        [aEffects release];
}
    
  return self;
}

- (void)drawView:(id)sender
{

}

- (void)applyTransform
{
    [rightPage_ deform];
    [renderer renderObject:rightPage_ withEffects:effects_];    
}

- (void)loadTextures 
{
    
    [effects_ buildEffects];
    [renderer loadEffects];
     
    [renderer loadTextures];
    
    // update texture coord
    
    UIImage *tex = [renderer.datasource rendererGetFrontTexture];
    CGRect rect = [renderer.datasource rendererGetFrontTextureRect];
    
    // correct width
    rightPage_.width = ( self.superview.frame.size.width * 0.5 ) / ( self.frame.size.width * 0.5 ) * 0.5;
    rightPage_.height = self.superview.frame.size.height / self.frame.size.height;
    rightPage_.width = rect.size.width / self.frame.size.width;
    rightPage_.height = rect.size.height / self.frame.size.height;
    [rightPage_ createMesh];
    
    // interpolate texture rect
    rect.origin.x /= tex.size.width;
    rect.origin.y = ( tex.size.height - rect.size.height - rect.origin.y ) / tex.size.height;
    rect.size.width /= tex.size.width;
    rect.size.height /= tex.size.height;
    
    NSLog( @"Rect -->: %f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height );
    [rightPage_ updateTextureCoord:rect];
}

- (void)layoutSubviews
{ 
    effects_.bounds = self.bounds;
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [renderer setupView:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
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
      // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
      // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
      // not be called in system versions earlier than 3.1.
      displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
      [displayLink setFrameInterval:animationFrameInterval];
      [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    } else {
      animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
    }
      
    animating = TRUE;
  }
}

- (void)stopAnimation
{
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

- (PSPage *)activePage
{
  return rightPage_;
}

- (PSEffects *)activeEffects
{
    return effects_;
}

- (void)setDatasource:(id<ESRendererDataSource>)value
{
    renderer.datasource = value;
}

#pragma mark -
#pragma mark CCPageDelegate

- (void)pageDidFinishDeformWithAngle:(CGFloat)angle andTime:(CGFloat)time point:(CGPoint)point theta:(CGFloat)theta
{
    [effects_ updateCurlPath:[rightPage_ curlPath] withShadow:[rightPage_ shadowPath] time:time angle:angle point:point theta:theta];
}

- (void)dealloc
{
    [rightPage_ release];
    [effects_ release];
    [renderer release];
    [super dealloc];
}

@end
