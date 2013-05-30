//
//  NSWInfoViewController.m
//  NSWApp
//
//  Created by Nicholas Wittison on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSWInfoViewController.h"

@interface NSWInfoViewController ()

@end

@implementation NSWInfoViewController
@synthesize backgroundColourView;
@synthesize spinner;
@synthesize webView;
@synthesize internetDownMessage, error;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        hasContent = NO;
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    //WILL CURRENTLY LOAD EVERY TIME ITS TAPPED.
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.scienceweek.secretlab.com.au/scienceweekinfo.html"]]];
    [self.internetDownMessage setHidden:YES];
    
    if (self.error) {
        [self.spinner startAnimating];
    }
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)newError
{
    if (!hasContent) {
    [self.internetDownMessage setHidden:NO];
    [self.spinner stopAnimating];
    [self.backgroundColourView setHidden:NO];
    self.error = newError;
    NSLog(@"Error %@", newError);
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.error = nil;
    [self.internetDownMessage setHidden:YES];

    [self.spinner stopAnimating];
    [self.backgroundColourView setHidden:YES];
    hasContent = YES;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    return YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setBackgroundColourView:nil];
    [self setSpinner:nil];
    [self setWebView:nil];
    [self setInternetDownMessage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
