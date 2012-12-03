//
//  Request.h
//  perSecond
//
//  Created by b123400 Chan on 22/3/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Request : NSObject{
	id delegate;
	SEL selector;
    SEL failSelector;
}
@property (assign) id delegate;
@property (assign) SEL selector;
@property (assign) SEL failSelector;

@end
