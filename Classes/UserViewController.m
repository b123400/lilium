//
//  UserViewController.m
//  perSecond
//
//  Created by b123400 on 9/12/12.
//
//
#import "UIApplication+Frame.h"
#import "UserViewController.h"
#import "SquareCell.h"
#import "UIView+Interaction.h"
#import "StatusFetcher.h"
#import "StatusDetailViewController.h"
#import "NichijyouNavigationController.h"

@interface UserViewController ()

-(void)didGetUserRelationship:(User*)thisUser;
-(void)requestFinished:(Request*)request withStatuses:(NSMutableArray*)_statuses withError:(NSError*)error;
-(void)layoutActionView;

@end

@implementation UserViewController

-(id)initWithUser:(User*)_user{
    user=[_user retain];
    
    //statuses=[[NSMutableArray alloc] init];
    StatusesRequest *request=[[[StatusesRequest alloc]initWithRequestType:StatusRequestTypeSolo] autorelease];
    request.referenceUsers=[NSMutableArray arrayWithObject:user];
    request.selector=@selector(requestFinished:withStatuses:withError:);
    request.delegate=self;
    [[StatusFetcher sharedFetcher] getStatusesForRequest:request];
    
    if(user.relationship==UserRelationshipUnknown){
        [user getRelationshipAndReturnTo:self withSelector:@selector(didGetUserRelationship:)];
    }
    
    return [self initWithNibName:@"UserViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc{
    if(user)[user release];
    gridView.delegate=nil;
    //[statuses release];
    [usernameLabel release];
    [actionView release];
    [followButton release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    gridView.contentIndent=UIEdgeInsetsMake(80, 10, 10, 10);
    float margin=(gridView.frame.size.height-gridView.contentIndent.top-gridView.contentIndent.bottom)/11;
    float cellToMarginRatio=3;
    gridView.cellMargin=CGSizeMake(margin, margin);
	gridView.cellSize=CGSizeMake(margin*cellToMarginRatio, margin*cellToMarginRatio);
	gridView.numOfRow=floor((gridView.frame.size.height-(gridView.contentIndent.top+gridView.contentIndent.bottom)+margin)/(margin+gridView.cellSize.height));
	gridView.alwaysBounceVertical=YES;
	gridView.alwaysBounceHorizontal=YES;
	gridView.showsHorizontalScrollIndicator=NO;
	gridView.showsVerticalScrollIndicator=NO;
    
    usernameLabel.text=[NSString stringWithFormat:@"%@@%@",user.displayName,[Status sourceName:user.type]];
    [usernameLabel sizeToFit];
    [self layoutActionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSArray*)viewsForNichijyouNavigationControllerToAnimate:(id)sender{
    NSMutableArray *views=[[[NSMutableArray alloc] initWithArray:[gridView subviews]] autorelease];
    [views addObject:actionView];
	return views;
}
-(BOOL)shouldWaitForViewToLoadBeforePush{
	return	 YES;
}
#pragma mark action view
-(void)layoutActionView{
    usernameLabel.text=[NSString stringWithFormat:@"%@@%@",user.username,[Status sourceName:user.type]];
    [usernameLabel sizeToFit];
    CGRect frame=usernameLabel.frame;
    frame.origin.y=(usernameLabel.superview.frame.size.height-usernameLabel.frame.size.height)/2;
    usernameLabel.frame=frame;
    
    frame=followButton.frame;
    frame.origin.x=usernameLabel.frame.origin.x+usernameLabel.frame.size.width+10;
    followButton.frame=frame;
    if(user.relationship==UserRelationshipUnknown||user.relationship==UserRelationshipNotAvailable){
        followButton.hidden=YES;
    }else{
        followButton.hidden=NO;
        if(user.relationship==UserRelationshipNotFollowing){
            [followButton setTitle:@"follow" forState:UIControlStateNormal];
        }else{
            [followButton setTitle:@"unfollow" forState:UIControlStateNormal];
        }
    }
    frame=actionView.frame;
    frame.size.width=usernameLabel.frame.size.width+usernameLabel.frame.origin.x;
    if(!followButton.hidden){
        frame.size.width=followButton.frame.size.width+followButton.frame.origin.x;
    }
    actionView.frame=frame;
}
- (IBAction)followButtonPressed:(id)sender {
    if(user.relationship==UserRelationshipFollowing){
        user.relationship=UserRelationshipNotFollowing;
    }else if(user.relationship==UserRelationshipNotFollowing){
        user.relationship=UserRelationshipFollowing;
    }
    [self layoutActionView];
}
#pragma mark - load things
-(void)requestFinished:(Request*)request withStatuses:(NSMutableArray*)_statuses withError:(NSError*)error{
    if(error){
        NSLog(@"%@",[error description]);
    }
    if([gridView numberOfCellInSection:0]!=user.statuses.count){
        [gridView reloadDataWithAnimation:YES];
    }
}
-(void)didGetUserRelationship:(User*)thisUser{
    [self layoutActionView];
}
#pragma mark - grid view
-(void)gridViewDidFinishedLoading:(id)sender{
	if(!pushed){
		[(NichijyouNavigationController*)self.navigationController viewCanBePushed:self];
		pushed=YES;
	}
    [gridView addSubview:actionView];
}
- (BRGridViewCell *)gridView:(id)_gridView cellAtIndexPath:(NSIndexPath *)indexPath{
	SquareCell *cell=(SquareCell*)[gridView dequeueReusableCellWithIdentifier:@"cell"];
	if(!cell){
		cell=[[[SquareCell alloc] initWithReuseIdentifier:@"cell"] autorelease];
		cell.backgroundColor=[UIColor blackColor];
		[cell setTouchReactionEnabled:YES];
	}
	Status *thisStatus=[user.statuses objectAtIndex:indexPath.row];
	cell.status=thisStatus;
	return cell;
}
- (NSInteger)gridView:(id)gridView numberOfCellsInSection:(NSInteger)section{
    return [user.statuses count];
}
- (NSInteger)numberOfSectionsInGridView:(id)gridView{
    return 1;
}
- (void)gridView:(id)gridView didSelectCell:(BRGridViewCell*)cell AtIndexPath:(NSIndexPath *)indexPath{
    Status *thisStatus=[user.statuses objectAtIndex:indexPath.row];
	StatusDetailViewController *detailViewController=[[StatusDetailViewController alloc]initWithStatus:thisStatus];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

- (void)viewDidUnload {
    [usernameLabel release];
    usernameLabel = nil;
    [actionView release];
    actionView = nil;
    [followButton release];
    followButton = nil;
    [super viewDidUnload];
}
@end
