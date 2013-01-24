//
//  UserViewController.h
//  perSecond
//
//  Created by b123400 on 9/12/12.
//
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "BRGridView.h"
#import "StatusDetailViewController.h"

@interface UserViewController : UIViewController <StatusDetailViewControllerDelegate>{
    BOOL pushed;

    User *user;
    BOOL canFollow;
    BOOL isFollowing;
    
    IBOutlet BRGridView *gridView;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UIView *actionView;
    IBOutlet UIButton *followButton;
}

-(id)initWithUser:(User*)_user;
- (IBAction)followButtonPressed:(id)sender;

@end
