//
//  NSWInfoViewController_iPad.m
//  NSWApp
//
//  Created by Nicholas Wittison on 17/06/13.
//
//

#import "NSWInfoViewController_iPad.h"

@interface NSWInfoViewController_iPad ()

@end

@implementation NSWInfoViewController_iPad

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
