//
//  FlickrLoginViewController.h
//  perSecond
//
//  Created by b123400 on 07/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRFlickrOAuthTokenGetter.h"

@protocol FlickrLoginViewControllerDelegate

-(void)flickrLoginControllerDidReceivedAccessToken:(OAToken*)token;

@end


@interface FlickrLoginViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	BRFlickrOAuthTokenGetter *getter;
	
	id <FlickrLoginViewControllerDelegate> delegate;
}

@property (nonatomic,assign) id <FlickrLoginViewControllerDelegate> delegate;

@end
