//
//  MessageWindowController.h
//  iRelayChat
//
//  Created by Christian Speich on 03.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface MessageViewController : NSObject {
	WebView		*messageView;
}

- (id) initWithMessageView:(WebView*)messageView;
- (void) loadTemplate;

- (void) addMessage:(NSString*)message fromUser:(NSString*)user highlighted:(BOOL)highlighted;
- (void) addMyMessage:(NSString*)message withUserName:(NSString*)user;
- (void) userJoins:(NSString*)user channel:(NSString*)channel;
- (void) userLeaves:(NSString*)user channel:(NSString*)channel;
- (void) userQuit:(NSString*)user withMessage:(NSString*)message;

- (NSString*) escapeString:(NSString*)string;

@end
