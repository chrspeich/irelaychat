//
//  ChannelView.h
//  iRelayChat
//
//  Created by Christian Speich on 02.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "IRCChannel.h"
#import "MessageViewController.h"

@interface ChannelView : NSObject {
	IBOutlet NSView			*channelView;
	IBOutlet NSTableView	*userTable;
	IBOutlet WebView		*messageView;
	MessageViewController	*messageViewController;
	IRCChannel				*channel;
	NSTextField				*inputField;
}

- (id) initWithChannel:(IRCChannel*)channel;
- (void) sendMessage;

@property(readonly,assign) NSView *view;
@property(retain) NSTextField *inputField;

@end
