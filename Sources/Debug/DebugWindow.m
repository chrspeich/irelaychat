//
//  DebugWindow.m
//  iRelayChat
//
//  Created by Christian Speich on 12.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DebugWindow.h"
#import <RegexKit/RegexKit.h>
#import "IRCUser.h"

@implementation DebugWindow

- (id) init;
{
	self = [super init];
	if (self != nil) {
		regexKitDebug = [[RegexKitDebug alloc] init];
		serverDebug = [[IRCServerDebug alloc] init];
		userDebug = [[IRCUserDebug alloc] init];
		
		controller = [[SS_PrefsController alloc] init];
		[controller setDebug:YES];
		
		[controller addPreferencePane:regexKitDebug];
		[controller addPreferencePane:serverDebug];
		[controller addPreferencePane:userDebug];
				
		[NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(update) userInfo:nil repeats:YES];
	}
	return self;
}

- (void) update
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[regexKitDebug update];
	[serverDebug update];

	[pool release];
}

- (IBAction) showWindow:(id)sender
{
	[controller showPreferencesWindow];	
}

@end
