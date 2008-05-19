//
//  IRCUserDebug.h
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PreferencePaneProtocol.h"
#import "IRCServer.h"
#import "IRCUser.h"

@interface IRCUserDebug : NSObject <SS_PreferencePaneProtocol> {
	IBOutlet NSView *prefsView;
	
	IRCServer *currentServer;
	IRCUser *currentUser;
	
	IBOutlet NSTableView *usersTable;
	IBOutlet NSTextField *nickname;
	IBOutlet NSTextField *username;
	IBOutlet NSTextField *host;
	IBOutlet NSTextField *me;
	IBOutlet NSPopUpButton *servers;
}

- (void) update;

@end
