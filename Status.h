//
//  Status.h
//  perSecond
//
//  Created by b123400 on 19/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageManager.h"
#import "User.h"

#define StatusDidPreloadedImageNotification @"StatusDidPreloadedImageNotification"

typedef enum StatusImageSize {
    StatusImageSizeThumb       = 0,
    StatusImageSizeMedium   =1,
	StatusImageSizeFull  = 2,
} StatusImageSize;

@interface Status : NSObject <SDWebImageManagerDelegate> {
	NSURL *thumbURL;
	NSURL *meduimURL;
	NSURL *fullURL;
	NSURL *webURL;
	
	NSString *caption;
	UIColor *captionColor;
	
	User *user;
	
	NSString *statusID;
	
	NSDate *date;
	BOOL liked;
	NSMutableArray *attributes;
	
	NSMutableArray *comments;
}

@property (nonatomic,retain) NSURL *thumbURL;
@property (nonatomic,retain) NSURL *mediumURL;
@property (nonatomic,retain) NSURL *fullURL;
@property (nonatomic,retain) NSURL *webURL;

@property (nonatomic,retain) NSString *caption;
@property (nonatomic,retain) UIColor *captionColor;

@property (nonatomic,retain) User *user;
@property (nonatomic,retain) NSString *statusID;

@property (nonatomic,retain) NSDate *date;
@property (nonatomic,assign) BOOL liked;
@property (nonatomic,retain) NSMutableArray *attributes;
@property (nonatomic,retain) NSMutableArray *comments;

+(NSArray*)allSources;
+(Status*)sampleStatus;
+(NSString*)sourceName:(StatusSourceType)source;


-(void)prefetechThumb;
-(UIImage*)cachedImageOfSize:(StatusImageSize)size;
-(BOOL)isImagePreloaded;

-(void)getCommentsAndReturnTo:(id)target withSelector:(SEL)selector;

-(NSDictionary*)dictionaryRepresentation;

@end
