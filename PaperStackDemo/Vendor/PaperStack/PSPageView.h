//
//  PSPageView.h
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 25/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSDrawings.h"

@class PSPageView;

@protocol PSPageViewDatasource <NSObject>

- (UIView*)pageViewForPage:(PSPageView*)pageView;

@end

@protocol PSPageViewDelegate <NSObject>
@optional
- (void)pageViewDidFinishLoadContentForPage:(PSPageView*)pageView;

@end

@interface PSPageView : UIView {
    
}

@property (nonatomic, assign) id<PSPageViewDatasource> datasource;
@property (nonatomic, assign) id<PSPageViewDelegate> delegate;
@property (nonatomic, assign) NSDictionary *properties;
@property (nonatomic, assign) BOOL flipped;

- (void)setFlippedFlag;
- (void)pageDidRotateWithPageOrientation:(PSPagesViewPageOrientation)orientation;

- (UIImage*)textureData;
- (CGRect)textureRect;
- (CGRect)textureBounds;

@end
