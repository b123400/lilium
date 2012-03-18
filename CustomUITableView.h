//
//  CustomUITableView.h
//  win7tweet
//
//  Created by b123400 on 05/12/2010.
//  Copyright 2010 home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomUITableView : UITableView <UITableViewDelegate> {

}

@end

@protocol CustomUITableViewDelegate

-(void)tableViewDidReloadedData:(CustomUITableView*)sender;
-(void)tableViewDidInsertedRow:(CustomUITableView*)sender;

@end