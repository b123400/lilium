//
//  Status.h
//  perSecond
//
//  Created by b123400 on 19/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageManager.h"
#import "Account.h"

@interface Status : NSObject <SDWebImageManagerDelegate> {
	NSURL *thumbURL;
	NSURL *meduimURL;
	NSURL *fullURL;
	NSURL *webURL;
	
	NSString *caption;
	UIColor *captionColor;
	
	Account *account;
	
	NSString *statusID;
	
	NSDate *date;
	BOOL liked;
	NSMutableArray *attributes;
	
	NSMutableArray *comments;
}

@property (nonatomic,retain) NSURL *thumbURL;
@property (nonatomic,retain) NSURL *meduimURL;
@property (nonatomic,retain) NSURL *fullURL;
@property (nonatomic,retain) NSURL *webURL;

@property (nonatomic,retain) NSString *caption;
@property (nonatomic,retain) UIColor *captionColor;

@property (assign)  StatusSourceType source;
@property (nonatomic,retain) Account *account;
@property (nonatomic,retain) NSString *statusID;

@property (nonatomic,retain) NSDate *date;
@property (nonatomic,assign) BOOL liked;
@property (nonatomic,retain) NSMutableArray *attributes;
@property (nonatomic,retain) NSMutableArray *comments;

-(NSDictionary*)dictionaryRepresentation;
-(void)prefetechThumb;
-(void)getCommentsAndReturnTo:(id)target withSelector:(SEL)selector;

@end
