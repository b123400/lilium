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

-(void)requestFinished:(Request*)request withStatuses:(NSMutableArray*)_statuses withError:(NSError*)error;

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
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    gridView.contentIndent=CGSizeMake(10, 10);
    float margin=([UIApplication currentFrame].size.height-gridView.contentIndent.height*2)/11;
    float cellToMarginRatio=3;
    gridView.cellMargin=CGSizeMake(margin, margin);
	gridView.cellSize=CGSizeMake(margin*cellToMarginRatio, margin*cellToMarginRatio);
	gridView.numOfRow=floor(([UIApplication currentFrame].size.height-gridView.contentIndent.height*2+margin)/(margin+gridView.cellSize.height));
	gridView.alwaysBounceVertical=YES;
	gridView.alwaysBounceHorizontal=YES;
	gridView.showsHorizontalScrollIndicator=NO;
	gridView.showsVerticalScrollIndicator=NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSArray*)viewsForNichijyouNavigationControllerToAnimate:(id)sender{
	return [gridView subviews];
}
-(BOOL)shouldWaitForViewToLoadBeforePush{
	return	 YES;
}
#pragma mark - load statuses
-(void)requestFinished:(Request*)request withStatuses:(NSMutableArray*)_statuses withError:(NSError*)error{
    if(error){
        NSLog(@"%@",[error description]);
    }
    if([gridView numberOfCellInSection:0]!=user.statuses.count){
        [gridView reloadDataWithAnimation:YES];
    }
}
#pragma mark - grid view
-(void)gridViewDidFinishedLoading:(id)sender{
	if(!pushed){
		[(NichijyouNavigationController*)self.navigationController viewCanBePushed:self];
		pushed=YES;
	}
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

@end
