//
//  PSPageView.h
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 25/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PSPageView : UIView {
    
}

@property (nonatomic, assign) BOOL flipped;

- (void)setFlippedFlag;

- (void)pageFlipStartWithTarget:(CGFloat)value;
- (void)pageFlipEnd;
- (void)pageFlipTo:(CGFloat)value;

- (void)pageWillRotateToOrientation:(UIDeviceOrientation)orientation;
- (void)pageDidRotate;

- (UIImage*)textureData;
- (CGRect)textureRect;
- (CGRect)textureBounds;

@end
