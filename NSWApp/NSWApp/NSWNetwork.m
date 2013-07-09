//
//  NSWNetwork.m
//  NSWApp
//
//  Created by Nicholas Wittison on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSWNetwork.h"
#import "NSWEventData.h"
static NSWNetwork* _sharedNetwork = nil;

//#define NETWORK_TESTING

#if NETWORK_TESTING
#define BASE_URL @"http://dev.secretlab.com.au"
#define EVENT_DATA_PATH @"/scienceweek/scienceweek-events.xml"
#define REVERT_FILE_URL @"http://dev.secretlab.com.au/scienceweek/revert.txt"
#else
#define BASE_URL @"http://www.scienceweek.net.au"
#define EVENT_DATA_PATH @"/event-transfer/scienceweek-events.xml"
#define REVERT_FILE_URL @"https://dl.dropboxusercontent.com/u/1101046/revert.txt"
#endif

@implementation NSWNetwork

+ (NSWNetwork*)sharedNetwork {
    if (_sharedNetwork == nil) 
    {  
        NSString *baseURLString;
        baseURLString = BASE_URL;
        _sharedNetwork.shouldCheckForNewContent = YES;
        _sharedNetwork = [[NSWNetwork alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
        
    }
    return _sharedNetwork;
}

/*
- (void) checkForNewFileVersionWithCompletionHandler:(void (^)(NSNumber *newVersionNumber))completionHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    
    [self getPath:@"/nswdataversion.txt" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *stringData = [[NSString alloc] initWithData:responseObject encoding:0];
        NSLog(@"VERSION %@", stringData);
        
        if ([stringData intValue] > [[[NSWEventData sharedData] latestVersionNumber] intValue]) {
            
            [self downloadEventDataWithVersionNumber:[NSNumber numberWithInt:[stringData intValue]] completionHandler:^{
                NSLog(@"New Data downloaded!");
            } errorHandler:^(NSError *error) {
                NSLog(@"New data download failed.");
            }];
            
            completionHandler([NSNumber numberWithInt:[stringData intValue]]);
        }
        else
        {
            NSLog(@"Current Data is the latest! No need to update file."); 
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorHandler(error);
    }];
    
}
 
*/
- (void) downloadEventDataWithVersionNumber:(NSNumber*)newVersionNumber completionHandler:(void (^)(void))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;
{
    [self getPath:EVENT_DATA_PATH parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *stringData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"New data has been downloaded");
        [[NSWEventData sharedData] updateEventDataFromDownload:stringData withVersionNumber:newVersionNumber];
        completionHandler();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         errorHandler(error);
    }];
    
}


/*
- (void) downloadEventXMLWithCompletionHandler:(void (^)(void))completionHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    [self getPath:@"/event-transfer/scienceweek-events.xml" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *stringData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"New Event Data %@", stringData);
        [[NSWEventData sharedData] updateEventDataFromDownload:stringData];
        completionHandler();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorHandler(error);
    }];
    
}
 */

- (void) checkLatestHeader:(void (^)(void))completionHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    NSLog(@"Checking version...");
    
    [self enqueueHTTPRequestOperation:[self HTTPRequestOperationWithRequest:[self requestWithMethod:@"HEAD" path:EVENT_DATA_PATH parameters:nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"];
        NSLog(@"UNIX TIME %f", [[dateFormatter dateFromString:[[[operation response] allHeaderFields] objectForKey:@"Last-Modified"]] timeIntervalSince1970]);
        NSNumber *lastModified = [NSNumber numberWithFloat:[[dateFormatter dateFromString:[[[operation response] allHeaderFields] objectForKey:@"Last-Modified"]] timeIntervalSince1970]];
        if ([lastModified intValue] != [[[NSWEventData sharedData] latestVersionNumber] intValue])
        {
            NSLog(@"New data is being downloaded! Version was %d, is now %d", [[[NSWEventData sharedData] latestVersionNumber] intValue], [lastModified intValue]);

            [self downloadEventDataWithVersionNumber:lastModified completionHandler:^{
            } errorHandler:^(NSError *error) {
                NSLog(@"New data download failed.");
            }];
            
            completionHandler();
        }
        else
        {
            NSLog(@"Current Data is the latest! No need to update file.");
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error when checking version %@", error);
        errorHandler(error);

    }]];
    
}

- (void) checkShouldRevertToPreBakeFailsafe:(void (^)(void))completionHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    [self enqueueHTTPRequestOperation:[self HTTPRequestOperationWithRequest:[self requestWithMethod:@"GET" path:REVERT_FILE_URL parameters:nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *stringData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Should revert to baked in data %@?", stringData);
        
        if ([stringData isEqualToString:@"REVERT"]) //key for SHOULD revert
        {
            NSLog(@"Yes. Reverting to built-in data.");
            [[NSWEventData sharedData] revertDataAndStopDownload];
        }
        else //key for SHOULD NOT revert (i.e. keep downloading current data)
        {
            NSLog(@"No. Continuing download.");
            [[NSWEventData sharedData] resumeNormalUpdates];
            [self checkLatestHeader:^{} errorHandler:^(NSError *error) {}];

        }

        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        errorHandler(error);
        
        //Failsafe for failsafe. (This is here incase the file dissappears so the app can continue downloading.)
        [self checkLatestHeader:^{} errorHandler:^(NSError *error) {}];
    }]];
}


@end
