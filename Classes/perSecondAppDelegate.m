//
//  perSecondAppDelegate.m
//  perSecond
//
//  Created by b123400 on 11/06/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "perSecondAppDelegate.h"
#import "WelcomeViewController.h"
#import "BRFunctions.h"
#import "TimelineManager.h"
#import "StatusFetcher.h"
#import "SDImageCache.h"

@implementation perSecondAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [TestFlight takeOff:@"02c4122f796fe828e4bdabd359ef6ae9_NzU4NDIwMTItMTItMjkgMTM6MzM6NDkuMTc1MDYy"];
    [BRFunctions loadAccounts];
    [[TimelineManager sharedManager]loadRecentStatuses];
    [[TimelineManager sharedManager] sync];
    // Override point for customization after application launch.
    
    // Set the navigation controller as the window's root view controller and display.
	//navigationController.disableFade=YES;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
	WelcomeViewController *welcome=[[WelcomeViewController alloc]init];
	[self.navigationController pushViewController:welcome animated:YES];
	[welcome release];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [[TimelineManager sharedManager] saveRecentStatuses];
    [[SDImageCache sharedImageCache] clearMemory];
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	
    return [[BRFunctions sharedFacebook] handleOpenURL:url]; 
}
#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SDImageCache sharedImageCache] clearMemory];
    [[StatusFetcher sharedFetcher] freeUnusedStatuses];
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

