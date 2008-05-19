//
//  Preferences.h
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PrefsController.h"

@interface Preferences : NSObject {
	SS_PrefsController *controller;
}

- (IBAction) showPreferencesWindow:(id)sender;

@end
