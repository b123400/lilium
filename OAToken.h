//
//  OAToken.h
//  OAuthConsumer
//
//  Created by Jon Crosby on 10/19/07.
//  Copyright 2007 Kaboomerang LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

@interface OAToken : NSObject {
@protected
	//NSString *pin;
	
	NSString *key;
	NSString *secret;
	NSString *session;
	NSNumber *duration;
	NSMutableDictionary *attributes;
	NSDate *created;
	BOOL renewable;
	BOOL forRenewal;
}

//@property(retain) NSString *pin;			//added for the Twitter OAuth implementation

@property(retain, readwrite) NSString *key;
@property(retain, readwrite) NSString *secret;
@property(retain, readwrite) NSString *session;
@property(retain, readwrite) NSNumber *duration;
@property(retain, readwrite) NSDictionary *attributes;
@property(readwrite, getter=isForRenewal) BOOL forRenewal;

- (instancetype)initWithKey:(NSString *)aKey secret:(NSString *)aSecret;
- (instancetype)initWithKey:(NSString *)aKey secret:(NSString *)aSecret session:(NSString *)aSession
		 duration:(NSNumber *)aDuration attributes:(NSDictionary *)theAttributes created:(NSDate *)creation
		renewable:(BOOL)renew NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithHTTPResponseBody:(NSString *)body;

- (instancetype)initWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix NS_DESIGNATED_INITIALIZER;
- (int)storeInUserDefaultsWithServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;

@property (NS_NONATOMIC_IOSONLY, getter=isValid, readonly) BOOL valid;

- (void)setAttribute:(NSString *)aKey value:(NSString *)aValue;
- (NSString *)attribute:(NSString *)aKey;
- (void)setAttributesWithString:(NSString *)aAttributes;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *attributeString;

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasExpired;
@property (NS_NONATOMIC_IOSONLY, getter=isRenewable, readonly) BOOL renewable;
- (void)setDurationWithString:(NSString *)aDuration;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL hasAttributes;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSDictionary *parameters;

- (BOOL)isEqualToToken:(OAToken *)aToken;

+ (void)removeFromUserDefaultsWithServiceProviderName:(const NSString *)provider prefix:(const NSString *)prefix;

@end
