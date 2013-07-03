//
//  NSWEventData.m
//  NSWApp
//
//  Created by Nicholas Wittison on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSWEventData.h"
#import "CHCSV.h"
#import "TouchXML.h"
static NSWEventData* _sharedData = nil;

@implementation NSWEventData
@synthesize eventData, location, eventsForLocation, locationValues, latestVersionNumber, delegate, locationMeasurements, favouriteEvents, favouritesDelegate, mapsDelegate;

+ (NSWEventData*)sharedData {
    if (_sharedData == nil) 
    {  
        _sharedData = [[NSWEventData alloc] init];
        _sharedData.locationValues = [NSArray arrayWithObjects:@"TAS", @"QLD", @"NT", @"SA", @"WA", @"ACT", @"VIC", @"NSW", nil];
        [_sharedData setCurrentLocationCounter:0];
        _sharedData.latestVersionNumber = [NSNumber numberWithInt:-1];
        _sharedData.locationMeasurements = [NSMutableArray array];
        _sharedData.favouriteEvents = [NSMutableArray array];
        _sharedData.shouldRevertToBakedInData = NO;
        [_sharedData loadFromFile];

    }
    
    return _sharedData;
}

-(void)setCurrentLocationCounter:(int)newValue
{
    currentLocationCounter = newValue;
}

-(void)saveToFile
{
    NSLog(@"Saving...");
    NSMutableDictionary *saveDict = [NSMutableDictionary dictionary];
    [saveDict setValue:self.eventData forKey:@"eventData"];
    [saveDict setValue:self.location forKey:@"location"];
    [saveDict setValue:self.latestVersionNumber forKey:@"latestVersion"];
    [saveDict setValue:self.favouriteEvents forKey:@"favouriteEvents"];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/NSWEventData.sav"];
    [saveDict writeToFile:filePath atomically:YES];
    
}

-(void)loadFromFile
{
    NSLog(@"Loading Data..");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/NSWEventData.sav"];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    
    if (fileExists) {
        NSDictionary *loadDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
        self.eventData =   [NSMutableArray arrayWithArray:[loadDict valueForKey:@"eventData"]];
        self.favouriteEvents =   [NSMutableArray arrayWithArray:[loadDict valueForKey:@"favouriteEvents"]];
        [self changeLocation:[NSString stringWithString:[loadDict valueForKey:@"location"]]];
        self.latestVersionNumber = [loadDict valueForKey:@"latestVersion"];
        [self refilterEventsForLocation];
    }
    else {
        self.eventData = [NSMutableArray array];
        self.favouriteEvents = [NSMutableArray array];
        [self changeLocation:@"TAS"];
        self.latestVersionNumber = [NSNumber numberWithInt:-1];
        [self loadXMLPreBakedData]; //TAKE AWAY IF YOU DON'T WANT DEFAULT LOADING DONE
        
    }
    
}

-(void)loadXMLPreBakedData
{
    NSString * file = [[NSBundle bundleForClass:[self class]] pathForResource:@"scienceweek-events" ofType:@"xml"];
	//NSLog(@"%@", file);
    NSError * error = nil;

    NSString *fileAsString = [NSString stringWithContentsOfFile:file encoding:NSASCIIStringEncoding error:&error];
    //NSLog(@"%@", error);

    self.latestVersionNumber = [NSNumber numberWithInt:-1];
    [self updateEventDataFromDownload:fileAsString withVersionNumber:[NSNumber numberWithInt:-1]];
    //[self saveToFile];
    
}

-(void)revertDataAndStopDownload
{
    _shouldRevertToBakedInData = YES;
    [self loadXMLPreBakedData];
}

-(void)resumeNormalUpdates
{
    _shouldRevertToBakedInData = NO;
}

/*
-(void)loadCSVEventsFromCSVFile
{
    
    NSString * file = [[NSBundle bundleForClass:[self class]] pathForResource:@"NSWkAPPSpreadsheet" ofType:@"csv"];
	
	NSStringEncoding encoding = 0;
	NSError * error = nil;
	NSArray * fields = [NSArray arrayWithContentsOfCSVFile:file usedEncoding:&encoding error:&error];
    //NSLog(@"read: %@", fields);
    self.latestVersionNumber = [NSNumber numberWithInt:-1];

    [self processNewEventsArray:fields];
    
    [self saveToFile];
}
 */

