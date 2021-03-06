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
#import "CommentComposeView.h"
#import "OHAttributedLabel.h"
#import "Attribute.h"
#import "SDWebImageManager.h"
#import "OLImageView.h"
//#import "GAITrackedViewController.h"

@protocol StatusDetailViewControllerDelegate <NSObject>
@optional
-(Status*)nextImageForStatusViewController:(id)controller currentStatus:(Status*)currentStatus;
-(Status*)previousImageForStatusViewController:(id)controller currentStatus:(Status*)currentStatus;

@end

@interface StatusDetailViewController : UIViewController <UITextFieldDelegate,UIActionSheetDelegate,SDWebImageManagerDelegate> {
	IBOutlet UIView *imageWrapperView;
    OHAttributedLabel *textLabel;
	IBOutlet OLImageView *mainImageView;
	IBOutlet UIActivityIndicatorView *commentLoading;
	IBOutlet UITableView *commentTableView;
	IBOutlet UIScrollView *mainScrollView;
	IBOutlet UIScrollView *imageWrapperScrollView;
    
    IBOutlet UIView *userView;
    IBOutlet UIButton *actionButton;
    IBOutlet UIButton *likeButton;
    IBOutlet UIImageView *profileImageView;
    IBOutlet UILabel *displayNameLabel;
    
    CommentComposeView *commentComposeView;
	
	Status *status;
    
    id <StatusDetailViewControllerDelegate> delegate;
}
@property (nonatomic,readonly) Status *status;
@property (nonatomic,assign) id <StatusDetailViewControllerDelegate> delegate;
-(instancetype)initWithStatus:(Status*)_status;

-(void)refreshLikeButton;
- (IBAction)likeButtonClicked:(id)sender;
- (IBAction)actionButtonClicked:(id)sender;

@end
