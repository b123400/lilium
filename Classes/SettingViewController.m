//
//  SettingViewController.m
//  perSecond
//
//  Created by b123400 on 13/1/13.
//
//

#import "SettingViewController.h"
#import "BRFunctions.h"
#import "BRCircleAlert.h"
#import "MultipleChoiceViewController.h"
#import "TumblrUser.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

-(id)init{
    return [self initWithNibName:@"SettingViewController" bundle:NO];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(!cell){
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
    }
    cell.textLabel.text=@"";
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
- (IBAction)tumblrReblogButtonPressed:(id)sender{
    if([BRFunctions didLoggedInTumblr]){
        NSMutableArray *choices=[NSMutableArray array];
        for(TumblrUser *thisUser in [BRFunctions tumblrUsers]){
            [choices addObject:[Choice choiceWithText:thisUser.displayName detailText:thisUser.userID action:^{
                [[BRFunctions tumblrUsers]removeObject:thisUser];
                [[BRFunctions tumblrUsers]insertObject:thisUser atIndex:0];
            }]];
        }
        MultipleChoiceViewController *controller=[MultipleChoiceViewController controllerWithChoices:choices];
        controller.title=@"Reblog to:";
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        [[BRCircleAlert alertWithText:@"You are not logged into tumblr yet."] show];
    }
}
- (IBAction)autoReloadPressed:(id)sender {
    NSMutableArray *choices=[NSMutableArray array];
    [choices addObject:[Choice choiceWithText:@"1 minute" action:^{
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:refreshIntervalKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }]];
    NSArray *intervals=@[@2,@3,@5,@20,@15];
    for(NSNumber *interval in intervals){
        [choices addObject:[Choice choiceWithText:[NSString stringWithFormat:@"%@ minutes",interval] action:^{
            [[NSUserDefaults standardUserDefaults] setObject:interval forKey:refreshIntervalKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }]];
    }
    MultipleChoiceViewController *controller=[MultipleChoiceViewController controllerWithChoices:choices];
    controller.title=@"Refresh rate";
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)clearCachePressed:(id)sender {
}
@end