-(void)updateEventDataFromDownload:(NSString*)newCSVData withVersionNumber:(NSNumber*)newVersionNumber
{

    //NSLog(@"Data definately here: %@", newCSVData);
    
    if (_shouldRevertToBakedInData == YES && [newVersionNumber intValue] != -1) {
        NSLog(@"Not Processing data because staying with baked in");
        return;
    }
    
    datesNeedUpdating = YES;
    NSError *error;
    CXMLDocument *rssParser = [[CXMLDocument alloc] initWithXMLString:newCSVData options:0 error:&error];
    
    //NSLog(@"ERROR: %@",error);
    
    if (error == nil) {
        RXMLElement *rootXML = [RXMLElement elementFromXMLString:newCSVData encoding:NSUTF8StringEncoding];

        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingString:@"/LastKnownGoodXML.xml"];
        
        [newCSVData writeToFile:filePath atomically:YES
                       encoding:NSUTF8StringEncoding error:&error];
        __block NSMutableArray *fields = [NSMutableArray array];
       __block NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        
        [rootXML iterate:@"Event" usingBlock: ^(RXMLElement *event) {
            NSMutableDictionary *eventDict = [NSMutableDictionary dictionary];
            
            [eventDict setObject:[NSString stringWithFormat:@"%@",[event child:@"EventID"].text] forKey:@"Event ID"];
            [eventDict setObject:[NSString stringWithFormat:@"%@",[event child:@"EventName"].text] forKey:@"Title"];
            
            [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];

            NSDate *startDate = [dateFormatter dateFromString:[event child:@"EventStart"].text];
             NSDate *endDate = [dateFormatter dateFromString:[event child:@"EventEnd"].text];
            //NSLog(@"Date: %@, %@", startDate, endDate);

            [dateFormatter setDateFormat:@"dd/MM/yyyy"];
            
            [eventDict setObject:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:startDate]]  forKey:@"Date"];
            [eventDict setObject:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:endDate]]  forKey:@"End Date"];

            if ([endDate timeIntervalSinceDate:startDate]<60*60*24) //<-Seconds in a day
            {
                [eventDict setObject:[NSString stringWithFormat:@""] forKey:@"End Date"];
            }
            
            [dateFormatter setDateFormat:@"hh:mm a"];

            [eventDict setObject:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:startDate]]  forKey:@"Start Time"];
            [eventDict setObject:[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:endDate]]  forKey:@"End Time"];
            
            if ([event child:@"EventDescription"].text) {
                [eventDict setObject:[NSString stringWithFormat:@"%@",[event child:@"EventDescription"].text] forKey:@"Description"];
            }
            if ([event child:@"EventTargetAudience"].text) {
                [eventDict setObject:[NSString stringWithFormat:@"%@\n\nFor: %@", [eventDict objectForKey:@"Description"],[event child:@"EventTargetAudience"].text]  forKey:@"Description"];
            }
            
            if ([[event child:@"EventIsFree"].text isEqualToString:@"true"])
            {
                [eventDict setObject:[NSString stringWithFormat:@"%@\n\nEvent Price: %@", [eventDict objectForKey:@"Description"], @"Free"]  forKey:@"Description"];
            }
            else
            {
                [eventDict setObject:[NSString stringWithFormat:@"%@\n\nEvent Price: %@", [eventDict objectForKey:@"Description"],[event child:@"EventPayment"].text]  forKey:@"Description"];
            }


            
            //[eventDict setObject:[NSString stringWithFormat:@"%@\n\nFor: %@ \n\nEvent Price: %@",[event child:@"EventDescription"].text,[event child:@"EventTargetAudience"].text,[event child:@"EventPayment"].text] forKey:@"Description"];
            
            [eventDict setObject:@"" forKey:@"Latitude"];
            [eventDict setObject:@"" forKey:@"Longitude"];
            
            RXMLElement *venue = [event child:@"Venue"];
            //NSLog(@"Venue: %@", venue);
            if (venue != nil)
            {
                [eventDict setObject:[NSString stringWithFormat:@"%@", [venue child:@"VenueName"].text] forKey:@"Location"];
                
                [eventDict setObject:@"" forKey:@"Address"];
                if ([event child:@"VenueStreetName"].text) {
                    [eventDict setObject:[NSString stringWithFormat:@"%@",[event child:@"VenueStreetName"].text] forKey:@"Address"];
                }
                if ([event child:@"VenueSuburb"].text) {
                    [eventDict setObject:[NSString stringWithFormat:@"%@, %@", [eventDict objectForKey:@"Address"],[event child:@"VenueSuburb"].text]  forKey:@"Address"];
                }
                if ([event child:@"VenuePostcode"].text) {
                    [eventDict setObject:[NSString stringWithFormat:@"%@, %@", [eventDict objectForKey:@"Address"],[event child:@"VenuePostcode"].text]  forKey:@"Address"];
                }
                
                if ([venue child:@"VenueLatitude"].text)
                {
                    [eventDict setObject:[NSString stringWithFormat:@"%@", [venue child:@"VenueLatitude"].text] forKey:@"Latitude"];

                }
                if ([venue child:@"VenueLongitude"].text)
                {

                    [eventDict setObject:[NSString stringWithFormat:@"%@", [venue child:@"VenueLongitude"].text] forKey:@"Longitude"];
                }


                //NSString *addressString = [NSString stringWithFormat:@"%@, %@, %@", [venue child:@"VenueStreetName"].text, [venue child:@"VenueSuburb"].text, [venue child:@"VenuePostcode"].text];
                //[eventDict setObject:addressString forKey:@"Address"];
            }
            else
            {
                [eventDict setObject:@"" forKey:@"Location"];
                [eventDict setObject:@"" forKey:@"Address"];
            }
            
                if ([event child:@"EventContactName"].text) {
                    [eventDict setObject:[NSString stringWithFormat:@"%@",[event child:@"EventContactName"].text] forKey:@"Contact"];
                }
                if ([event child:@"EventContactOrganisation"].text) {
                    [eventDict setObject:[NSString stringWithFormat:@"%@\n%@", [eventDict objectForKey:@"Contact"],[event child:@"EventContactOrganisation"].text]  forKey:@"Contact"];
                }
                if ([event child:@"EventContactTelephone"].text) {
                    [eventDict setObject:[NSString stringWithFormat:@"%@\n%@", [eventDict objectForKey:@"Contact"],[event child:@"EventContactTelephone"].text]  forKey:@"Contact"];
                }
                if ([event child:@"EventContactEmail"].text) {
                    [eventDict setObject:[NSString stringWithFormat:@"%@\n%@", [eventDict objectForKey:@"Contact"],[event child:@"EventContactEmail"].text]  forKey:@"Contact"];
                }
                if ([event child:@"EventWebsite"].text) {
                    [eventDict setObject:[NSString stringWithFormat:@"%@\n%@", [eventDict objectForKey:@"Contact"],[event child:@"EventWebsite"].text]  forKey:@"Contact"];
                }
            
            [eventDict setObject:[NSString stringWithFormat:@"%@",[event child:@"EventWebsite"].text] forKey:@"Website"];
            
            
           // [eventDict setObject:[NSString stringWithFormat:@"%@\n%@\n\n%@\n\n%@",[event child:@"EventContactName"].text, [event child:@"EventContactOrganisation"].text, [event child:@"EventContactTelephone"].text, [event child:@"EventContactEmail"].text] forKey:@"Contact"];
            
            //[eventDict setObject:[NSString stringWithFormat:@"%@", [venue child:@"EventWebsite"].text] forKey:@"Website"];



            [eventDict setObject:[NSString stringWithFormat:@"%@", [event child:@"EventState"].text] forKey:@"Region"];  //EXPLICIT STATE REGION DATA NEEDS TO BE INCLUDED IN THE DATA
            [fields addObject:eventDict];
            //NSLog(@"Event: %@", [event child:@"EventName"]);
        }];
        
        //NSArray * fields = nil; //PARSE XML HERE
        
        //[NSArray arrayWithContentsOfCSVFile:filePath usedEncoding:&encoding error:&error];
        
        if (fields) {
            
            self.latestVersionNumber = newVersionNumber;
            [self processNewEventsArray:fields];
            [self revalidateFavourites];
            [self saveToFile];
            if (self.delegate) {
                [self.delegate newDataWasDownloaded];
            }
            if (self.mapsDelegate) {
                [self.mapsDelegate newDataWasDownloaded];
            }
        }
    }
    else
    {
        
        NSError *error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingString:@"/LastKnownGoodXML.xml"];
        
        NSString *xmlRecover = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error];
        NSLog(@"Attempting a recovery");
        if (error == nil) {
            [self updateEventDataFromDownload:xmlRecover withVersionNumber:[NSNumber numberWithInt:-1]];
        }
    }

}

