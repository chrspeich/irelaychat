/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * iRelayChat - A better IRC Client for Mac OS X                             *
 * - Frontend Class -                                                        *
 *                                                                           *
 * Copyright 2008 by Christian Speich <kontakt@kleinweby.de>                 *
 *                                                                           *
 * Licenced under GPL v3 or later. See 'Copying' for details.                *
 *                                                                           *
 * - Description - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
 *                                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class IRCChannelMessage;

@interface MessageViewController : NSObject {
	WebView		*messageView;
}

- (id) initWithMessageView:(WebView*)messageView;
- (void) loadTemplate;

- (void) addMessage:(IRCChannelMessage*)message;
- (void) userJoins:(NSString*)user channel:(NSString*)channel;
- (void) userLeaves:(NSString*)user channel:(NSString*)channel;
- (void) userQuit:(NSString*)user withMessage:(NSString*)message;
- (void) user:(NSString*)user remove:(NSString*)mode toUser:(NSString*)user2;
- (void) user:(NSString*)user give:(NSString*)mode toUser:(NSString*)user2;

- (NSString*) escapeString:(NSString*)string;

@end
