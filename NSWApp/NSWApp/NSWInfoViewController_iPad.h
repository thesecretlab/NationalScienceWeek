//
//  NSWInfoViewController_iPad.h
//  NSWApp
//
//  Created by Nicholas Wittison on 17/06/13.
//
//

#import <UIKit/UIKit.h>

@interface NSWInfoViewController_iPad : UIViewController
{
    BOOL hasContent;
}
@property (weak, nonatomic) IBOutlet UIImageView *backgroundColourView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) id delegate;
- (IBAction)dismissModalView:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *internetDownMessage;
@property (strong, nonatomic) NSError *error;
@end