- (void)processNewEventsArray:(NSArray *)fields
{
    /*
    NSMutableArray * csvEventArray = [NSMutableArray array];
    
    for (NSArray *event in fields) {
        if ([fields indexOfObject:event]== 0) {
            
        }
        else {
            int counter = 0;
            NSMutableDictionary *eventDictionary = [NSMutableDictionary dictionary];
            for (NSString *informationField in event) {
                
                [eventDictionary setObject:informationField forKey:[[fields objectAtIndex:0] objectAtIndex:counter]];
                
                counter = counter +1;
            }
            [csvEventArray addObject:eventDictionary];
        }
    }
     */
    //NSLog(@"read: %@", csvEventArray);
    self.eventData = [fields mutableCopy];
    
    [self refilterEventsForLocation];
}





-(NSArray*)uniqueSingleDates
{
    NSLog(@"Getting all dates");
    
    /* OLD NECESSARY WRANGLING

    for(NSMutableDictionary *event in self.eventsForLocation)
    {
        if ([[event objectForKey:@"Date"] length] == 9) {
            [event setObject:[NSString stringWithFormat:@"0%@",[event objectForKey:@"Date"]] forKey:@"Date"];
        }
        if ([[event objectForKey:@"Date"] length] == 10) {

            if (![uniqueDates containsObject:[event objectForKey:@"Date"]])
            {
                [uniqueDates addObject:[event objectForKey:@"Date"]];
            }
            
            
        }
    }
    
    NSMutableArray *arrayOfDates = [NSMutableArray array];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    for (NSString *stringDate in uniqueDates) {
        NSDate *dateObject = [dateFormatter dateFromString:stringDate];
        [arrayOfDates addObject:dateObject];
    }
    */
    

    if (datesNeedUpdating || self.uniqueDatesForLocation == nil) {
        NSLog(@"Processing Dates");
        datesNeedUpdating = NO;
        NSMutableArray *uniqueDates = [NSMutableArray array];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];

        for(NSMutableDictionary *event in self.eventsForLocation)
        {
            NSDate *dateObject = [dateFormatter dateFromString:[event objectForKey:@"Date"]];
            [uniqueDates addObject:dateObject];
        }
        NSMutableArray *arrayOfDates = [NSMutableArray array];

        [arrayOfDates addObjectsFromArray:[[NSSet setWithArray:uniqueDates] allObjects]];
        [arrayOfDates sortUsingSelector:@selector(compare:)];
        
        NSMutableArray *arrayToReturn = [NSMutableArray array];
        
        for (NSDate *currentDate in arrayOfDates) {
            [arrayToReturn addObject:[dateFormatter stringFromDate:currentDate]];
        }
        self.uniqueDatesForLocation = arrayToReturn;
        [self prePrepareOptimised2DEventArray];
        NSLog(@"Done processing dates");
    }

    return self.uniqueDatesForLocation;
}

