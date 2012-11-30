//
//  StatusDetailViewController.h
//  perSecond
//
//  Created by b123400 on 06/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRGridView.h"
#import "Status.h"

@interface StatusDetailViewController : UIViewController {
	IBOutlet UIView *imageWrapperView;
	IBOutlet UIImageView *mainImageView;
	IBOutlet UIActivityIndicatorView *commentLoading;
	IBOutlet UITableView *commentTableView;
	IBOutlet UIScrollView *mainScrollView;
	IBOutlet UIScrollView *imageWrapperScrollView;
	//IBOutlet BRGridView *gridView;
	
	Status *status;
}
-(id)initWithStatus:(Status*)_status;

@end
