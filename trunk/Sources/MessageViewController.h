//
//  MessageWindowController.h
//  iRelayChat
//
//  Created by Christian Speich on 03.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

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
