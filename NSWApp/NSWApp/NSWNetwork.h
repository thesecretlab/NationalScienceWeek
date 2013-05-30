//
//  NSWNetwork.h
//  NSWApp
//
//  Created by Nicholas Wittison on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFNetworking.h"

@interface NSWNetwork : AFHTTPClient

+ (NSWNetwork*)sharedNetwork;

- (void) checkForNewFileVersionWithCompletionHandler:(void (^)(NSNumber *newVersionNumber))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

- (void) downloadEventDataWithVersionNumber:(NSNumber*)newVersionNumber completionHandler:(void (^)(void))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;
@end