-(void)prePrepareOptimised2DEventArray
{
    NSMutableArray *twoDeeArray = [NSMutableArray array];
    for (NSString* date in self.uniqueDatesForLocation)
    {
        NSMutableArray *singleDateEvents = [NSMutableArray array];

        for(NSMutableDictionary *event in self.eventsForLocation)
        {
            if ([[event objectForKey:@"Date"] isEqualToString:date]) {
                [singleDateEvents addObject:event];
            }
        }
        [twoDeeArray addObject:singleDateEvents];
    }

    prePrepared2DEventArray = twoDeeArray;

}

-(NSArray*)multiDateEvents
{
    NSMutableArray *multiDates = [NSMutableArray array];
    
    for(NSMutableDictionary *event in self.eventsForLocation)
    {
        if ([[event objectForKey:@"Date"] length] == 9) {
            [event setObject:[NSString stringWithFormat:@"0%@",[event objectForKey:@"Date"]] forKey:@"Date"];
        }
        if ([[event objectForKey:@"Date"] length] != 10) {
                [multiDates addObject:event];
        }
    }

    
    return multiDates;
}

-(NSArray*)eventsForDate:(NSString*) date
{
    
    /* OLD PREOPTIMISEDCODE
    NSMutableArray *singleDateEvents = [NSMutableArray array];
    
    for(NSMutableDictionary *event in self.eventsForLocation)
    {
        if ([[event objectForKey:@"Date"] length] == 9) {
            [event setObject:[NSString stringWithFormat:@"0%@",[event objectForKey:@"Date"]] forKey:@"Date"];
        }
        if ([[event objectForKey:@"Date"] isEqualToString:date]) {
            [singleDateEvents addObject:event];
        }
        
        
    }*/
    
    
    for (NSString* uniqueDate in self.uniqueDatesForLocation)
    {
        if ([uniqueDate isEqualToString:date]) {
            return [prePrepared2DEventArray objectAtIndex:[self.uniqueDatesForLocation indexOfObject:uniqueDate]];
            }
        
    }
    
    return nil;
}

