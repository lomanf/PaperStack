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

@property (nonatomic, assign) UIImageView *pageContent;
@property (nonatomic, assign) BOOL flipped;
@property (nonatomic, assign) BOOL isLandscape;

- (void)pageFlipStartWithTarget:(CGFloat)value;
- (void)pageFlipEnd;
- (void)pageFlipTo:(CGFloat)value;

- (void)pageWillRotate;
- (void)pageDidRotate;

@end
