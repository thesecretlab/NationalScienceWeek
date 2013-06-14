//
//  NSWEventData.h
//  NSWApp
//
//  Created by Nicholas Wittison on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol NSWEventDataDelegate <NSObject>

@optional

- (void)newDataWasDownloaded;
- (void)reloadView;
@end

@interface NSWEventData : NSObject <CLLocationManagerDelegate> 
{
    CLLocationManager *locationManager;

    NSMutableArray *locationMeasurements;
    CLLocation *bestEffortAtLocation;

    int currentLocationCounter;
    BOOL datesNeedUpdating;
}
+ (NSWEventData*)sharedData;
@property (nonatomic, strong) NSMutableArray *eventData;
@property (nonatomic, strong) NSMutableArray *locationMeasurements;
@property (nonatomic, strong) NSMutableArray *eventsForLocation;
@property (nonatomic, strong) NSMutableArray *favouriteEvents;

@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSArray* locationValues;
@property (nonatomic, strong) NSArray* uniqueDatesForLocation;

@property (nonatomic, strong) NSNumber* latestVersionNumber;
@property (nonatomic, strong) id<NSWEventDataDelegate> delegate;
@property (nonatomic, strong) id<NSWEventDataDelegate> favouritesDelegate;
@property (nonatomic, strong) id<NSWEventDataDelegate> mapsDelegate;


-(void)loadCSVEventsFromCSVFile;
-(void)loadFromFile;
-(void)saveToFile;
-(NSArray*)eventsForDate:(NSString*) date;
-(NSArray*)uniqueSingleDates;
-(void)changeLocation:(NSString*)newLocation;
-(void)refilterEventsForLocation;
-(NSArray*)multiDateEvents;
-(void)previousLocation;
-(void)nextLocation;
-(void)updateEventDataFromDownload:(NSString*)newCSVData;
-(NSDictionary*)eventForKey:(NSString*)eventKey;
-(void)checkUsersLocation;
-(NSArray*)uniqueSingleDatesForFavourites;
-(NSArray*)eventsForDateInFavourites:(NSString*) date;
-(BOOL)favouritesArrayContainsEventWithID:(NSString*)eventID;
-(void)removeEventFromFavouritesArrayWithID:(NSString*)eventID;
-(void)addEventToFavouritesArray:(NSDictionary*)event;

@end
