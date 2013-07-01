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


@implementation NSWNetwork

+ (NSWNetwork*)sharedNetwork {
    if (_sharedNetwork == nil) 
    {  
        NSString *baseURLString;
        baseURLString = @"http://www.scienceweek.net.au";
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
    [self getPath:@"/event-transfer/scienceweek-events.xml" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    
    [self enqueueHTTPRequestOperation:[self HTTPRequestOperationWithRequest:[self requestWithMethod:@"HEAD" path:@"/event-transfer/scienceweek-events.xml" parameters:nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        NSLog(@"%@", error);
        errorHandler(error);

    }]];
    NSLog(@"Done checking version");
}

- (void) checkShouldRevertToPreBakeFailsafe:(void (^)(void))completionHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    [self enqueueHTTPRequestOperation:[self HTTPRequestOperationWithRequest:[self requestWithMethod:@"GET" path:@"https://dl.dropboxusercontent.com/u/1101046/revert.txt" parameters:nil] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *stringData = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Should revert to baked in data %@", stringData);
        
        if ([stringData isEqualToString:@"REVERT"]) //key for SHOULD revert
        {
            [[NSWEventData sharedData] revertDataAndStopDownload];
        }
        else //key for SHOULD NOT revert (i.e. keep downloading current data)
        {

            [[NSWEventData sharedData] resumeNormalUpdates];
            [self checkLatestHeader:^{} errorHandler:^(NSError *error) {}];

        }

        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        errorHandler(error);
    }]];
}


@end
