//
//  PSPDFPageViewController.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 15/09/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PSPDFPageViewController.h"
#import "PSPDFPageView.h"

@interface PSPDFPageViewController()

@property (nonatomic, assign) CGPDFPageRef pdfPageRef;

@end

@implementation PSPDFPageViewController

@synthesize pdfPageRef;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initwithPDFPage:(CGPDFPageRef)pdfPage
{
    self = [self initWithNibName:nil bundle:nil];
    if ( self ) {
        self.pdfPageRef = pdfPage;
        PSPDFPageView *pdfView = [[PSPDFPageView alloc] initWithPDFPage:pdfPage];
        self.view = pdfView;
        [pdfView release];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

@end
