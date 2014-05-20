//
//  AppDelegate.m
//  NSWApp
//
//  Created by Nicholas Wittison on 17/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "NSWEventData.h"
#import "NSWNetwork.h"
#import "UIBarButtonItem+FlatUI.h"
#import "UIColor+FlatUI.h"
#import "EventsListViewController.h"
#import "UIFont+FlatUI.h"
#import "NSWAppAppearanceConfig.h"
#import "UITabBar+FlatUI.h"
@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    
    [TestFlight takeOff:@"377eb2df-f7d9-442a-b52f-b0e1fef9dec5"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ( ![userDefaults valueForKey:@"version"] )
    {
        
        [self savePreParsedDataForFirstRun];
        // Adding version number to NSUserDefaults for first version:
        [userDefaults setFloat:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue] forKey:@"version"];
    }
    
    
    if ([[NSUserDefaults standardUserDefaults] floatForKey:@"version"] == [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue] )
    {
        /// Same Version so dont run the function
    }
    else
    {
        // Call Your Function;
        
        // Update version number to NSUserDefaults for other versions:
        [userDefaults setFloat:[[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] floatValue] forKey:@"version"];
    }
    
    [userDefaults synchronize];

    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [[NSWNetwork sharedNetwork] setReachabilityStatusChangeBlock:^(BOOL isNetworkReachable) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                if (isNetworkReachable == NO) {
                    [(UITabBarController*)[self.window rootViewController] setSelectedIndex: 1];
                }
            });
        }];
        [(UITabBarController*)[self.window rootViewController] setSelectedIndex: 1]; //Defaulting to having this selected for now, looks silly with launch image otherwise.
    }
    

    [[NSWEventData sharedData] checkUsersLocation];

    [self keepUpAppearances];
    


    return YES;
}


-(void)savePreParsedDataForFirstRun
{
    NSString * file = [[NSBundle bundleForClass:[self class]] pathForResource:@"NSWEventDataForFirstRun" ofType:@"plist"];
    
    NSDictionary *saveDict = [NSDictionary dictionaryWithContentsOfFile:file];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingString:@"/NSWEventData.sav"];
    
    [saveDict writeToFile:filePath atomically:YES];

}

-(void)keepUpAppearances
{
    //[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:245/255.0 green:140/245.0 blue:30/245.0 alpha:1.0]];
    
    //[[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:245/255.0 green:140/245.0 blue:30/245.0 alpha:1.0]];

        UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
        [tabController.tabBar configureFlatTabBarWithColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1] selectedColor:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]];
    
    
    NSDictionary *tabBarButtonAppearanceDict = @{UITextAttributeFont : kGlobalTabBarItemFont, UITextAttributeTextColor: [UIColor whiteColor]};
    [[UITabBarItem appearance] setTitleTextAttributes:tabBarButtonAppearanceDict forState:UIControlStateNormal];
    tabBarButtonAppearanceDict = @{UITextAttributeFont : kGlobalTabBarBoldItemFont, UITextAttributeTextColor: [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]};
    [[UITabBarItem appearance] setTitleTextAttributes:tabBarButtonAppearanceDict forState:UIControlStateSelected];
    
    //[[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, 10)forBarMetrics:UIBarMetricsDefault];
    
    //[[UITabBar appearance] setTintColor:[UIColor whiteColor]];

    
    NSDictionary *barButtonAppearanceDict = @{UITextAttributeFont : kGlobalNavBarItemFont, UITextAttributeTextColor: kGlobalNavBarTextColor};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    NSDictionary *barAppearanceDict = @{UITextAttributeFont : kGlobalNavBarFont,UITextAttributeTextShadowColor : [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8], UITextAttributeTextColor : [UIColor whiteColor], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, -1)]};
    
    [[UINavigationBar appearance] setTitleTextAttributes:barAppearanceDict];
    [UIBarButtonItem configureFlatButtonsWithColor:kGlobalNavBarItemColour
                                  highlightedColor:kGlobalNavBarItemColourHighlighted
                                      cornerRadius:kNavBarButtonCornerRadius];

    if ([[UIBarButtonItem appearance] respondsToSelector:@selector(setTintColor:)]) {
        [[UIBarButtonItem appearance] setTintColor:kGlobalNavBarTextColor];
    }
    
    if (IsIOS7OrGreater()) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }
    
    
    
    //[[UISearchBar appearance] setTintColor:[UIColor redColor]];
    
    
    //[[UIBarButtonItem appearance] setTitlePositionAdjustment:UIOffsetMake(0.0f, 5.0f) forBarMetrics:UIBarMetricsDefault];

   
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSWEventData sharedData] saveToFile];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"HOW MANY? ");
    [[NSWNetwork sharedNetwork] checkShouldRevertToPreBakeFailsafe:^{} errorHandler:^(NSError *error) {}];
    //THIS CURRENTLY CHECKS THE REVERT FILE FIRST THEN CHAINS TO REAL DATA
    //[[NSWNetwork sharedNetwork] checkLatestHeader:^{} errorHandler:^(NSError *error) {}];
    //[[NSWNetwork sharedNetwork] downloadEventXMLWithCompletionHandler:^{} errorHandler:^(NSError *error) {}];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
