//
//  PSDrawings.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 28/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSDrawings.h"


CGMutablePathRef PSCreatePagePath( CGRect rect, CGFloat padding, CGFloat span ) 
{
    CGFloat radius = rect.size.height * 0.05;
    CGFloat sp = radius * 0.25;
    CGFloat dpadding = span;
    CGFloat ox = rect.origin.x;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint( path, NULL, 0.0, sp + padding );
    CGPathAddQuadCurveToPoint( path, NULL, ox, 0.0 + padding, radius + padding, 0.0 + padding );
    CGPathAddLineToPoint( path, NULL, rect.size.width - dpadding, 0.0 + padding );
    CGPathAddLineToPoint( path, NULL, rect.size.width - dpadding, rect.size.height - padding );
    CGPathAddLineToPoint( path, NULL, radius + padding, rect.size.height - padding );
    CGPathAddQuadCurveToPoint( path, NULL, ox, rect.size.height - padding, ox, rect.size.height - sp - padding );
    CGPathAddLineToPoint( path, NULL, ox, sp + padding );
    return path;
}

CGMutablePathRef PSCreatePageSquarePath( CGRect rect, CGFloat padding, CGFloat span ) 
{
    CGFloat dpadding = span;
    CGFloat ox = rect.origin.x;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint( path, NULL, ox, padding );
    CGPathAddLineToPoint( path, NULL, rect.size.width - dpadding, 0.0 + padding );
    CGPathAddLineToPoint( path, NULL, rect.size.width - dpadding, rect.size.height - padding );
    CGPathAddLineToPoint( path, NULL, ox, rect.size.height - padding );
    CGPathAddLineToPoint( path, NULL, ox, padding );
    return path;
}

unsigned int PSNextPOT( unsigned int x ) {
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >>16);
    return x + 1;
}

CGPoint PSVector( CGPoint firstPoint, CGPoint secondPoint ) 
{
	return CGPointMake( firstPoint.x - secondPoint.x, firstPoint.y - secondPoint.y );
}

CGFloat PSDistance( CGPoint firstPoint, CGPoint secondPoint ) 
{
	return sqrtf( powf( firstPoint.x - secondPoint.x, 2 ) + powf( firstPoint.y - secondPoint.y, 2 ) );
}

CGFloat PSAngle( CGPoint firstPoint, CGPoint secondPoint )
{
	return acosf( PSVector( firstPoint, secondPoint ).x / PSDistance( firstPoint, secondPoint) );
}

CGFloat PSQuad( CGFloat ft, CGFloat f0, CGFloat f1 )
{
    return f0 + (f1 - f0) * ft * ft;	
}

CGFloat PSLinear( CGFloat ft, CGFloat f0, CGFloat f1 )

{
    return f0 + (f1 - f0) * ft;	
}

CGFloat PSPower( CGFloat ft, CGFloat f0, CGFloat f1, CGFloat p )
{
    return f0 + (f1 - f0) * powf(ft, p);
}
