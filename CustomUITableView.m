//
//  CustomUITableView.m
//  win7tweet
//
//  Created by b123400 on 05/12/2010.
//  Copyright 2010 home. All rights reserved.
//

#import "CustomUITableView.h"

@implementation CustomUITableView

-(void)reloadData{
	[super	reloadData];
	if([self.delegate respondsToSelector:@selector(tableViewDidReloadedData:)]){
		[(id)self.delegate tableViewDidReloadedData:self];
	}
}
-(void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation{
	[super insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
	if([self.delegate respondsToSelector:@selector(tableViewDidInsertedRow:)]){
		[(id)self.delegate tableViewDidInsertedRow:self];
	}
}

@end
