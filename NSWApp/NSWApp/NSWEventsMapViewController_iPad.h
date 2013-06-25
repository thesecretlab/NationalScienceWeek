//
//  NSWEventsMapViewController_iPad.h
//  NSWApp
//
//  Created by Nicholas Wittison on 26/06/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NSWEventData.h"

@interface NSWEventsMapViewController_iPad : UIViewController <NSWEventDataDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *eventMap;
- (IBAction)findClosestEvent:(id)sender;
- (IBAction)centerOnUser:(id)sender;

- (void)plotEvents;
- (void)newDataWasDownloaded;

@property (nonatomic, strong) NSString* lastLocationShown;
@end
