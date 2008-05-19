//
//  PreferenceGeneral.h
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PreferencePaneProtocol.h"

@interface PreferenceGeneral : NSObject <SS_PreferencePaneProtocol> {
	IBOutlet NSView *prefsView;
}

@end
