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

@interface PSPlayerController : UIViewController <ESRendererDataSource> {
@private
    
}

@property (nonatomic, retain) IBOutlet EAGLView *glView;

@end
