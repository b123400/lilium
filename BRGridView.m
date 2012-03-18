//
//  BRGridView.m
//  perSecond
//
//  Created by b123400 on 03/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRGridView.h"

@interface BRGridView ()

-(void)drawCurrentContent;

@end

@implementation BRGridView
@synthesize delegate,numOfRow,contentIndent,cellSize,cellMargin;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		reuseCellIdentifiers=[[NSMutableDictionary alloc]init];
		cells=[[NSMutableArray	 alloc]init];
		cellsIndex=[[NSMutableDictionary alloc]init];
		self.backgroundColor=[UIColor clearColor];
		[self addObserver:self forKeyPath:@"contentOffset" options:nil context:nil];
        // Initialization code.
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
	self=[super initWithCoder:aDecoder];
	reuseCellIdentifiers=[[NSMutableDictionary alloc]init];
	cells=[[NSMutableArray	 alloc]init];
	cellsIndex=[[NSMutableDictionary alloc]init];
	[self addObserver:self forKeyPath:@"contentOffset" options:nil context:nil];
	self.backgroundColor=[UIColor clearColor];
	return self;
}
#pragma mark Drawing
-(void)reloadData{
	float totalContentWidth=contentIndent.width;
	float drawingX=contentIndent.width;
	
	int numOfSection=[delegate numberOfSectionsInGridView:self];
	float widthOfGapBetweenSection=40.0;
	
	if(frameOfSections){
		[frameOfSections release];
	}
	if(numOfCellInSections){
		[numOfCellInSections release];
	}
	numOfCellInSections=[[NSMutableArray alloc]init];
	frameOfSections=[[NSMutableArray alloc]init];
	
	for(int i=0;i<numOfSection;i++){
		CGRect thisSectionFrame=CGRectMake(totalContentWidth, contentIndent.height, 0, 0);
		
		int numOfCellInThisSection=[delegate gridView:self numberOfCellsInSection:i];
		int numOfColumns=ceil(numOfCellInThisSection/(numOfRow/1.0f));
		float widthOfThisSection=numOfColumns*(cellSize.width+cellMargin.width)-(numOfCellInThisSection==0?0:cellMargin.width);
		totalContentWidth+=widthOfThisSection+widthOfGapBetweenSection;
		
		thisSectionFrame.size.width=widthOfThisSection;
		
		[frameOfSections addObject:[NSValue valueWithCGRect:thisSectionFrame]];
		
		/*for(int j=0;j<numOfCellInThisSection;j++){
			int currentColumn=j/numOfRow;
			int currentRow=j%numOfRow;
			
			BRGridViewCell *cell=[delegate gridView:self cellAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
			[self addSubview:cell];
			cell.frame=CGRectMake(drawingX, contentIndent.height+currentRow*(cellSize.height+cellMargin.height), cellSize.width, cellSize.height);
			
			if(currentRow==numOfRow-1||j==numOfCellInThisSection){
				drawingX+=cellSize.width+cellMargin.width;
			}
		}*/
		[numOfCellInSections addObject:[NSNumber numberWithInt:numOfCellInThisSection]];
	}
	
	self.contentSize=CGSizeMake(totalContentWidth, self.frame.size.height);
	[self drawCurrentContent];
	if(delegate){
		if([(id)delegate respondsToSelector:@selector(gridViewDidFinishedLoading:)]){
			[delegate gridViewDidFinishedLoading:self];
		}
	}
}
-(void)drawCurrentContent{
	if(!delegate)return;
	for(int i=0;i<[frameOfSections count];i++){
		CGRect sectionFrame=[[frameOfSections objectAtIndex:i] CGRectValue];
		if(self.contentOffset.x+self.frame.size.width>sectionFrame.origin.x&&self.contentOffset.x<sectionFrame.size.width+sectionFrame.origin.x){
			//section is visible
			float leftInvisibleWidth=self.contentOffset.x-sectionFrame.origin.x;
			if(leftInvisibleWidth<0)leftInvisibleWidth=0.0;
			float rightInvisibleWidth=(sectionFrame.origin.x+sectionFrame.size.width)-(self.contentOffset.x+self.frame.size.width);
			if(rightInvisibleWidth<0)rightInvisibleWidth=0.0;
			int numOfCellInThisSection=[[numOfCellInSections objectAtIndex:i]intValue];
			
			int numOfLeftInvisibleColumn=leftInvisibleWidth/(cellSize.width+cellMargin.width);
			int numOfLeftInvisibleCell=numOfLeftInvisibleColumn*numOfRow;
			if(numOfLeftInvisibleCell>numOfCellInThisSection)numOfLeftInvisibleCell=numOfCellInThisSection;
			
			//int numOfRightInvisibleColumn=rightInvisibleWidth/(cellSize.width+cellMargin.width);
			float preRightWidth=sectionFrame.size.width-rightInvisibleWidth;
			int numOfPreRightCell=ceil(preRightWidth/(cellSize.width+cellMargin.width))*numOfRow;
			if(numOfPreRightCell>numOfCellInThisSection)numOfPreRightCell=numOfCellInThisSection;
			//int numOfRightInvisibleCell=numOfCellInThisSection-numOfPreRightCell;
			
			for(int j=numOfLeftInvisibleCell;j<numOfPreRightCell;j++){
				int currentColumn=j/numOfRow;
				int currentRow=j%numOfRow;
				
				CGRect targetFrame=CGRectMake(sectionFrame.origin.x+currentColumn*(cellSize.width+cellMargin.width), contentIndent.height+currentRow*(cellSize.height+cellMargin.height), cellSize.width, cellSize.height);
				
				BOOL cellExistsAtIndexPath=NO;
				NSIndexPath *indexPath=[NSIndexPath indexPathForRow:j inSection:i];
				for(NSIndexPath *thisIndexPath in cellsIndex){
					if([thisIndexPath isEqual:indexPath]){
						cellExistsAtIndexPath=YES;
					}
				}
				if(!cellExistsAtIndexPath){
					BRGridViewCell *cell=[delegate gridView:self cellAtIndexPath:indexPath];
					cell.gridView=self;
					cell.indexPath=indexPath;
					[self addSubview:cell];
					cell.frame=targetFrame;
					if(![cells containsObject:cell]){
						[cells addObject:cell];
						[cellsIndex setObject:cell forKey:indexPath];
					}
				}
			}
		}
	}
	NSMutableArray *tempRemoveArr=[NSMutableArray array];
	for(BRGridViewCell *thisCell in cells){
		if(thisCell.frame.origin.x+thisCell.frame.size.width<self.contentOffset.x||thisCell.frame.origin.x>self.contentOffset.x+self.frame.size.width){
			[thisCell removeFromSuperview];
			[tempRemoveArr addObject:thisCell];
			[cellsIndex removeObjectsForKeys:[cellsIndex allKeysForObject:thisCell]];
		}
	}
	[cells removeObjectsInArray:tempRemoveArr];
}
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	[self reloadData];
}
#pragma mark scrolling
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	[self drawCurrentContent];
}
#pragma mark reuse
- (BRGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier{
	if(!identifier)return nil;
	if(![reuseCellIdentifiers objectForKey:identifier])return nil;
	NSArray *cachedCells=[reuseCellIdentifiers objectForKey:identifier];
	if(![cachedCells count])return nil;
	return [cachedCells objectAtIndex:0];
}
-(void)cellDidMovedToWindow:(BRGridViewCell*)sender{
	NSString *reuseIdentifier=[sender reuseIdentifier];
	if(!reuseIdentifier)return;
	if(![reuseCellIdentifiers objectForKey:reuseIdentifier])return;
	NSMutableArray *cachedCells=[reuseCellIdentifiers objectForKey:reuseIdentifier];
	[cachedCells removeObject:sender];
}
-(void)cellDidRemovedFromWindow:(BRGridViewCell*)sender{
	NSString *reuseIdentifier=[sender reuseIdentifier];
	if(!reuseIdentifier)return;
	if(![reuseCellIdentifiers objectForKey:reuseIdentifier]){
		[reuseCellIdentifiers setObject:[NSMutableArray arrayWithObject:sender] forKey:reuseIdentifier];
	}else{
		NSMutableArray *cachedCells=[reuseCellIdentifiers objectForKey:reuseIdentifier];
		[cachedCells addObject:sender];
	}
}
-(void)cellTapped:(BRGridViewCell*)sender{
	if(delegate&&[(id)delegate respondsToSelector:@selector(gridView:didSelectCell:AtIndexPath:)]){
		[delegate gridView:self didSelectCell:sender AtIndexPath:sender.indexPath];
	}
}

- (void)dealloc {
	[cells release];
	[cellsIndex release];
	if(numOfCellInSections){
		[numOfCellInSections release];
	}
	if(frameOfSections){
		[frameOfSections release];
	}
	[reuseCellIdentifiers release];
    [super dealloc];
}


@end
