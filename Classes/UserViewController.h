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

@interface UserViewController : UIViewController{
    User *user;
    NSMutableArray *statuses;
    
    IBOutlet BRGridView *gridView;
}

-(id)initWithUser:(User*)_user;

@end
