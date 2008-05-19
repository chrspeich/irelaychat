//
//  IRCUserDebug.m
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCUserDebug.h"
#import "InternetRelayChat.h"

@implementation IRCUserDebug

- (id) init
{
	self = [super init];
	if (self != nil) {
		prefsView = nil;
		currentUser = nil;
		currentServer = [[[InternetRelayChat sharedInternetRelayChat] servers] objectAtIndex:0];
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
        loaded = [NSBundle loadNibNamed:@"IRCUserDebug" owner:self];
    }
    
    if (loaded) {
        return prefsView;
    }
    
    return nil;
}


- (NSString *)paneName
{
    return @"Users";
}


- (NSImage *)paneIcon
{
    return [NSImage imageNamed:@"NSEveryone"];
}


- (NSString *)paneToolTip
{
    return @"Users";
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

	if (currentUser) {
		[nickname setStringValue:[currentUser nickname]];
		[username setStringValue:([currentUser user]?[currentUser user]:@"-")];
		[host setStringValue:([currentUser host]?[currentUser host]:@"-")];
		[me setStringValue:(currentUser.isMe?@"Yes":@"No")];
	}
	else {
		[nickname setStringValue:@"-"];
		[username setStringValue:@"-"];
		[host setStringValue:@"-"];
		[me setStringValue:@"-"];
	}
	
	[usersTable reloadData];
	
	[pool release];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[currentServer knownUsers] count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	NSParameterAssert(rowIndex >= 0 && rowIndex < [[currentServer knownUsers] count]);
	
	return [[[currentServer knownUsers] objectAtIndex:rowIndex] nickname];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	NSParameterAssert(rowIndex >= 0 && rowIndex < [[currentServer knownUsers] count]);

	currentUser = [[currentServer knownUsers] objectAtIndex:rowIndex];
	[self update];
	return YES;
}

@end
