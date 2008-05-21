//
//  RegexKitDebug.h
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PreferencePaneProtocol.h"

@interface RegexKitDebug : NSObject <SS_PreferencePaneProtocol> {
	IBOutlet NSView *prefsView;
	
	IBOutlet NSTextField *cacheEnabled;
	IBOutlet NSTextField *cacheCount;
	IBOutlet NSTextField *cacheHitRate;
	IBOutlet NSTextField *cacheHits;
	IBOutlet NSTextField *cacheMisses;
	IBOutlet NSTextField *cacheTotal;
	IBOutlet NSTextField *regexVersion;
}

- (void) update;

@end
