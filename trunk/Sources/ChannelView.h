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
@property(readonly) IRCChannel *channel;

@end
