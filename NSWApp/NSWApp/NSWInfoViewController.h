//
//  NSWInfoViewController.h
//  NSWApp
//
//  Created by Nicholas Wittison on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSWInfoViewController : UIViewController <UIWebViewDelegate>
{
    BOOL hasContent;
}
@property (weak, nonatomic) IBOutlet UIImageView *backgroundColourView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *internetDownMessage;
@property (strong, nonatomic) NSError *error;
@end
