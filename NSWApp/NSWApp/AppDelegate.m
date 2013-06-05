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
    
    [[NSWNetwork sharedNetwork] setReachabilityStatusChangeBlock:^(BOOL isNetworkReachable) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (isNetworkReachable == NO) {
                [(UITabBarController*)[self.window rootViewController] setSelectedIndex: 1];
            }
        });
    }];
    [self keepUpAppearances];
       
    [[NSWEventData sharedData] checkUsersLocation];
    return YES;
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

    
    NSDictionary *barButtonAppearanceDict = @{UITextAttributeFont : kGlobalNavBarItemFont};
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtonAppearanceDict forState:UIControlStateNormal];
    NSDictionary *barAppearanceDict = @{UITextAttributeFont : kGlobalNavBarFont,UITextAttributeTextShadowColor : [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, -1)]};
    
    [[UINavigationBar appearance] setTitleTextAttributes:barAppearanceDict];
    [UIBarButtonItem configureFlatButtonsWithColor:kGlobalNavBarItemColour
                                  highlightedColor:kGlobalNavBarItemColourHighlighted
                                      cornerRadius:kNavBarButtonCornerRadius];
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
    [[NSWEventData sharedData] loadFromFile];
    [[NSWNetwork sharedNetwork] downloadEventXMLWithCompletionHandler:^{} errorHandler:^(NSError *error) {}];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
