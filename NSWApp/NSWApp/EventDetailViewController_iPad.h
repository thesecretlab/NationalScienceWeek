//
//  EventDetailViewController_iPad.h
//  NSWApp
//
//  Created by Nicholas Wittison on 14/06/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <EventKitUI/EventKitUI.h>

@interface EventDetailViewController_iPad : UIViewController
{
    float currentLayoutHeight;
}
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventAddressLabel;
@property (weak, nonatomic) IBOutlet UITextView *eventContactTextView;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *openInSafariLabel;

@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;
@property (strong, nonatomic) NSDictionary *event;
@property (weak, nonatomic) IBOutlet MKMapView *eventMapView;
@property (weak, nonatomic) IBOutlet UIButton *openInMapsButton;
@property (weak, nonatomic) IBOutlet UIScrollView *labelScrollView;
@property (weak, nonatomic) IBOutlet UIView *eventDateView;
@property (weak, nonatomic) IBOutlet UIView *eventTimeView;
@property (weak, nonatomic) IBOutlet UIView *eventMapHolderView;
@property (weak, nonatomic) IBOutlet UIView *onlineOnlyOpenInSafariView;
@property (weak, nonatomic) IBOutlet UIView *eventDetailView;
@property (weak, nonatomic) IBOutlet UIView *eventAddressView;
@property (weak, nonatomic) IBOutlet UIView *topRowView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favouriteButton;
@property (weak, nonatomic) IBOutlet UIView *eventContactView;

- (void)updateAndRelayoutView;

@end
