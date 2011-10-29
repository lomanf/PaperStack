//
//  ES1Renderer.h
//  ConeCurl
//
//  Created by W. Dana Nuon on 4/18/10.
//  Copyright lunaray 2010. All rights reserved.
//
//  Modified from Xcode OpenGL ES template project.
//
//  TODO: Add proper lighting once we calculate surface normals.

#import "ESRenderer.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "ESCommon.h"

@interface ES1Renderer : NSObject <ESRenderer>
{
@private
    EAGLContext *context;
  
    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;
  
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;
    GLuint texture[6];
    
    NSUInteger frontTextureIndex;
    NSUInteger backTextureIndex;
}

@property (nonatomic, assign) id<ESRendererDataSource> datasource;
@property (nonatomic, assign) CGFloat orthoTranslate;

- (void)setupView:(CAEAGLLayer *)layer;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)renderObject:(id)obj withEffects:(id)effects;

@end
