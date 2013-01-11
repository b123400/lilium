//
//  TimelineViewController.m
//  perSecond
//
//  Created by b123400 on 16/07/2011.
//  Copyright 2011 home. All rights reserved.
//
#import "NichijyouNavigationController.h"
#import "TimelineViewController.h"
#import "TimelineManager.h"
#import "SquareCell.h"
#import "UIView+Interaction.h"
#import "StatusDetailViewController.h"
#import "UIApplication+Frame.h"

@implementation TimelineViewController

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
-(id)init{
	statuses=[[[TimelineManager sharedManager] latestStatuses:99] mutableCopy];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timelineManagerDidFinishedPreloadThumbImage:) name:TimelineManagerDidPrefectchThumbNotification object:nil];
	return [super initWithNibName:@"TimelineViewController" bundle:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
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
    [super viewDidLoad];
}
-(void)timelineManagerDidFinishedPreloadThumbImage:(NSNotification*)notification{
    if(statuses)[statuses release];
    statuses=[[[TimelineManager sharedManager] latestStatuses:99] mutableCopy];
    [gridView reloadDataWithAnimation:YES];
}
-(NSArray*)viewsForNichijyouNavigationControllerToAnimate:(id)sender{
	return [gridView subviews];
}
-(void)pushInAnimationDidFinished{
	//[[StatusFetcher sharedFetcher]getStatusesForRequest:[StatusRequest requestWithRequestType:StatusRequestTypeTimeline]];
}
-(BOOL)shouldWaitForViewToLoadBeforePush{
	return	 YES;
}
-(void)gridViewDidFinishedLoading:(id)sender{
	if(!pushed){
		[(NichijyouNavigationController*)self.navigationController viewCanBePushed:self];
		pushed=YES;
	}
}
- (BRGridViewCell *)gridView:(BRGridView*)_gridView cellAtIndexPath:(NSIndexPath *)indexPath{
	SquareCell *cell=(SquareCell*)[gridView dequeueReusableCellWithIdentifier:@"cell"];
	if(!cell){
		cell=[[[SquareCell alloc] initWithReuseIdentifier:@"cell"] autorelease];
		cell.backgroundColor=[UIColor blackColor];
		[cell setTouchReactionEnabled:YES];
	}
	Status *thisStatus=[statuses objectAtIndex:indexPath.row];
	cell.status=thisStatus;
	return cell;
}
- (NSInteger)gridView:(BRGridView *)gridView numberOfCellsInSection:(NSInteger)section{
	return [statuses count];
}
- (NSInteger)numberOfSectionsInGridView:(BRGridView *)gridView{
	return 1;
}
- (void)gridView:(id)gridView didSelectCell:(BRGridViewCell*)cell AtIndexPath:(NSIndexPath *)indexPath{
	Status *thisStatus=[statuses objectAtIndex:indexPath.row];
	StatusDetailViewController *detailViewController=[[StatusDetailViewController alloc]initWithStatus:thisStatus];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	gridView.delegate=nil;
	[statuses release];
    [super dealloc];
}


@end
