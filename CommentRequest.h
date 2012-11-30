//
//  CommentRequest.h
//  perSecond
//
//  Created by b123400 Chan on 22/3/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "Request.h"
#import "Status.h"

@interface CommentRequest : Request{
	Status *targetStatus;
}
@property (retain,nonatomic) 	Status *targetStatus;

@end
