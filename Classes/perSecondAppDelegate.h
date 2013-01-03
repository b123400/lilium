//
//  perSecondAppDelegate.h
//  perSecond
//
//  Created by b123400 on 11/06/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NichijyouNavigationController.h"
#import "TestFlight.h"

@interface perSecondAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    NichijyouNavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

