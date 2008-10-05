//
//  IRCConversationMessage.h
//  iRelayChat
//
//  Created by Christian Speich on 03.10.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IRCUser;
@class IRCConversation;

enum IRCConversationMessageTypes {
	IRCConversationMessageText = 1,
	IRCConversationMessageJoin = 2,
	IRCConversationMessagePart = 4,
	IRCConversationMessageQuit = 8
};

@interface IRCConversationMessage : NSObject {
	IRCUser					*user;
	IRCConversation			*conversation;
	bool					highlight;
	bool					action;
	NSAttributedString		*messageString;
	NSString				*htmlString;
	NSDate					*date;
	enum IRCConversationMessageTypes	type;
}

- (id) initWithMessage:(NSString*)message fromUser:(IRCUser*)user;
- (id) initJoinWithUser:(IRCUser*)user;
- (id) initPartWithUser:(IRCUser*)user andReason:(NSString*)reason;
- (id) initQuitWithUser:(IRCUser*)user andReason:(NSString*)reason;

@property(readonly) IRCUser					*user;
@property(readonly) bool					highlight;
@property(readonly) bool					action;
@property(readonly) NSAttributedString		*messageString;
@property(readonly) NSString				*htmlString;
@property(retain)	NSDate					*date;
@property(assign)	IRCConversation			*conversation;
@property(readonly) enum IRCConversationMessageTypes	type;

@end
