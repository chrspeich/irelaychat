//
//  Preferences.m
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Preferences.h"
#import "PreferenceGeneral.h"

@implementation Preferences

- (id) init
{
	self = [super init];
	if (self != nil) {
		controller = [[SS_PrefsController alloc] init];
		[controller addPreferencePane:[[PreferenceGeneral alloc] init]];
	} 
	return self;
}


- (IBAction) showPreferencesWindow:(id)sender
{
	[controller showPreferencesWindow];
}

@end
