//
//  TumblrLoginViewController.h
//  perSecond
//
//  Created by b123400 on 22/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAToken.h"
//#import "BRTumblrLoginViewController.h"

@protocol TumblrLoginViewControllerDelegate <NSObject>

-(void)tumblrLoginViewController:(id)sender didReceivedAccessToken:(OAToken*)token;
-(void)tumblrLoginViewController:(id)sender failedWithError:(NSError*)error;

@end

@interface TumblrLoginViewController : UIViewController {
	
}

@property (nonatomic, weak) id<TumblrLoginViewControllerDelegate> delegate;

@end
