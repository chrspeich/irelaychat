//
//  IRCMessagesDebug.h
//  iRelayChat
//
//  Created by Christian Speich on 31.08.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PreferencePaneProtocol.h"

@interface IRCMessagesDebug : NSObject <SS_PreferencePaneProtocol> {
	IBOutlet NSView *prefsView;
	
	NSArray *serversArray;
}

@end
