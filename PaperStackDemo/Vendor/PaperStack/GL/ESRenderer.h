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

- (BOOL)rendererHasSinglePage;
- (BOOL)rendererisRightPage; 
- (UIImage*)rendererGetRightFrontTexture;
- (UIImage*)rendererGetRightBackTexture;
- (UIImage*)rendererGetLeftFrontTexture;
- (UIImage*)rendererGetLeftBackTexture;
- (UIImage*)rendererGetShaderTexture;
- (UIImage*)rendererGetInnerShadowTexture;
- (CGRect)rendererGetRightFrontTextureRect;
- (CGRect)rendererGetRightBackTextureRect;
- (CGRect)rendererGetLeftFrontTextureRect;
- (CGRect)rendererGetLeftBackTextureRect;
- (CGRect)rendererGetRightFrontTextureBounds;
- (CGRect)rendererGetRightBackTextureBounds;
- (CGRect)rendererGetLeftFrontTextureBounds;
- (CGRect)rendererGetLeftBackTextureBounds;

@end

@protocol ESRenderer <NSObject>

- (void)loadTextures;
- (void)loadEffects;
- (void)setupView:(CAEAGLLayer *)layer;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (void)renderObject:(id)obj withEffects:(id)effects;

@property (nonatomic, assign) id<ESRendererDataSource> datasource;
@property (nonatomic, assign) CGFloat orthoTranslate;

@end

