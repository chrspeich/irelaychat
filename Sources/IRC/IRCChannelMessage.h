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
 * This file contains a basics class for a Channel Message. It provides      *
 * methods for getting the plain text and a html 'useable' text. It also     *
 * dedects if the message is an 'action' or if it is a message thats must be *
 * highlighted because the users name or one of the words that are defined   *
 * by the user is in the message.                                            *
 *                                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Cocoa/Cocoa.h>

@class IRCUser;
@class IRCChannel;

enum IRCChannelMessageTypes {
	IRCChannelMessageText = 1,
	IRCChannelMessageJoin = 2,
	IRCChannelMessagePart = 4,
	IRCChannelMessageQuit = 8
};

@interface IRCChannelMessage : NSObject {
	IRCUser		*from;
	IRCChannel	*channel;
	bool		highlight;
	bool		action;
	NSString	*message;
	NSString	*htmlUseableMessage;
	NSDate		*date;
	enum IRCChannelMessageTypes	type;
}

- (id) initWithUser:(IRCUser*)user andMessage:(NSString*)message;
- (id) initJoinWithUser:(IRCUser*)user;
- (id) initPartWithUser:(IRCUser*)user andReason:(NSString*)reason;
- (id) initQuitWithUser:(IRCUser*)user andReason:(NSString*)reason;

@property(readonly) IRCUser *from;
@property(readonly) bool highlight;
@property(readonly) bool action;
@property(readonly) NSString *message;
@property(readonly) NSString *htmlUseableMessage;
@property(retain)	NSDate *date;
@property(assign)	IRCChannel *channel;
@property(readonly) enum IRCChannelMessageTypes	type;

+ (NSString*) urlRegex;

@end
