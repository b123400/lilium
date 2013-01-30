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
#import "GAITrackedViewController.h"

@interface UserViewController : GAITrackedViewController <StatusDetailViewControllerDelegate>{
    BOOL pushed;

    User *user;
    NSArray *statuses;
    BOOL canFollow;
    BOOL isFollowing;
    
    IBOutlet BRGridView *gridView;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UIView *actionView;
    IBOutlet UIButton *followButton;

    BOOL isLoadingNewerStatus;
    BOOL isLoadingOlderStatus;
}
@property (retain,nonatomic) NSArray *statuses;

-(id)initWithUser:(User*)_user;
- (IBAction)followButtonPressed:(id)sender;

@end
