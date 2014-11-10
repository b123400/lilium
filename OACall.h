//
//  OACall.h
//  OAuthConsumer
//
//  Created by Alberto García Hierro on 04/09/08.
//  Copyright 2008 Alberto García Hierro. All rights reserved.
//	bynotes.com

#import <Foundation/Foundation.h>

@class OAProblem;
@class OACall;

@protocol OACallDelegate

- (void)call:(OACall *)call failedWithError:(NSError *)error;
- (void)call:(OACall *)call failedWithProblem:(OAProblem *)problem;

@end

@class OAConsumer;
@class OAToken;
@class OADataFetcher;
@class OAMutableURLRequest;
@class OAServiceTicket;

@interface OACall : NSObject {
	NSURL *url;
	NSString *method;
	NSArray *parameters;
	NSDictionary *files;
	NSObject <OACallDelegate> *delegate;
	SEL finishedSelector;
	OADataFetcher *fetcher;
	OAMutableURLRequest *request;
	OAServiceTicket *ticket;
}

@property(readonly) NSURL *url;
@property(readonly) NSString *method;
@property(readonly) NSArray *parameters;
@property(readonly) NSDictionary *files;
@property(nonatomic, retain) OAServiceTicket *ticket;

- (instancetype)init;
- (instancetype)initWithURL:(NSURL *)aURL;
- (instancetype)initWithURL:(NSURL *)aURL method:(NSString *)aMethod;
- (instancetype)initWithURL:(NSURL *)aURL parameters:(NSArray *)theParameters;
- (instancetype)initWithURL:(NSURL *)aURL method:(NSString *)aMethod parameters:(NSArray *)theParameters;
- (instancetype)initWithURL:(NSURL *)aURL parameters:(NSArray *)theParameters files:(NSDictionary*)theFiles;

- (instancetype)initWithURL:(NSURL *)aURL
		   method:(NSString *)aMethod
	   parameters:(NSArray *)theParameters
			files:(NSDictionary*)theFiles;

- (void)perform:(OAConsumer *)consumer
		  token:(OAToken *)token
		  realm:(NSString *)realm
	   delegate:(NSObject <OACallDelegate> *)aDelegate
	  didFinish:(SEL)finished;

@end
