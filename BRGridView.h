//
//  BRGridView.h
//  perSecond
//
//  Created by b123400 on 03/08/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRGridViewCell.h"

@protocol BRGridViewDelegate

- (BRGridViewCell *)gridView:(id)gridView cellAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)gridView:(id)gridView numberOfCellsInSection:(NSInteger)section;
- (NSInteger)numberOfSectionsInGridView:(id)gridView;
@optional
- (void)gridView:(id)gridView didSelectCell:(BRGridViewCell*)cell AtIndexPath:(NSIndexPath *)indexPath;

@optional
-(void)gridViewDidFinishedLoading:(id)sender;

@end

@interface BRGridView : UIScrollView <BRGridViewCellDelegate>{
	CGSize contentIndent;
	CGSize cellSize;
	int numOfRow;
	CGSize cellMargin;
	
	NSMutableArray *frameOfSections;
	NSMutableArray *numOfCellInSections;
	NSMutableDictionary *reuseCellIdentifiers;
	NSMutableArray *cells;
	NSMutableDictionary *cellsIndex;
	
	IBOutlet id <BRGridViewDelegate> delegate;
}
@property (assign,nonatomic) IBOutlet id delegate;
@property (assign) int numOfRow;
@property (assign) CGSize contentIndent;
@property (assign) CGSize cellSize;
@property (assign) CGSize cellMargin;

-(void)reloadData;
-(void)reloadDataWithAnimation:(BOOL)animated;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
