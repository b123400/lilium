//
//  NSString+EscapePercentage.h
//  perSecond
//
//  Created by b123400 on 4/1/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (EscapePercentage)

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *stringByEscapingWithPercentage;

@end
