//
//  EventsMapViewController.h
//  NSWApp
//
//  Created by Nicholas Wittison on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NSWEventData.h"
@interface EventsMapViewController : UIViewController <NSWEventDataDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *eventMap;
- (IBAction)findClosestEvent:(id)sender;
- (IBAction)centerOnUser:(id)sender;

- (void)plotEvents;
- (void)newDataWasDownloaded;

@property (nonatomic, strong) NSString* lastLocationShown;
@end
