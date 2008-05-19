//
//  DebugWindow.h
//  iRelayChat
//
//  Created by Christian Speich on 12.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IRCServer.h"
#import "SS_PrefsController.h"
#import "RegexKitDebug.h"
#import "IRCServerDebug.h"
#import "IRCUserDebug.h"

@interface DebugWindow : NSObject {
	IRCServer *server;
	SS_PrefsController *controller;
	
	RegexKitDebug *regexKitDebug;
	IRCServerDebug *serverDebug;
	IRCUserDebug *userDebug;
	
	IBOutlet NSTextField *cacheEnabled;
	IBOutlet NSTextField *cacheCount;
	IBOutlet NSTextField *cacheHitRate;
	IBOutlet NSTextField *cacheHits;
	IBOutlet NSTextField *cacheMisses;
	IBOutlet NSTextField *cacheTotal;
	IBOutlet NSTextField *regexVersion;
	
	IBOutlet NSTextField *ircUserCount;
	IBOutlet NSTableView *ircUsers;
	
	IBOutlet NSTextField *messagesCount;
	IBOutlet NSTableView *messagesTable;
		
	IBOutlet NSTextField *serverName;
	IBOutlet NSTextField *serverNick;
	IBOutlet NSTextField *serverRegisterdObservers;
	IBOutlet NSTextField *serverMissedMessage;
	IBOutlet NSTextField *serverIsConnected;
}

- (id) initWithServer:(IRCServer*)server;

@end
