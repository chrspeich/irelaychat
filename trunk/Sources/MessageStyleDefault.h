//
//  MessageStyleDefault.h
//  iRelayChat
//
//  Created by Christian Speich on 25.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IRCChannelMessage.h"

@interface MessageStyleDefault : NSObject {

}

+ (NSString*) template;
+ (NSString*) htmlForChannelMessage:(IRCChannelMessage*)message;

@end
