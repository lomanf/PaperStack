//
//  PSDrawings.h
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 28/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
	kPSDrawingsPixelFormat_Automatic = 0,
	//! 32-bit texture: RGBA8888
	kPSDrawingsPixelFormat_RGBA8888,
	//! 16-bit texture without Alpha channel
	kPSDrawingsPixelFormat_RGB565,
	//! 8-bit textures used as masks
	kPSDrawingsPixelFormat_A8,
	//! 16-bit textures: RGBA4444
	kPSDrawingsPixelFormat_RGBA4444,
	//! 16-bit textures: RGB5A1
	kPSDrawingsPixelFormat_RGB5A1,	
    
	//! Default texture format: RGBA8888
	kPSDrawingsPixelFormat_Default = kPSDrawingsPixelFormat_RGBA8888
	
} PSDrawingsPixelFormat;


CGMutablePathRef PSCreatePagePath( CGRect rect, CGFloat padding, CGFloat span );

CGMutablePathRef PSCreatePageSquarePath( CGRect rect, CGFloat padding, CGFloat span );


unsigned int PSNextPOT( unsigned int x );

CGPoint PSVector( CGPoint firstPoint, CGPoint secondPoint );

CGFloat PSDistance( CGPoint firstPoint, CGPoint secondPoint );

CGFloat PSAngle( CGPoint firstPoint, CGPoint secondPoint );

CGFloat PSQuad( CGFloat ft, CGFloat f0, CGFloat f1 );

CGFloat PSLinear( CGFloat ft, CGFloat f0, CGFloat f1 );

CGFloat PSPower( CGFloat ft, CGFloat f0, CGFloat f1, CGFloat p );

