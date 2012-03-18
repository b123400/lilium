//
//  BRInstagramEngine.h
//  perSecond
//
//  Created by b123400 on 22/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAConsumer.h"
#import "OAToken.h"

@protocol BRTwitterEngineDelegate

-(void)twitterEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier;
-(void)twitterEngine:(id)sender didFailed:(NSError*)error forRequestIdentifier:(NSString*)identifier;

@end

typedef enum BRImageSize{
	BRImageSizeThumb =0,
	BRImageSizeMedium =1,
	BRImageSizeLarge  =2,
	BRImageSizeFull =3,
}BRImageSize;

@interface BRTwitterEngine : NSObject {
	OAConsumer *consumer;
	OAToken *accessToken;
	
	id <BRTwitterEngineDelegate> delegate;
}
@property (nonatomic,retain) OAToken *accessToken;
@property (nonatomic,assign) id <BRTwitterEngineDelegate> delegate;

-(id)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;
-(id)initWithConsumer:(OAConsumer*)_consumer;

-(NSString*)performRequestWithPath:(NSString*)path parameters:(NSDictionary*)params;

-(NSString*)getHomeTimelineWithSinceID:(NSString*)sinceID maxID:(NSString*)maxID;

+(NSURL*)rawImageURLFromURL:(NSURL*)aURL boolOnly:(BOOL)boolOnly size:(BRImageSize)size;

@end
