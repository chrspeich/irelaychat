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
#import "IRCMessage.h"
#import "IRCObserveContainer.h"

@implementation DebugWindow

- (id) initWithServer:(IRCServer*)inServer;
{
	self = [super init];
	if (self != nil) {
		server = [inServer retain];
		
		if (![NSBundle loadNibNamed:@"DebugWindow" owner:self]) {
			[self release];
			return nil;
		}
		
		messages = [[NSMutableArray alloc] init];
		
		[regexVersion setStringValue:[RKRegex PCREVersionString]];
		[server addObserver:self selector:@selector(addMessage:) message:[[IRCMessage alloc] initWithCommand:@"*" from:nil andPrarameters:nil]];
		
		[NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(update) userInfo:nil repeats:YES];
	}
	return self;
}

- (void) update
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *cacheStatusString = [[RKRegex regexCache] status];
	
	NSArray *components = [cacheStatusString componentsSeparatedByString:@","];

	[cacheEnabled setStringValue:[[[components objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:2]];
	[cacheCount setStringValue:[[[components objectAtIndex:3] componentsSeparatedByString:@" "] lastObject]];
	[cacheHitRate setStringValue:[[[components objectAtIndex:4] componentsSeparatedByString:@" "] lastObject]];
	[cacheHits setStringValue:[[[components objectAtIndex:5] componentsSeparatedByString:@" "] lastObject]];
	[cacheMisses setStringValue:[[[components objectAtIndex:6] componentsSeparatedByString:@" "] lastObject]];
	[cacheTotal setStringValue:[[[components objectAtIndex:7] componentsSeparatedByString:@" "] lastObject]];
	
	[ircUserCount setIntValue:[[server knownUsers] count]];
	[ircUsers reloadData];
	
	[serverName setStringValue:[server serverName]];
	[serverNick setStringValue:[server.me nickname]];
	[serverRegisterdObservers setIntValue:[[server registerdObservers] count]];
	[serverMissedMessage setIntValue:[server missedMessages]];
	[serverIsConnected setStringValue:server.isConnected?@"Yes":@"No"];

	[pool release];
}

- (void) addMessage:(IRCMessage*)message
{

	[messagesCount setIntValue:[server.messages count]];
	[messagesTable reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	if (aTableView == ircUsers)
		return [[server knownUsers] count];
	else if (aTableView == messagesTable)
		return [server.messages count];
	else
		return [[server registerdObservers] count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	if (aTableView == ircUsers) {
		NSParameterAssert(rowIndex >= 0 && rowIndex < [[server knownUsers] count]);
		if ([[aTableColumn identifier] isEqualToString:@"nick"]) {
			return [[[server knownUsers] objectAtIndex:rowIndex] nickname];
		}
		else if ([[aTableColumn identifier] isEqualToString:@"user"]) {
			return [[[server knownUsers] objectAtIndex:rowIndex] user];
		}
		else if ([[aTableColumn identifier] isEqualToString:@"host"]) {
			return [[[server knownUsers] objectAtIndex:rowIndex] host];
		}
	}
	else if (aTableView == messagesTable) {
		NSParameterAssert(rowIndex >= 0 && rowIndex < [server.messages count]);
		NSDictionary *dict = [server.messages objectAtIndex:-(rowIndex-[server.messages count])-1];
		NSMutableAttributedString *string;
		if ([[aTableColumn identifier] isEqualToString:@"time"]) {
			string = [[NSMutableAttributedString alloc] initWithString:[dict objectForKey:@"TIME"]];
		} else if ([[aTableColumn identifier] isEqualToString:@"message"]) {
			string = [[NSMutableAttributedString alloc] initWithString:[dict objectForKey:@"MESSAGE"]];
		}
		
		if ([[dict valueForKey:@"MISSED"] isEqualToString:@"YES"]) {
			[string beginEditing];
			[string addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [string length])];
			[string endEditing];
		}
		return [string autorelease];
	}
	else {
		NSParameterAssert(rowIndex >= 0 && rowIndex < [[server registerdObservers] count]);
		IRCObserveContainer *container = [[server registerdObservers] objectAtIndex:rowIndex];
		
		if ([[aTableColumn identifier] isEqualToString:@"object"])
			return [NSString stringWithFormat:@"%@(%p)", NSStringFromClass([container.observer class]), container.observer];
		else if ([[aTableColumn identifier] isEqualToString:@"selector"])
			return NSStringFromSelector(container.selector);
		else
			return container.pattern;
			
	}

	return @"";
}

@end
