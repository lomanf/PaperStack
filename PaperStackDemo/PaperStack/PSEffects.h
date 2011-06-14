//
//  PSEffectsView.h
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 09/06/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESCommon.h"

@interface PSEffects : NSObject {
    Vertex2f *shaderVertices_;
    Vertex2f *shaderCoords_;
}

@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, retain) UIImage *renderImage;

- (void)buildEffects;
- (void)updateCurlPath:(CGPathRef)path withShadow:(CGPathRef)shadow time:(CGFloat)time angle:(CGFloat)angle point:(CGPoint)point theta:(CGFloat)theta;

- (const Vertex2f *)shaderVertices;
- (const Vertex2f *)shaderCoords;

@end
