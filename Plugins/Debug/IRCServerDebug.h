//
//  IRCServerDebug.h
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PreferencePaneProtocol.h"
#import "IRCServer.h"b

@interface IRCServerDebug : NSObject <SS_PreferencePaneProtocol> {
	IBOutlet NSView *prefsView;
	
	IBOutlet NSTextField *serverName;
	IBOutlet NSTextField *serverNick;
	IBOutlet NSTextField *serverRegisterdObservers;
	IBOutlet NSTextField *serverMissedMessage;
	IBOutlet NSTextField *serverIsConnected;
	
	IBOutlet NSTableView *serversTable;
	IBOutlet NSTableView *observersTable;
	
	IRCServer *currentServer;
}

- (void) update;

@end
