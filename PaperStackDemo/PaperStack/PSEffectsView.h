//
//  PSEffectsView.h
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 09/06/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSEffectsView : UIView {
    
}

- (void)updateCurlPath:(CGPathRef)path withShadow:(CGPathRef)shadow time:(CGFloat)time angle:(CGFloat)angle point:(CGPoint)point theta:(CGFloat)theta;

@end
