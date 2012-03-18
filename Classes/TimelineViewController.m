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
	statuses=[[[TimelineManager sharedManager] lastestStatuses:99] retain];
	return [super initWithNibName:@"TimelineViewController" bundle:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	gridView.contentIndent=CGSizeMake(10, 10);
	gridView.cellSize=CGSizeMake(120, 120);
	gridView.numOfRow=3;
	gridView.alwaysBounceVertical=YES;
	gridView.alwaysBounceHorizontal=YES;
	gridView.showsHorizontalScrollIndicator=NO;
	gridView.showsVerticalScrollIndicator=NO;
	gridView.cellMargin=CGSizeMake(40, 40);
    [super viewDidLoad];
}

-(NSArray*)viewsForNichijyouNavigationControllerToAnimate:(id)sender{
	return [gridView subviews];
}
-(void)pushInAnimationDidFinished{
	[[TimelineManager sharedManager] sync];
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
	SquareCell *cell=[gridView dequeueReusableCellWithIdentifier:@"cell"];
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
	gridView.delegate=nil;
	[statuses release];
    [super dealloc];
}


@end
