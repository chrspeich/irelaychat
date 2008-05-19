//
//  IRCServerDebug.m
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCServerDebug.h"
#import "InternetRelayChat.h"
#import "IRCUser.h"

@implementation IRCServerDebug

- (id) init
{
	self = [super init];
	if (self != nil) {
		prefsView = nil;
	}
	return self;
}


+ (NSArray*) preferencePanes
{
	return nil;
}

- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefsView) {
        loaded = [NSBundle loadNibNamed:@"IRCServerDebug" owner:self];
    }
    
    if (loaded) {
        return prefsView;
    }
    
    return nil;
}


- (NSString *)paneName
{
    return @"Servers";
}


- (NSImage *)paneIcon
{
    return [NSImage imageNamed:@"NSNetwork"];
}


- (NSString *)paneToolTip
{
    return @"Servers";
}


- (BOOL)allowsHorizontalResizing
{
    return NO;
}


- (BOOL)allowsVerticalResizing
{
    return NO;
}

- (void) update
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (currentServer) {
		[serverName setStringValue:[currentServer serverName]];
		[serverNick setStringValue:[currentServer.me nickname]];
		[serverRegisterdObservers setIntValue:[[currentServer registerdObservers] count]];
		[serverMissedMessage setIntValue:[currentServer missedMessages]];
		[serverIsConnected setStringValue:currentServer.isConnected?@"Yes":@"No"];
	}
	else {
		[serverName setStringValue:@"-"];
		[serverNick setStringValue:@"-"];
		[serverRegisterdObservers setStringValue:@"-"];
		[serverMissedMessage setStringValue:@"-"];
		[serverIsConnected setStringValue:@"-"];
	}
	
	[observersTable reloadData];
	[pool release];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if (aTableView == serversTable)
		return [[[InternetRelayChat sharedInternetRelayChat] servers] count];
	else if (aTableView == observersTable)
		return [[currentServer registerdObservers] count];
	else
		return 0;
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	if (aTableView == serversTable) {
		NSParameterAssert(rowIndex >= 0 && rowIndex < [[[InternetRelayChat sharedInternetRelayChat] servers] count]);
		
		IRCServer *server = [[[InternetRelayChat sharedInternetRelayChat] servers] objectAtIndex:rowIndex];
		
		if ([[aTableColumn identifier] isEqualToString:@"status"]) {
			NSImage *image = nil;
			
			if (server.isConnected)
				image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"green" ofType:@"tiff"]];
			else
				image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"red" ofType:@"tiff"]];
			
			return [image autorelease];
		}
		else if ([[aTableColumn identifier] isEqualToString:@"servername"]) {
			return server.serverName;
		}
	}
	else if (aTableView == observersTable) {
		NSParameterAssert(rowIndex >= 0 && rowIndex < [[currentServer registerdObservers] count]);
		NSDictionary *dict = [[currentServer registerdObservers] objectAtIndex:rowIndex];
		
		if ([[aTableColumn identifier] isEqualToString:@"object"])
			return [NSString stringWithFormat:@"%@(%p)", NSStringFromClass([[dict objectForKey:@"OBSERVER"] class]), [dict objectForKey:@"OBSERVER"]];
		else if ([[aTableColumn identifier] isEqualToString:@"selector"])
			return [dict objectForKey:@"SELECTOR"];
		else
			return [dict objectForKey:@"PATTERN"];
	}
	return Nil;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	if (aTableView == serversTable) {
		NSParameterAssert(rowIndex < [[[InternetRelayChat sharedInternetRelayChat] servers] count]);
		
		if (rowIndex < 0)
			currentServer = nil;
		else
			currentServer = [[[InternetRelayChat sharedInternetRelayChat] servers] objectAtIndex:rowIndex];
		[self update];
	}
	return YES;
}

@end
