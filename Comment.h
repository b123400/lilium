//
//  Comment.h
//  perSecond
//
//  Created by b123400 Chan on 23/3/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"

@interface Comment : NSObject{
	NSDate *date;
	Account *account;
	NSString *text;
}
@property (nonatomic,retain)NSDate *date;
@property (nonatomic,retain)Account *account;
@property (nonatomic,retain)NSString *text;

@end
