//
//  TimelineViewController.h
//  perSecond
//
//  Created by b123400 on 16/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRGridView.h"
#import "StatusDetailViewController.h"
//#import "GAITrackedViewController.h"

@interface TimelineViewController : UIViewController <StatusDetailViewControllerDelegate> {
	BOOL pushed;
	
	IBOutlet BRGridView *gridView;
	
	NSMutableArray *statuses;
}

-(void)loadOlderStatuses;

@end
