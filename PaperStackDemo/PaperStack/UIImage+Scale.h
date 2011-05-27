//
//  UIImage+Scale.h
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 25/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage( Scale )

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
