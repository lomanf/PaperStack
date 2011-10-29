//
//  PaperStackDemoViewController.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 24/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PaperStackDemoViewController.h"
#import "PSPDFPageViewController.h"

@implementation PaperStackDemoViewController

- (void)dealloc
{
    CGPDFDocumentRelease(pdf);
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Actions

- (IBAction)launchPlayer
{
    PSPagesViewController *aController = [[PSPagesViewController alloc] initWithNibName:nil bundle:nil];
    aController.datasource = self;
    aController.shouldUseInitialEmptyLeftPage = NO;
    [self.navigationController pushViewController:aController animated:YES];
    [aController release];
    
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // load pdf
    CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("book.pdf"), NULL, NULL);
    pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);

}

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

#pragma mark -
#pragma mark - PSPagesViewControllerDatasource

- (NSUInteger)pagesNumberOfControllers
{
    return CGPDFDocumentGetNumberOfPages(pdf);
}

- (UIViewController*)pagesPageViewControllerAtIndex:(NSUInteger)index
{
    CGPDFPageRef page = CGPDFDocumentGetPage(pdf, index+1);
    PSPDFPageViewController *aController = [[PSPDFPageViewController alloc] initwithPDFPage:page];
    return [aController autorelease];
}

@end
