//
//  PSPlayerController.h
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 25/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSPageView.h"
#import "ESRenderer.h"
#import "EAGLView.h"
#import "PSDrawings.h"

@protocol PSPagesViewControllerDatasource <NSObject>

- (NSUInteger)pagesNumberOfControllers;
- (UIViewController*)pagesPageViewControllerAtIndex:(NSUInteger)index;

@end

@interface PSPagesViewController : UIViewController <ESRendererDataSource, PSPageViewDatasource, PSPageViewDelegate> {
@private
    id<PSPagesViewControllerDatasource> datasource;
    NSUInteger pageIndex;
    BOOL pageShouldCurl;
    BOOL needsAdjustGLView;
}

@property (nonatomic, assign) id<PSPagesViewControllerDatasource> datasource;
@property (nonatomic, assign) BOOL shouldUseInitialEmptyLeftPage;
@property (nonatomic, assign) PSPagesViewPageOrientation pageOrientation;
@property (nonatomic, readonly) UIViewController *leftPageViewController;
@property (nonatomic, readonly) UIViewController *rightPageViewController;

@end