-(NSDictionary*)eventForKey:(NSString*)eventKey
{
    NSMutableDictionary *foundEvent;
    
    for (NSMutableDictionary *event in self.eventsForLocation) {
        if ([[event objectForKey:@"Event ID"] isEqualToString:eventKey]) {
            foundEvent = event;
        }
    }
    return foundEvent;
}


-(void)refilterEventsForLocation
{
    [self changeLocation:self.location];
}

-(void)checkUsersLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.purpose = @"We'll show you events close to where you are.";
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [locationManager startUpdatingLocation];
    
    [self performSelector:@selector(stopUpdatingLocation:) withObject:@"Timed Out" afterDelay:20.0];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [locationMeasurements addObject:newLocation];
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    if (newLocation.horizontalAccuracy < 0) return;
    if (bestEffortAtLocation == nil || bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        bestEffortAtLocation = newLocation;

        if (newLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {

            [self stopUpdatingLocation:@""];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:@"Timed Out"];
        }
    }
}

- (void)setMapCurrentLocationUsingKey:(NSString *)stateInfo {
    NSString *mappedStateChoice;
    
    if ([stateInfo isEqualToString:@"Australian Capital Territory"])
    {
        mappedStateChoice = @"ACT";
    }
    if ([stateInfo isEqualToString:@"New South Wales"])
    {
        mappedStateChoice = @"NSW";
    }
    if ([stateInfo isEqualToString:@"Northern Territory"])
    {
        mappedStateChoice = @"NT";
    }
    if ([stateInfo isEqualToString:@"Queensland"])
    {
        mappedStateChoice = @"QLD";
    }
    if ([stateInfo isEqualToString:@"South Australia"])
    {
        mappedStateChoice = @"SA";
    }
    if ([stateInfo isEqualToString:@"Tasmania"])
    {
        mappedStateChoice = @"TAS";
    }
    if ([stateInfo isEqualToString:@"Victoria"])
    {
        mappedStateChoice = @"VIC";
    }
    if ([stateInfo isEqualToString:@"Western Australia"])
    {
        mappedStateChoice = @"WA";
    }
    
    if (stateInfo == nil) {
        mappedStateChoice = @"TAS";
    }
    
    [self changeLocation:mappedStateChoice];
}

- (void)stopUpdatingLocation:(NSString *)state {
    
    //NSLog(@"Location %@", bestEffortAtLocation);
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    
    if (bestEffortAtLocation != nil) {
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:bestEffortAtLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if ([placemarks objectAtIndex:0])
            {
                [self setMapCurrentLocationUsingKey:[[placemarks objectAtIndex:0] administrativeArea]];
            }
        }];

    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:@""];
    }
}

