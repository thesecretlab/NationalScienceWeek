//
//  EventDetailViewController.h
//  NSWApp
//
//  Created by Nicholas Wittison on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <EventKitUI/EventKitUI.h>

typedef enum  {
    EventDetailPositionTopRow = 0,
    EventDetailPositionDetail,
    EventDetailPositionContact,
    EventDetailPositionTitle,
    EventDetailPositionAddress
} EventDetailPosition;

@interface EventDetailViewController : UIViewController <EKEventEditViewDelegate>
{
    float currentLayoutHeight;
}
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventAddressLabel;
@property (weak, nonatomic) IBOutlet UITextView *eventContactTextView;
@property (weak, nonatomic) IBOutlet UILabel *eventContactLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *openInSafariLabel;

@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;
@property (strong, nonatomic) NSDictionary *event;
@property (weak, nonatomic) IBOutlet UILabel *eventWebsiteLabel;
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
- (IBAction)openInMaps:(id)sender;
- (IBAction)createEvent:(id)sender;
- (IBAction)openInSafari:(id)sender;
- (IBAction)favouriteEvent:(id)sender;

-(void)refreshDetailedEventData;
- (void)positionLabelOnScreen:(UILabel *)currentLabel withFont:(UIFont *)fontForLabel sizeForMinumumLabel:(float)sizeForMinumumLabel bufferToNextLabel:(float)bufferToNextLabel;  
-(void)positionLabelViewOnScreen:(UIView*)currentView withLabel:(UILabel*)currentLabel bufferToNextView:(float)bufferToNextView;

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action;

@end
