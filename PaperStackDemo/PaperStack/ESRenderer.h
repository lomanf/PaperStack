//
//  ESRenderer.h
//  ConeCurl
//
//  Created by W. Dana Nuon on 4/18/10.
//  Copyright lunaray 2010. All rights reserved.
//
//  Modified from Xcode OpenGL ES template. Replaced -render method with -renderObject: to allow passing in
//  of arbitrary object data so the renderer isn't responsible for keeping model state.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@protocol ESRendererDataSource <NSObject>

- (UIImage*)rendererGetFrontTexture;
- (UIImage*)rendererGetBackTexture;
- (UIImage*)rendererGetShaderTexture;
- (CGRect)rendererGetFrontTextureRect;
- (CGRect)rendererGetBackTextureRect;
- (CGRect)rendererGetFrontTextureBounds;
- (CGRect)rendererGetBackTextureBounds;

@end

@protocol ESRenderer <NSObject>

- (void)loadTextures;
- (void)loadEffects;
- (void)setupView:(CAEAGLLayer *)layer;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)renderObject:(id)obj withEffects:(id)effects;

@property (nonatomic, assign) id<ESRendererDataSource> datasource;

@end

