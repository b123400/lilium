//
//  BRGridView.h
//  perSecond
//
//  Created by b123400 on 03/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRGridViewCell.h"

@protocol BRGridViewDelegate <UIScrollViewDelegate>

- (BRGridViewCell *)gridView:(id)gridView cellAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)gridView:(id)gridView numberOfCellsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInGridView:(id)gridView;
@optional
- (void)gridView:(id)gridView didSelectCell:(BRGridViewCell*)cell AtIndexPath:(NSIndexPath *)indexPath;

@optional
-(void)gridViewDidFinishedLoading:(id)sender;

@end

@interface BRGridView : UIScrollView <BRGridViewCellDelegate>{
	UIEdgeInsets contentIndent;
	CGSize cellSize;
	int numOfRow;
	CGSize cellMargin;
    float widthOfGapBetweenSection;
	
	NSMutableArray *frameOfSections;
	NSMutableArray *numOfCellInSections;
	NSMutableDictionary *reuseCellIdentifiers;
	NSMutableArray *cells;
	NSMutableDictionary *cellsIndex;
	
//	IBOutlet id <BRGridViewDelegate> delegate;
}
@property (assign,nonatomic) IBOutlet id delegate;
@property (assign) int numOfRow;
@property (assign) UIEdgeInsets contentIndent;
@property (assign) CGSize cellSize;
@property (assign) CGSize cellMargin;
@property (assign,nonatomic) float widthOfGapBetweenSection;

-(void)reloadData;
-(void)reloadDataWithAnimation:(BOOL)animated;
-(void)reloadDataWithAnimation:(BOOL)animated clearViews:(BOOL)clear;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

-(int)numberOfCellInSection:(int)section;
-(void)scrollToCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

@end
