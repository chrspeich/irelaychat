//
//  IRCUser.h
//  iRelayChat
//
//  Created by Christian Speich on 05.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IRCServer;
@class IRCChannel;
@class IRCUserMode;

extern NSString *IRCUserChanged;

@interface IRCUser : NSObject {
	NSString			*nickname;
	NSString			*user;
	NSString			*host;
	IRCServer			*server;
	NSMutableDictionary	*userModes;
}

+ (id) userWithNickname:(NSString*)name onServer:(IRCServer*)server;
+ (id) userWithString:(NSString*)string onServer:(IRCServer*)server;

- (IRCUserMode*) userModeForChannel:(IRCChannel*)channel;
- (void) setUserMode:(IRCUserMode*)userMode forChannel:(IRCChannel*)channel;
- (bool) isEqualToUser:(IRCUser*)_user;

@property(readonly) bool		isMe;
@property(readonly)	NSString	*string;
@property(retain)	NSString	*nickname;
@property(retain)	NSString	*user;
@property(retain)	NSString	*host;
@property(readonly)	IRCServer	*server;

@end
