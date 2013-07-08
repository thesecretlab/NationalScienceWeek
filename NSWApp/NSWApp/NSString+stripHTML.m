//
//  NSString+stripHTML.m
//  NSWApp
//
//  Created by Nicholas Wittison on 9/07/13.
//
//

#import "NSString+stripHTML.h"

@implementation NSString (stripHTML)
-(NSString *) stringByStrippingHTML {
    NSRange r;
    NSString *s = [self copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s;
}
@end
