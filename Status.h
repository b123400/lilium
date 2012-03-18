//
//  Status.h
//  perSecond
//
//  Created by b123400 on 19/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageManager.h"

typedef enum StatusSourceType {
    StatusSourceTypeTwitter       = 0,
    StatusSourceTypeFacebook   =1,
	StatusSourceTypeFlickr  = 2,
	StatusSourceTypeInstagram =3,
	StatusSourceTypeTumblr    =4,
} StatusSourceType;

@interface Status : NSObject <SDWebImageManagerDelegate> {
	NSURL *thumbURL;
	NSURL *meduimURL;
	NSURL *fullURL;
	NSURL *webURL;
	
	NSString *caption;
	UIColor *captionColor;
	
	StatusSourceType source;
	NSString *accountName;
	NSString *accountID;
	
	NSString *statusID;
	
	NSDate *date;
	BOOL liked;
}

@property (nonatomic,retain) NSURL *thumbURL;
@property (nonatomic,retain) NSURL *meduimURL;
@property (nonatomic,retain) NSURL *fullURL;
@property (nonatomic,retain) NSURL *webURL;

@property (nonatomic,retain) NSString *caption;
@property (nonatomic,retain) UIColor *captionColor;

@property (assign)  StatusSourceType source;
@property (nonatomic,retain) NSString *accountName;
@property (nonatomic,retain) NSString *accountID;
@property (nonatomic,retain) NSString *statusID;

@property (nonatomic,retain) NSDate *date;
@property (nonatomic,assign) BOOL liked;

-(NSDictionary*)dictionaryRepresentation;
-(void)prefetechThumb;

@end
