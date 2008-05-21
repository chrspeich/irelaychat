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
}

- (IBAction) showWindow:(id)sender;

@end
