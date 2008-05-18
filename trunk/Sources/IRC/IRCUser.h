/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * iRelayChat - A better IRC Client for Mac OS X                             *
 * - Backend Class -                                                         *
 *                                                                           *
 * Copyright 2008 by Christian Speich <kontakt@kleinweby.de>                 *
 *                                                                           *
 * Licenced under GPL v3 or later. See 'Copying' for details.                *
 *                                                                           *
 * - Description - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
 *                                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
	NSColor				*color;
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
@property(readonly) NSColor		*color;

@end
