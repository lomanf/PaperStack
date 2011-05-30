//
//  EAGLView.h
//  ConeCurl
//
//  Created by W. Dana Nuon on 4/18/10.
//  Copyright lunaray 2010. All rights reserved.
//
//  Modified from Xcode OpenGL ES template project.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ESRenderer.h"
#import "CCCommon.h"
#import "CCPage.h"

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{
  CGFloat animationTime;
@private
  id <ESRenderer> renderer;
  
  BOOL animating;
  BOOL displayLinkSupported;
  NSInteger animationFrameInterval;
  // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
  // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
  // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
  // isn't available.
  id displayLink;
  NSTimer *animationTimer;
  
  CCPage *leftPage_;  // Probably not good design. Model should be moved out of the view and into the controller.
  CCPage *rightPage_; // May only need one page object for the actively turning page, unless we want to
                      // draw the underlying pages with a curve rather than flat, in which case we'd need three.
                      // We could also implement an interesting "shuffle" of many pages flipping at once with
                      // multiple CCPage objects with slightly different time values.
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic) IBOutlet CGFloat animationTime;
@property (nonatomic,assign) id<ESRendererDataSource> datasource;

- (void)loadTextures;
- (void)startAnimation;
- (void)stopAnimation;
- (CCPage *)activePage;
- (void)drawView:(id)sender;
- (void)drawViewForTime:(CGFloat)time;
- (void)applyTransform:(CGFloat)time;

@end
