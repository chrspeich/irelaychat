//
//  IRCUser.h
//  iRelayChat
//
//  Created by Christian Speich on 05.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IRCServer;

@interface IRCUser : NSObject {
	NSString	*nickname;
	NSString	*user;
	NSString	*host;
	IRCServer	*server;
}

+ (id) userWithNickname:(NSString*)name onServer:(IRCServer*)server;
+ (id) userWithString:(NSString*)string onServer:(IRCServer*)server;

- (bool) isMe;

@property(readonly)	NSString	*string;
@property(retain)	NSString	*nickname;
@property(retain)	NSString	*user;
@property(retain)	NSString	*host;

@end
