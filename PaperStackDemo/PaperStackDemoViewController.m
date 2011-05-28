//
//  PaperStackDemoViewController.m
//  PaperStackDemo
//
//  Created by Lorenzo Manfredi on 24/05/11.
//  Copyright 2011 Mutado. All rights reserved.
//

#import "PaperStackDemoViewController.h"
#import "PSPlayerController.h"

@implementation PaperStackDemoViewController

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

#pragma mark - Actions

- (IBAction)launchPlayer
{
    PSPlayerController *ac = [[PSPlayerController alloc] initWithNibName:@"PSPlayerController" bundle:nil];
    [self.navigationController pushViewController:ac animated:YES];
    [ac release];
    
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
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

@end
