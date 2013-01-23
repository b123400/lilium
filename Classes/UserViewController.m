//
//  UserViewController.m
//  perSecond
//
//  Created by b123400 on 9/12/12.
//
//
#import <QuartzCore/QuartzCore.h>
#import "UIApplication+Frame.h"
#import "UserViewController.h"
#import "SquareCell.h"
#import "UIView+Interaction.h"
#import "StatusFetcher.h"
#import "NichijyouNavigationController.h"

@interface UserViewController ()

-(void)didGetUserRelationship:(User*)thisUser;
-(void)requestFinished:(Request*)request withStatuses:(NSMutableArray*)_statuses withError:(NSError*)error;
-(void)layoutActionView;

-(void)layoutGridview;
-(void)layoutGridviewAnimated:(BOOL)animated;

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
    [usernameLabel release];
    [actionView release];
    [followButton release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self layoutGridview];
    
    usernameLabel.text=[NSString stringWithFormat:@"%@@%@",user.displayName,[Status sourceName:user.type]];
    [usernameLabel sizeToFit];
    [self layoutActionView];
}
-(void)viewWillAppear:(BOOL)animated{
    [self layoutGridview];
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSArray*)viewsForNichijyouNavigationControllerToAnimate:(id)sender{
    NSMutableArray *views=[[[NSMutableArray alloc] initWithArray:[gridView subviews]] autorelease];
    [views addObjectsFromArray:actionView.subviews];
    [views removeObject:actionView];
	return views;
}
-(BOOL)shouldWaitForViewToLoadBeforePush{
	return	 YES;
}
#pragma mark action view
-(void)layoutActionView{
    actionView.layer.transform=CATransform3DIdentity;
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
    frame.origin.y=gridView.frame.size.height-gridView.contentIndent.bottom;
    frame.origin.x=10;
    actionView.frame=frame;
    
    actionView.center=CGPointMake(10, frame.origin.y);
    CGPoint anchor=CGPointMake(0, 0);
    actionView.layer.anchorPoint=anchor;
    actionView.layer.transform=CATransform3DMakeRotation(-M_PI_2, 0, 0, 1);
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
    for(Status *thisStatus in _statuses){
        [thisStatus prefetechThumb];
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
    detailViewController.delegate=self;
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}
-(void)layoutGridview{
    [self layoutGridviewAnimated:YES];
}
-(void)layoutGridviewAnimated:(BOOL)animated{
    if(!CGSizeEqualToSize(gridView.cellMargin, [BRFunctions gridViewCellMargin])||
       !CGSizeEqualToSize(gridView.cellSize, [BRFunctions gridViewCellSize])){
        gridView.contentIndent=UIEdgeInsetsMake(10, 80, 10, 10);
        gridView.cellMargin=[BRFunctions gridViewCellMargin];
        gridView.cellSize=[BRFunctions gridViewCellSize];
        gridView.numOfRow=floor(([UIApplication currentFrame].size.height-(gridView.contentIndent.bottom+gridView.contentIndent.top)+gridView.cellMargin.height)/(gridView.cellMargin.height+gridView.cellSize.height));
        gridView.alwaysBounceVertical=YES;
        gridView.alwaysBounceHorizontal=YES;
        gridView.showsHorizontalScrollIndicator=NO;
        gridView.showsVerticalScrollIndicator=NO;
        [gridView reloadDataWithAnimation:animated clearViews:YES];
    }
    [self layoutActionView];
}
- (void) updateLayoutForNewOrientation: (UIInterfaceOrientation) orientation{
    NSIndexPath *currentIndexPath=nil;
    for(BRGridViewCell *cell in gridView.cells){
        if(!currentIndexPath||(cell.indexPath.section==currentIndexPath.section&&cell.indexPath.row<currentIndexPath.row)||cell.indexPath.section<currentIndexPath.section){
            if([cell.superview convertRect:cell.frame toView:self.view].origin.x>0){
                currentIndexPath=cell.indexPath;
            }
        }
    }
    [self layoutGridview];
    if(currentIndexPath){
        [gridView scrollToCellAtIndexPath:currentIndexPath animated:YES];
    }
}
-(void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation duration: (NSTimeInterval) duration {
    [self updateLayoutForNewOrientation: interfaceOrientation];
}
#pragma mark - detail view delegate
-(Status*)nextImageForStatusViewController:(id)controller currentStatus:(Status*)currentStatus{
    NSArray *statuses=user.statuses;
    if(currentStatus==[statuses lastObject])return nil;
    int index=[statuses indexOfObject:currentStatus];
    if(index==NSNotFound)return nil;
    return [statuses objectAtIndex:index+1];
}
-(Status*)previousImageForStatusViewController:(id)controller currentStatus:(Status*)currentStatus{
    NSArray *statuses=user.statuses;
    int index=[statuses indexOfObject:currentStatus];
    if(index==NSNotFound||index==0)return nil;
    return [statuses objectAtIndex:index-1];
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
