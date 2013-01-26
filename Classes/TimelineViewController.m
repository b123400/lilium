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
#import "UIApplication+Frame.h"
#import "BRFunctions.h"
#import "SVProgressHUD.h"

@interface TimelineViewController ()

-(void)layout;
-(void)layoutAnimated:(BOOL)animated;

@end

@implementation TimelineViewController

-(id)init{
	statuses=[[[TimelineManager sharedManager] latestStatuses:30] mutableCopy];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timelineManagerDidFinishedPreloadThumbImage:) name:TimelineManagerDidPrefectchThumbNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timelineManagerDidLoadedNewerStatuses:) name:TimelineManagerDidRefreshNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timelineManagerDidLoadedOlderStatuses:) name:TimelineManagerDidLoadedOlderStatusNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timelineManagerDidRemovedStatuses:) name:TimelineManagerDidDeletedStatusesNotification object:nil];
	return [super initWithNibName:@"TimelineViewController" bundle:nil];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated{
    [self layout];
}
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

#pragma mark - delegates
-(Status*)nextImageForStatusViewController:(id)controller currentStatus:(Status*)currentStatus{
    int index=[statuses indexOfObject:currentStatus];
    if(index==NSNotFound)return nil;
    index++;
    if(index<statuses.count){
        return [statuses objectAtIndex:index];
    }
    return nil;
}
-(Status*)previousImageForStatusViewController:(id)controller currentStatus:(Status*)currentStatus{
    int index=[statuses indexOfObject:currentStatus];
    if(index==NSNotFound)return nil;
    index--;
    if(index>=0){
        return [statuses objectAtIndex:index];
    }
    return nil;
}
-(void)timelineManagerDidLoadedNewerStatuses:(NSNotification*)notification{
    [SVProgressHUD dismiss];
    NSArray *_statuses=notification.object;
    if(!_statuses.count)return;
    [statuses insertObjects:notification.object atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_statuses count])]];
    [gridView reloadDataWithAnimation:YES];
}
-(void)timelineManagerDidRemovedStatuses:(NSNotification*)notification{
    NSArray *removedStatuses=notification.object;
    [statuses filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        Status *thisStatus=evaluatedObject;
        if([removedStatuses indexOfObject:thisStatus]==NSNotFound)return YES;
        return NO;
    }]];
    [gridView reloadData];
}
-(void)timelineManagerDidFinishedPreloadThumbImage:(NSNotification*)notification{
//    if(statuses)[statuses release];
//    statuses=[[[TimelineManager sharedManager] latestStatuses:99] mutableCopy];
//    [gridView reloadDataWithAnimation:YES];
}
-(void)timelineManagerDidLoadedOlderStatuses:(NSNotification*)notification{
    [SVProgressHUD dismiss];
    NSArray *_statuses=notification.object;
    if(!_statuses.count)return;
    [statuses addObjectsFromArray:_statuses];
    [gridView reloadDataWithAnimation:NO];
}
-(NSArray*)viewsForNichijyouNavigationControllerToAnimate:(id)sender{
    [self layout];
	return [gridView subviews];
}
-(void)pushInAnimationDidFinished{
	//[[StatusFetcher sharedFetcher]getStatusesForRequest:[StatusRequest requestWithRequestType:StatusRequestTypeTimeline]];
}
-(BOOL)shouldWaitForViewToLoadBeforePush{
	return	 YES;
}
-(void)willPopOutFromSubviewController:(StatusDetailViewController*)controller{
    [self layoutAnimated:NO];
    Status *status=controller.status;
    int index=[statuses indexOfObject:status];
    if(index!=NSNotFound){
        [gridView scrollToCellAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO];
    }
}
#pragma mark - grid view
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
    detailViewController.delegate=self;
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.contentOffset.x>scrollView.contentSize.width-scrollView.frame.size.width-gridView.contentIndent.right){
        [self loadOlderStatuses];
    }else if(scrollView.contentOffset.x<-40){
        [[TimelineManager sharedManager] sync];
        [SVProgressHUD show];
    }
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
    [self layout];
    if(currentIndexPath){
        [gridView scrollToCellAtIndexPath:currentIndexPath animated:YES];
    }
}
-(void) willAnimateRotationToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation duration: (NSTimeInterval) duration {
    [self updateLayoutForNewOrientation: interfaceOrientation];
}
#pragma mark - actions
-(void)loadOlderStatuses{
    int count=30;
    NSArray *newStatuses=[[TimelineManager sharedManager] statusesAfter:statuses.lastObject count:count];
    if(newStatuses.count<count){
        //is loading from internet
        [SVProgressHUD show];
    }
    [statuses addObjectsFromArray:newStatuses];
    [gridView reloadData];
}
#pragma mark -
-(void)layout{
    [self layoutAnimated:YES];
}
-(void)layoutAnimated:(BOOL)animated{
    if(!CGSizeEqualToSize(gridView.cellMargin, [BRFunctions gridViewCellMargin])||
       !CGSizeEqualToSize(gridView.cellSize, [BRFunctions gridViewCellSize])){
        gridView.contentIndent=UIEdgeInsetsMake(10, 10, 10, 80);
        gridView.cellMargin=[BRFunctions gridViewCellMargin];
        gridView.cellSize=[BRFunctions gridViewCellSize];
        gridView.numOfRow=[BRFunctions gridViewNumOfRow];
        gridView.alwaysBounceVertical=YES;
        gridView.alwaysBounceHorizontal=YES;
        gridView.showsHorizontalScrollIndicator=NO;
        gridView.showsVerticalScrollIndicator=NO;
        [gridView reloadDataWithAnimation:animated clearViews:YES];
    }
}

@end
