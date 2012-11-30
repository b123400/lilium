//
//  Attribute.h
//  perSecond
//
//  Created by b123400 Chan on 21/3/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Attribute : NSObject{
	NSURL *url;
	NSRange range;
}
@property (retain,nonatomic)	NSURL *url;
@property (assign,nonatomic) NSRange range;

@end