-(void)changeLocation:(NSString*)newLocation
{
    datesNeedUpdating = YES;
    self.location = newLocation;
    currentLocationCounter = [self.locationValues indexOfObject:newLocation];
    NSMutableArray *eventsForNewLocation = [NSMutableArray array];
    
    for (NSMutableDictionary *event in self.eventData) {
        if ([[event objectForKey:@"Region"] isEqualToString:newLocation])         {
            [eventsForNewLocation addObject:event];
            if (![[event objectForKey:@"End Date"] isEqualToString:@""]) 
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                [dateFormatter setDateFormat:@"dd/MM/yyyy"];
                NSDate *date = [dateFormatter dateFromString:[event objectForKey:@"Date"]];
                NSDate *endDate = [dateFormatter dateFromString:[event objectForKey:@"End Date"]];
                NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                
                NSUInteger unitFlags = NSDayCalendarUnit;
                NSDateComponents *dayComponent = [gregorian components:unitFlags fromDate:date toDate:endDate options:0];
                
                int numberOfDaysEventRunsFor = [dayComponent day];
                
                
                NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
                [offsetComponents setDay:1];
                
                
                for (int i = 0; i<numberOfDaysEventRunsFor; i++) {
                    date = [gregorian dateByAddingComponents:offsetComponents toDate:date options:0];
                    NSString *strMyDate= [dateFormatter stringFromDate:date];
                    NSMutableDictionary *newEvent = [event mutableCopy];
                    [newEvent setValue:@"" forKey:@"End Date"];
                    [newEvent setValue:strMyDate forKey:@"Date"];
                    [newEvent setValue:[NSString stringWithFormat:@"%@-%d",[newEvent objectForKey:@"Event ID"],i] forKey:@"Event ID"];
                    [eventsForNewLocation addObject:newEvent];
                    
                }
                
                
            }

        }
        
        
    }
    self.eventsForLocation = eventsForNewLocation;
    //NSLog(@"Events for current location: %@", self.eventsForLocation);
    //NSLog(@"Updated Location to %@", self.location);
    if (self.delegate) {
        [delegate reloadView];
    }
}

-(void)previousLocation
{
    if (currentLocationCounter > 0) {
        [self changeLocation:[self.locationValues objectAtIndex:currentLocationCounter-1]]; 
    }
}

-(void)nextLocation
{
    if (currentLocationCounter < 2) {
        [self changeLocation:[self.locationValues objectAtIndex:currentLocationCounter+1]]; 
    }
    
}

-(void)addEventToFavouritesArray:(NSDictionary*)event
{
    
    [self.favouriteEvents addObject:event];
    
}

-(void)removeEventFromFavouritesArrayWithID:(NSString*)eventID
{
    NSMutableDictionary *foundDict;
    
    for (NSMutableDictionary *event in self.favouriteEvents) 
    {
        if ([[event objectForKey:@"Event ID"] isEqualToString:eventID]) 
        {
            foundDict = event;
        }
        
        
    }
    
    if (foundDict != nil) 
    {
        [self.favouriteEvents removeObject:foundDict];
    }
}

-(BOOL)favouritesArrayContainsEventWithID:(NSString*)eventID
{
    NSMutableDictionary *foundDict;
    
    for (NSMutableDictionary *event in self.favouriteEvents) 
    {
        if ([[event objectForKey:@"Event ID"] isEqualToString:eventID]) 
        {
            foundDict = event;
        }
        
        
    }
    
    if (foundDict == nil) 
    {
        //NSLog(@"NO");
        return NO;
    }
    else 
    {
        //NSLog(@"YES");
        return YES;
    }
    
}

-(NSArray*)uniqueSingleDatesForFavourites
{
    NSLog(@"Getting all dates");
    NSMutableArray *uniqueDates = [NSMutableArray array];
    
    for(NSMutableDictionary *event in self.favouriteEvents)
    {
        if ([[event objectForKey:@"Date"] length] == 9) {
            [event setObject:[NSString stringWithFormat:@"0%@",[event objectForKey:@"Date"]] forKey:@"Date"];
        }
        if ([[event objectForKey:@"Date"] length] == 10) {
            
            if (![uniqueDates containsObject:[event objectForKey:@"Date"]])
            {
                [uniqueDates addObject:[event objectForKey:@"Date"]];
            }
            
            
        }
    }
    
    NSMutableArray *arrayOfDates = [NSMutableArray array];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    
    for (NSString *stringDate in uniqueDates) {
        NSDate *dateObject = [dateFormatter dateFromString:stringDate];
        [arrayOfDates addObject:dateObject];
    }
    
    
    [arrayOfDates sortUsingSelector:@selector(compare:)];
    
    NSMutableArray *arrayToReturn = [NSMutableArray array];
    
    for (NSDate *currentDate in arrayOfDates) {
        [arrayToReturn addObject:[dateFormatter stringFromDate:currentDate]];
    }
    
    return arrayToReturn;
    
}

