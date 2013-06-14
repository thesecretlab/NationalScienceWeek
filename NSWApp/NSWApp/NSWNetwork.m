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
        
        _sharedNetwork = [[NSWNetwork alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
        //_sharedNetwork.parameterEncoding = AFJSONParameterEncoding;
        
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
 

- (void) downloadEventDataWithVersionNumber:(NSNumber*)newVersionNumber completionHandler:(void (^)(void))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;
{
    [self getPath:@"/event-transfer/scienceweek-events.xml" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *stringData = [[NSString alloc] initWithData:responseObject encoding:0];
        NSLog(@"New Event Data %@", stringData);
        [[NSWEventData sharedData] updateEventDataFromDownload:stringData withVersionNumber:newVersionNumber];
        completionHandler();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         errorHandler(error);
    }];
    
}
*/

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



@end
