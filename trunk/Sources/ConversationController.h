/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * iRelayChat - A better IRC Client for Mac OS X                             *
 * - Controller Class for IRCConversation -                                  *
 *                                                                           *
 * Copyright 2008 by Christian Speich <kontakt@kleinweby.de>                 *
 *                                                                           *
 * Licenced under GPL v3 or later. See 'Copying' for details.                *
 *                                                                           *
 * - Description - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
 *                                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Cocoa/Cocoa.h>

@class IRCConversation;

@interface ConversationController : NSObject {
	IRCConversation *m_conversation;
}

- (id) initWithConversation:(IRCConversation*)conversation;

@property(readonly) IRCConversation *conversation;

- (bool) supportInputField;
- (bool) hasUserList;

- (bool) isLeaf;

- (NSArray*) userList;
- (NSArray*) messages;
- (NSString*) name;

- (bool) isShowTimeStamps;
- (void) setShowTimeStamps:(bool)showTimeStamps;

- (bool) isShowJoinMessages;
- (void) setShowJoinMessages:(bool)showJoinMessages;

- (bool) isShowPartMessages;
- (void) setShowPartMessages:(bool)showPartMessages;

- (bool) isShowQuitMessages;
- (void) setShowQuitMessages:(bool)showQuitMessages;

// Actions
- (IBAction) showOrHideTimeStamps:(id)sender;
- (IBAction) showOrHideJoinMessages:(id)sender;
- (IBAction) showOrHidePartMessages:(id)sender;
- (IBAction) showOrHideQuitMessages:(id)sender;

@end
