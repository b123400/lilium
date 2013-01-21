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
#import "TimelineManager.h"
#import "SDImageCache.h"

@interface SettingViewController ()

-(void)refreshAutoReloadIntervalButton;

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
    [self refreshAutoReloadIntervalButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_autoReloadButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setAutoReloadButton:nil];
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
                [BRFunctions saveAccounts];
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
        [[TimelineManager sharedManager] resetTimer];
        [self refreshAutoReloadIntervalButton];
    }]];
    NSArray *intervals=@[@2,@3,@5,@10,@15];
    for(NSNumber *interval in intervals){
        [choices addObject:[Choice choiceWithText:[NSString stringWithFormat:@"%@ minutes",interval] action:^{
            [[NSUserDefaults standardUserDefaults] setObject:interval forKey:refreshIntervalKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[TimelineManager sharedManager] resetTimer];
            [self refreshAutoReloadIntervalButton];
        }]];
    }
    MultipleChoiceViewController *controller=[MultipleChoiceViewController controllerWithChoices:choices];
    controller.title=@"Refresh rate";
    [self.navigationController pushViewController:controller animated:YES];
}
-(void)refreshAutoReloadIntervalButton{
    int interval=2;
    NSNumber *savedInterval=[[NSUserDefaults standardUserDefaults] objectForKey:refreshIntervalKey];
    if(savedInterval)interval=[savedInterval intValue];
    NSString *unit=@"minutes";
    if(interval==1){
        unit=@"minute";
    }
    [self.autoReloadButton setTitle:[NSString stringWithFormat:@"Auto Reload:\n%d %@",interval,unit] forState:UIControlStateNormal];
}
- (IBAction)clearCachePressed:(id)sender {
    [[SDImageCache sharedImageCache] clearDisk];
    [[TimelineManager sharedManager] clearRecentStatuses];
    BRCircleAlert *alert=[BRCircleAlert alertWithText:@"Cache cleared"];
    [alert setColor:[UIColor colorWithRed:83/255. green:169/255. blue:37/255. alpha:1]];
    [alert show];
}
@end