-(NSArray*)eventsForDateInFavourites:(NSString*) date
{
    NSMutableArray *singleDateEvents = [NSMutableArray array];
    
    for(NSMutableDictionary *event in self.favouriteEvents)
    {
        if ([[event objectForKey:@"Date"] length] == 9) {
            [event setObject:[NSString stringWithFormat:@"0%@",[event objectForKey:@"Date"]] forKey:@"Date"];
        }
        if ([[event objectForKey:@"Date"] isEqualToString:date]) {
            [singleDateEvents addObject:event];
        }
        
    }
    
    
    return singleDateEvents;
}

-(void)revalidateFavourites
{
    NSMutableArray *toBeRemovedFromFavourites = [NSMutableArray array];

    for (NSMutableDictionary *favouriteEvent in self.favouriteEvents) 
    {
        NSMutableDictionary *foundEvent;
        
        for (NSMutableDictionary *event in self.eventData) 
        {
            NSArray *components = [[favouriteEvent objectForKey:@"Event ID"] componentsSeparatedByString:@"-"];
            if ([components count] > 1) {
                
                if ([[event objectForKey:@"Event ID"] isEqualToString:[components objectAtIndex:0]]) 
                {
                    foundEvent = event;
                    
                    [favouriteEvent setObject:[event objectForKey:@"Address"] forKey:@"Address"];
                    [favouriteEvent setObject:[event objectForKey:@"Contact"] forKey:@"Contact"];
                    [favouriteEvent setObject:[event objectForKey:@"Description"] forKey:@"Description"];
                    [favouriteEvent setObject:[event objectForKey:@"End Date"] forKey:@"End Date"];
                    [favouriteEvent setObject:[event objectForKey:@"End Time"] forKey:@"End Time"];
                    [favouriteEvent setObject:[event objectForKey:@"Latitude"] forKey:@"Latitude"];
                    [favouriteEvent setObject:[event objectForKey:@"Location"] forKey:@"Location"];
                    [favouriteEvent setObject:[event objectForKey:@"Longitude"] forKey:@"Longitude"];
                    [favouriteEvent setObject:[event objectForKey:@"Region"] forKey:@"Region"];
                    [favouriteEvent setObject:[event objectForKey:@"Start Time"] forKey:@"Start Time"];
                    [favouriteEvent setObject:[event objectForKey:@"Title"] forKey:@"Title"];
                    [favouriteEvent setObject:[event objectForKey:@"Website"] forKey:@"Website"];
                    
                }

            }
            else 
            {
                if ([[event objectForKey:@"Event ID"] isEqualToString:[favouriteEvent objectForKey:@"Event ID"]]) 
                {
                    foundEvent = event;
                    [favouriteEvent setObject:[event objectForKey:@"Address"] forKey:@"Address"];
                    [favouriteEvent setObject:[event objectForKey:@"Contact"] forKey:@"Contact"];
                    [favouriteEvent setObject:[event objectForKey:@"Date"] forKey:@"Date"];
                    [favouriteEvent setObject:[event objectForKey:@"Description"] forKey:@"Description"];
                    [favouriteEvent setObject:[event objectForKey:@"End Date"] forKey:@"End Date"];
                    [favouriteEvent setObject:[event objectForKey:@"End Time"] forKey:@"End Time"];
                    [favouriteEvent setObject:[event objectForKey:@"Latitude"] forKey:@"Latitude"];
                    [favouriteEvent setObject:[event objectForKey:@"Location"] forKey:@"Location"];
                    [favouriteEvent setObject:[event objectForKey:@"Longitude"] forKey:@"Longitude"];
                    [favouriteEvent setObject:[event objectForKey:@"Region"] forKey:@"Region"];
                    [favouriteEvent setObject:[event objectForKey:@"Start Time"] forKey:@"Start Time"];
                    [favouriteEvent setObject:[event objectForKey:@"Title"] forKey:@"Title"];
                    [favouriteEvent setObject:[event objectForKey:@"Website"] forKey:@"Website"];
                }
                
            }
        }
        
    if (foundEvent == nil) {
        [toBeRemovedFromFavourites addObject:favouriteEvent];
    }
        
    }
    if ([toBeRemovedFromFavourites count]>0) 
    {
        [self.favouriteEvents removeObjectsInArray:toBeRemovedFromFavourites];
    }
    if (self.favouritesDelegate) {
        [self.favouritesDelegate newDataWasDownloaded];
    }
}


@end
