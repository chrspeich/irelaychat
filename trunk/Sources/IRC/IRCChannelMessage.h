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
@class IRCMessage;

@interface IRCChannelMessage : NSObject {
	IRCUser		*from;
	bool		highlight;
	bool		action;
	NSString	*message;
}

- (id) initWithUser:(IRCUser*)user andMessage:(NSString*)message;

@property(readonly) IRCUser *from;
@property(readonly) bool highlight;
@property(readonly) bool action;
@property(readonly) NSString *message;
@property(readonly) NSString *htmlUseableMessage;

+ (NSString*) urlRegex;

@end
