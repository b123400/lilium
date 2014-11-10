//
//  BRInstagramLoginViewController.h
//  perSecond
//
//  Created by b123400 on 03/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRInstagramEngine.h"

@protocol BRInstagramLoginViewControllerDelegate

-(void)didReceivedInstagramToken:(NSString*)token;
-(void)didFailedToReceiveInstagramToken;

@end

@interface BRInstagramLoginViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	
	BRInstagramEngine *engine;
	
	id <BRInstagramLoginViewControllerDelegate> delegate;
}

@property (assign) id delegate;

-(instancetype)initWithInstagramEngine:(BRInstagramEngine*)_engine NS_DESIGNATED_INITIALIZER;

@end
