//
//  BRFlickrEngine.h
//  perSecond
//
//  Created by b123400 on 16/07/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAConsumer.h"
#import "OAToken.h"


@protocol BRFlickrEngineDelegate

-(void)flickrEngine:(id)sender didReceivedData:(id)data forRequestIdentifier:(NSString*)identifier;
-(void)flickrEngine:(id)sender didFailed:(NSError*)error forRequestIdentifier:(NSString*)identifier;

@end

@interface BRFlickrEngine : NSObject {
	OAConsumer *consumer;
	OAToken *accessToken;
	
	id <BRFlickrEngineDelegate> delegate;
    
    NSMutableArray *fetchers;
}
@property (retain,nonatomic) OAToken *accessToken;
@property (assign) id delegate;

-(id)initWithConsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerKey;
-(id)initWithConsumer:(OAConsumer*)_consumer;

-(NSString*)performRequestWithMethod:(NSString*)method parameters:(NSDictionary*)params; 

-(NSString*)getContactsPhotos;
-(NSString*)getPhotosOfUser:(NSString*)userID minDate:(NSDate*)minDate maxDate:(NSDate*)maxDate page:(int)page;
-(NSString*)getCommentsForPhotoWithID:(NSString*)photoID;
-(NSString*)addFavoritesForPhotoWithID:(NSString*)photoID;
-(NSString*)removeFavoritesForPhotoWithID:(NSString*)photoID;

+ (NSURL *)photoSourceURLFromDictionary:(NSDictionary *)inDictionary size:(NSString *)inSizeModifier;
+ (NSURL *)webPageURLFromDictionary:(NSDictionary *)inDictionary;

+ (NSURL *)iconSourceURLWithFarm:(int)farm iconServer:(int)server userID:(NSString*)userID;
+ (NSString *)shortURLIDFromPhotoID:(long long)num ;
+ (NSString *)photoIDFromShortURLID:(NSString *)strNum;

@end
