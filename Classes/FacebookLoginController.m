//
//  FacebookLoginController.m
//  perSecond
//
//  Created by b123400 on 03/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "FacebookLoginController.h"
#import "BRFunctions.h"
#import "SVProgressHUD.h"
#import "MultipleChoiceViewController.h"

@implementation FacebookLoginController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(instancetype)init{
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidLogin) name:facebookDidLoginNotification object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotLogin) name:facebookDidNotLoginNotification object:nil];
	
	return [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	BOOL isLoggedIn=[BRFunctions isFacebookLoggedIn];
	if(!isLoggedIn){
		loggedInButton.hidden=YES;
        [self login];
	}
    [super viewDidLoad];
}
-(void)pushInAnimationDidFinished{
    
}

- (void)login {
    NSArray *permissions=@[@"friends_photos",@"read_stream"];
    NSDictionary *options = @{ACFacebookAppIdKey : kFacebookAppID,
                              ACFacebookPermissionsKey : permissions,
                              ACFacebookAudienceKey:ACFacebookAudienceFriends};
    
    [[BRFunctions sharedAccountStore]
     requestAccessToAccountsWithType:[BRFunctions sharedFacebookType] options:options completion:^(BOOL granted, NSError *error) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             if (!granted) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get permission for Facebook, please enable it in Setting.app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
                 [alert release];
                 [self.navigationController popViewControllerAnimated:YES];
                 return;
             }
             if (error) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                 [alert show];
                 [alert release];
                 [self.navigationController popViewControllerAnimated:YES];
                 return;
             }
             NSArray *accounts = [[BRFunctions sharedAccountStore] accountsWithAccountType:[BRFunctions sharedFacebookType]];
             if (accounts.count == 0) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Facebook account found, please add it in Setting.app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
                 [alert release];
                 [self.navigationController popViewControllerAnimated:YES];
                 return;
                 
             } else if (accounts.count == 1) {
                 ACAccount *account = [accounts objectAtIndex:0];
                 [self didChooseAccount:account];
             } else {
                 NSMutableArray *choices = @[].mutableCopy;
                 for (int i = 0; i < accounts.count; i++) {
                     ACAccount *account = [accounts objectAtIndex:i];
                     Choice *thisChoice = [Choice choiceWithText:account.username detailText:nil action:^{
                         [self didChooseAccount:account];
                     }];
                     [choices addObject:thisChoice];
                 }
                 MultipleChoiceViewController *controller = [MultipleChoiceViewController controllerWithChoices:choices];
                 [self.navigationController pushViewController:controller animated:YES];
             }
         });
     }];
}

- (void)didChooseAccount:(ACAccount*)account {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:account.identifier forKey:@"currentFacebookUserIdentifier"];
    [defaults synchronize];
    
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeFacebook
                                            requestMethod:SLRequestMethodGET
                                                      URL:[NSURL URLWithString:@"https://graph.facebook.com/me"]
                                               parameters:@{}];
    [request setAccount:account];
    [SVProgressHUD show];

    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [BRFunctions logoutFacebook];
                [SVProgressHUD dismissWithError:@"Failed"];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert autorelease];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            
            NSError *error2 = nil;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error2];
            
            if (error2) {
                [BRFunctions logoutFacebook];
                [SVProgressHUD dismissWithError:@"Failed"];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error2.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert autorelease];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            
            if([result respondsToSelector:@selector(objectForKey:)]){
                if(result[@"id"]){
                    NSString *idString=[NSString stringWithFormat:@"%@",result[@"id"]];
                    [BRFunctions setFacebookCurrentUserID:idString];
                    [SVProgressHUD dismissWithSuccess:@"Success"];
                    [self.navigationController popViewControllerAnimated:YES];
                    return;
                }
            }
        });
    }];
}

//-(IBAction)didTapped{
//	[self.navigationController popViewControllerAnimated:YES];
//}

#pragma mark -




/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
