//
//  ES1Renderer.m
//  ConeCurl
//
//  Created by W. Dana Nuon on 4/18/10.
//  Copyright lunaray 2010. All rights reserved.
//
//  Portions borrowed and slightly modified from Jeff LaMarche, (C) 2009.

#import "ES1Renderer.h"
#import "PSPage.h"
#import "PSEffects.h"

@interface ES1Renderer()

@property (nonatomic, assign) BOOL hasSinglePage;

- (void)drawShaderWithEffects:(id)effects;
- (void)drawInnerShadowWithEffects:(id)effects andObject:(id)obj;
- (void)drawOuterShadowWithEffects:(id)effects andObject:(id)obj;

@end

@implementation ES1Renderer

@synthesize datasource, orthoTranslate, hasSinglePage;

// Create an OpenGL ES 1.1 context
- (id)init
{
  if ((self = [super init]))
  {
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!context || ![EAGLContext setCurrentContext:context])
    {
      [self release];
      return nil;
    }
    
    // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
    glGenFramebuffersOES(1, &defaultFramebuffer);
    glGenRenderbuffersOES(1, &colorRenderbuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
  }
  
  return self;
}

- (void)setupView:(CAEAGLLayer *)layer
{	
  [EAGLContext setCurrentContext:context];
  glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    
	//const GLfloat zNear = 0.01f, zFar = 100.0f, fieldOfView = 1.0f; 
	glMatrixMode(GL_PROJECTION); 
	//GLfloat size = zNear * tanf(DEGREES_TO_RADIANS(fieldOfView) / 2.0f); 
    //GLfloat aspectRatio = (GLfloat)backingWidth / backingHeight;
	//glFrustumf(-size, size, -size / aspectRatio, size / aspectRatio, zNear, zFar); 
	glViewport(0, 0, backingWidth, backingHeight);  
    //glTranslatef(0.0f, 0.0f, 0.0f);
    glOrthof(0.0f, 1.0f, 0.0f, 1.0f, -1.0f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
    glEnable(GL_TEXTURE_2D);
    glGenTextures(6, &texture[0]);
}

- (void)loadTextures
{
    
    // single page
    self.hasSinglePage = [datasource rendererHasSinglePage];
    
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
    
    UIImage *image = [datasource rendererGetRightFrontTexture];
    
    if (image == nil)
        NSLog(@"Do real error checking here");
    
 	GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    
    CGContextRef bitmapContext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace,
                                                       kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    
    // Flip the Y-axis
    CGContextTranslateCTM (bitmapContext, 0, height);
    CGContextScaleCTM (bitmapContext, 1.0, -1.0);
    
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(bitmapContext, CGRectMake( 0, 0, width, height ) );
    CGContextDrawImage(bitmapContext, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(bitmapContext);
    
    free(imageData);
    
    glBindTexture(GL_TEXTURE_2D, texture[1]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
    image = [datasource rendererGetRightBackTexture];
    
    if (image == nil)
        NSLog(@"Do real error checking here");
    
 	width = CGImageGetWidth(image.CGImage);
    height = CGImageGetHeight(image.CGImage);
    imageData = malloc( height * width * 4 );
    
    bitmapContext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace,
                                          kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    
    // Flip the Y-axis
    CGContextTranslateCTM (bitmapContext, 0, height);
    CGContextScaleCTM (bitmapContext, 1.0, -1.0);
    
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(bitmapContext, CGRectMake( 0, 0, width, height ) );
    CGContextDrawImage(bitmapContext, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(bitmapContext);
    
    free(imageData);
    
    if ( !self.hasSinglePage ) {
        glBindTexture(GL_TEXTURE_2D, texture[2]);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
        image = [datasource rendererGetLeftFrontTexture];
        
        if (image == nil)
            NSLog(@"Do real error checking here");
        
        width = CGImageGetWidth(image.CGImage);
        height = CGImageGetHeight(image.CGImage);
        imageData = malloc( height * width * 4 );
        
        bitmapContext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace,
                                              kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
        
        // Flip the Y-axis
        CGContextTranslateCTM (bitmapContext, 0, height);
        CGContextScaleCTM (bitmapContext, 1.0, -1.0);
        
        CGColorSpaceRelease(colorSpace);
        CGContextClearRect(bitmapContext, CGRectMake( 0, 0, width, height ) );
        CGContextDrawImage(bitmapContext, CGRectMake( 0, 0, width, height ), image.CGImage );
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        
        CGContextRelease(bitmapContext);
        
        free(imageData);
        
        glBindTexture(GL_TEXTURE_2D, texture[3]);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
        image = [datasource rendererGetLeftBackTexture];
        
        if (image == nil)
            NSLog(@"Do real error checking here");
        
        width = CGImageGetWidth(image.CGImage);
        height = CGImageGetHeight(image.CGImage);
        imageData = malloc( height * width * 4 );
        
        bitmapContext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace,
                                              kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
        
        // Flip the Y-axis
        CGContextTranslateCTM (bitmapContext, 0, height);
        CGContextScaleCTM (bitmapContext, 1.0, -1.0);
        
        CGColorSpaceRelease(colorSpace);
        CGContextClearRect(bitmapContext, CGRectMake( 0, 0, width, height ) );
        CGContextDrawImage(bitmapContext, CGRectMake( 0, 0, width, height ), image.CGImage );
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        
        CGContextRelease(bitmapContext);
        
        free(imageData);
    }

}

- (void)loadEffects
{
    glBindTexture(GL_TEXTURE_2D, texture[4]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
    
    UIImage *image = [datasource rendererGetShaderTexture];
    
    if (image == nil)
        NSLog(@"Do real error checking here");
    
 	GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    
    CGContextRef bitmapContext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace,
                                                       kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    
    // Flip the Y-axis
    CGContextTranslateCTM (bitmapContext, 0, height);
    CGContextScaleCTM (bitmapContext, 1.0, -1.0);
    
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(bitmapContext, CGRectMake( 0, 0, width, height ) );
    CGContextDrawImage(bitmapContext, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(bitmapContext);
    
    free(imageData);
    
    glBindTexture(GL_TEXTURE_2D, texture[5]);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR); 
    image = [datasource rendererGetInnerShadowTexture];
    
    if (image == nil)
        NSLog(@"Do real error checking here");
    
 	width = CGImageGetWidth(image.CGImage);
    height = CGImageGetHeight(image.CGImage);
    imageData = malloc( height * width * 4 );
    
    bitmapContext = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace,
                                          kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    
    // Flip the Y-axis
    CGContextTranslateCTM (bitmapContext, 0, height);
    CGContextScaleCTM (bitmapContext, 1.0, -1.0);
    
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(bitmapContext, CGRectMake( 0, 0, width, height ) );
    CGContextDrawImage(bitmapContext, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    
    CGContextRelease(bitmapContext);
    
    free(imageData);
    
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{	
    
  // Allocate color buffer backing based on the current layer size
  glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
  [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
  glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
  glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
      
  //  NSLog(@"BackinW: %d", backingWidth);
  //  NSLog(@"BackinH: %d", backingHeight);
    
  if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
  {
    NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
    return NO;
  }
  
  return YES;
}

- (void)renderObject:(id)obj withEffects:(id)effects
{
    const Vertex3f  *vertices   = [obj vertices];
    const Vertex2f  *textures   = [obj textureArray];
    
    frontTextureIndex = 0;
    backTextureIndex = 1;
    if ( ![datasource rendererisRightPage] ) {
        frontTextureIndex = 2;
        backTextureIndex = 3;
    }
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(-0.5, 0.5, -0.5f, 0.5f, -1.0f, 1.0f);
    glTranslatef(-orthoTranslate, 0.0f, 0.0f);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);    

    // Load our vertex and texture arrays. This needs to be done only once since the front and back pages share this data.
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textures);

#if USE_TRIANGLE_STRIPS  
    
    const GLushort  *frontStrip = [obj frontStrip];
    const GLushort  *backStrip  = [obj backStrip];
    GLuint   stripLength  = [obj stripLength];
    
    // Draw the back page
    if ( hasSinglePage ) {
        glColor4f(0.4, 0.4, 0.4, 0.4);
    }
    glBindTexture(GL_TEXTURE_2D, texture[backTextureIndex]);
    glDrawElements(GL_TRIANGLE_STRIP, stripLength, GL_UNSIGNED_SHORT, backStrip);
    
    if ( hasSinglePage ) {
        glDisable(GL_TEXTURE_2D);
        glBlendFunc(GL_ONE_MINUS_DST_ALPHA,GL_ONE);
        glColor4f(1.0, 1.0, 1.0, 1.0);
        glDrawElements(GL_TRIANGLE_STRIP, stripLength, GL_UNSIGNED_SHORT, backStrip);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_TEXTURE_2D);
        
        glColor4f(1.0, 1.0, 1.0, 1.0);
    }
    
    [self drawShaderWithEffects:effects];
    [self drawInnerShadowWithEffects:effects andObject:obj];
    [self drawOuterShadowWithEffects:effects andObject:obj];
    glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_ONE);
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textures);
    
    // Draw the front page
    glBindTexture(GL_TEXTURE_2D, texture[frontTextureIndex]);
    glDrawElements(GL_TRIANGLE_STRIP, stripLength, GL_UNSIGNED_SHORT, frontStrip);
    
#else
    
    const GLushort  *frontFaces = [obj frontFaces];
    const GLushort  *backFaces  = [obj backFaces];
    GLuint      numFaces  = [obj numFaces];
    
    // Draw the back page
    glBindTexture(GL_TEXTURE_2D, texture[backTextureIndex]);
    glDrawElements(GL_TRIANGLES, numFaces * 3, GL_UNSIGNED_SHORT, backFaces);
    
    [self drawShaderWithEffects:effects];
    
    glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_DST_ALPHA);
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textures);
    
    // Draw the front page
    glBindTexture(GL_TEXTURE_2D, texture[frontTextureIndex]);
    glDrawElements(GL_TRIANGLES, numFaces * 3, GL_UNSIGNED_SHORT, frontFaces);
    
#endif
    
    // This application only creates a single color renderbuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
}

- (void)drawShaderWithEffects:(id)effects
{     
    // shader
     
    glBlendFunc(GL_DST_COLOR, GL_ONE_MINUS_SRC_ALPHA);

    const Vertex2f *shaderVertices = [effects shaderVertices];
    const Vertex2f *shaderCoords = [effects shaderCoords];
    
    glBindTexture(GL_TEXTURE_2D, texture[4]);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    glVertexPointer(2, GL_FLOAT, 0, shaderVertices);
    glTexCoordPointer(2, GL_FLOAT, 0, shaderCoords);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)drawInnerShadowWithEffects:(id)effects andObject:(id)obj
{
    
    glBlendFunc(GL_ONE_MINUS_DST_ALPHA, GL_DST_ALPHA);

    const Vertex3f  *vertices   = [obj innerShadowVertices];
    const Vertex2f  *textures   = [obj textureArray];
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textures);
    
    const GLushort  *backStrip  = [obj backStrip];
    GLuint   stripLength  = [obj stripLength];
    
    // Draw the back page
    glBindTexture(GL_TEXTURE_2D, texture[5]);
        
    glDrawElements(GL_TRIANGLE_STRIP, stripLength, GL_UNSIGNED_SHORT, backStrip);
    
}

- (void)drawOuterShadowWithEffects:(id)effects andObject:(id)obj
{
    return;
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    //glBlendFunc(GL_ONE, GL_ONE);
    
    const Vertex3f  *vertices   = [obj outerShadowVertices];
    const Vertex2f  *textures   = [obj textureArray];
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, textures);
    
    const GLushort  *frontStrip  = [obj frontStrip];
    GLuint   stripLength  = [obj stripLength];
    
    // Draw the back page
    glBindTexture(GL_TEXTURE_2D, texture[5]);
        
    glDrawElements(GL_TRIANGLE_STRIP, stripLength, GL_UNSIGNED_SHORT, frontStrip);
    
}

- (void)dealloc
{
  // Tear down GL
  if (defaultFramebuffer)
  {
    glDeleteFramebuffersOES(1, &defaultFramebuffer);
    defaultFramebuffer = 0;
  }
  
  if (colorRenderbuffer)
  {
    glDeleteRenderbuffersOES(1, &colorRenderbuffer);
    colorRenderbuffer = 0;
  }
  
  // Tear down context
  if ([EAGLContext currentContext] == context)
    [EAGLContext setCurrentContext:nil];
  
  [context release];
  context = nil;
  
  [super dealloc];
}

@end
