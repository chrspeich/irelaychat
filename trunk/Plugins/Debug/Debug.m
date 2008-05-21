//
//  Debug.m
//  iRelayChat
//
//  Created by Christian Speich on 21.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Debug.h"


@implementation Debug

- (id) init
{
	self = [super init];
	if (self != nil) {
		menuItem = [[NSMenuItem alloc] initWithTitle:@"Debug Window" action:@selector(showDebugWindow:) keyEquivalent:@""];
		[menuItem setTarget:self];
		
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

- (NSString*) name
{
	return @"Debug";
}

- (NSString*) version
{
	return @"0.0.1";
}

- (NSString*) author
{
	return @"Christian Speich";
}

- (NSString*) description
{
	return @"Adds a Debug Window.";
}

- (NSImage*) icon
{
	return nil;
}

- (bool) load
{
	NSMenu *mainMenu = [NSApp mainMenu];
	NSMenu *windowMenu = [[mainMenu itemAtIndex:[mainMenu numberOfItems]-2] submenu];
	[windowMenu insertItem:menuItem atIndex:6];
	
	return YES;
}

- (void) unload
{
	NSMenu *mainMenu = [NSApp mainMenu];
	NSMenu *windowMenu = [[mainMenu itemAtIndex:[mainMenu numberOfItems]-2] submenu];
	
	if ([windowMenu indexOfItem:menuItem] >= 0)
		[windowMenu removeItem:menuItem];
}

- (void) showDebugWindow:(id)sender
{
	[controller showPreferencesWindow];
}

- (void) update
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[regexKitDebug update];
	[serverDebug update];
	
	[pool release];
}

@end
