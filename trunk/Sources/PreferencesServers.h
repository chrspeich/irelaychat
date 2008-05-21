//
//  PreferencesServers.h
//  iRelayChat
//
//  Created by Christian Speich on 21.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PreferencePaneProtocol.h"

@interface PreferencesServers : NSObject <SS_PreferencePaneProtocol> {
	IBOutlet NSView *prefsView;
	
	NSArray *serversArray;
}

@end
