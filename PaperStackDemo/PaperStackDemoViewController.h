//
//  PaperStackDemoViewController.h
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 24/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSPagesViewController.h"

@interface PaperStackDemoViewController : UIViewController <PSPagesViewControllerDatasource> {
    CGPDFDocumentRef pdf;
}

- (IBAction)launchPlayer;

@end
