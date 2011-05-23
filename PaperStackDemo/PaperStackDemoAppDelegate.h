//
//  PaperStackDemoAppDelegate.h
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 24/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PaperStackDemoViewController;

@interface PaperStackDemoAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PaperStackDemoViewController *viewController;

@end
