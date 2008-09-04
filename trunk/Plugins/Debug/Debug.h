//
//  Debug.h
//  iRelayChat
//
//  Created by Christian Speich on 21.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PrefsController.h"
#import "RegexKitDebug.h"
#import "IRCServerDebug.h"
#import "IRCUserDebug.h"
#import "IRCMessagesDebug.h"
#import "IRCPluginProtocol.h"

@interface Debug : NSObject <IRCPluginProtocol> {
	NSMenuItem *menuItem;
	
	SS_PrefsController *controller;
	
	RegexKitDebug *regexKitDebug;
	IRCServerDebug *serverDebug;
	IRCUserDebug *userDebug;
	IRCMessagesDebug *messagesDebug;
}

@end
