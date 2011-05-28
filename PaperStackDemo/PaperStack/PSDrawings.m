//
//  PSDrawings.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 28/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSDrawings.h"


CGMutablePathRef PSCreatePagePath( CGRect rect, CGFloat padding, CGFloat span ) {
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

CGMutablePathRef PSCreatePageSquarePath( CGRect rect, CGFloat padding, CGFloat span ) {
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

CGPoint PSVectorBetweenPoints(CGPoint firstPoint, CGPoint secondPoint) {
	// NSLog(@"Point One: %f, %f", firstPoint.x, firstPoint.y);
	// NSLog(@"Point Two: %f, %f", secondPoint.x, secondPoint.y);
	
	CGFloat xDifference = firstPoint.x - secondPoint.x;
	CGFloat yDifference = firstPoint.y - secondPoint.y;
	
	CGPoint result = CGPointMake(xDifference, yDifference);
	
	return result;
}

CGFloat PSDistanceBetweenPoints(CGPoint firstPoint, CGPoint secondPoint) {
	CGFloat distance;
	
	//Square difference in x
	CGFloat xDifferenceSquared = pow(firstPoint.x - secondPoint.x, 2);
	// NSLog(@"xDifferenceSquared: %f", xDifferenceSquared);
	
	// Square difference in y
	CGFloat yDifferenceSquared = pow(firstPoint.y - secondPoint.y, 2);
	// NSLog(@"yDifferenceSquared: %f", yDifferenceSquared);
	
	// Add and take Square root
	distance = sqrt(xDifferenceSquared + yDifferenceSquared);
	// NSLog(@"Distance: %f", distance);
	return distance;
	
}

CGFloat PSAngleBetweenCGPoints(CGPoint firstPoint, CGPoint secondPoint)
{
	CGPoint previousDifference = PSVectorBetweenPoints(firstPoint, secondPoint);
	CGFloat xDifferencePrevious = previousDifference.x;
    
	CGFloat previousDistance = PSDistanceBetweenPoints(firstPoint,
													 secondPoint);
	CGFloat previousRotation = acosf(xDifferencePrevious / previousDistance); 
	
	return previousRotation;
}
