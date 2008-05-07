//
//  ChannelView.m
//  iRelayChat
//
//  Created by Christian Speich on 02.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ChannelView.h"
#import "IRCServer.h"
#import "IRCUser.h"

@implementation ChannelView

@synthesize view=channelView, inputField;

- (id) initWithChannel:(IRCChannel*)chan
{
	self = [super init];
	if (self != nil) {
		channel = [chan retain];
		if (![NSBundle loadNibNamed:@"ChannelView" owner:self]) {
			[self release];
			return nil;
		}
		[userTable reloadData];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUserTable:) name:IRCUserListHasChanged object:channel];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMessage:) name:IRCNewChannelMessage object:channel];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userJoins:) name:IRCUserJoinsChannel object:channel];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLeaves:) name:IRCUserLeavesChannel object:channel];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userQuit:) name:IRCUserQuit object:channel.server];
		messageViewController = [[MessageViewController alloc] initWithMessageView:messageView];
	}
	return self;
}

- (void) reloadUserTable:(NSNotification*)unused
{
	NSLog(@"reload");
	[userTable reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSLog(@"count %i", [channel.userList count]);
	return [channel.userList count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	NSParameterAssert(rowIndex >= 0 && rowIndex < [channel.userList count]);
	return [channel.userList objectAtIndex:rowIndex];
}

- (void) newMessage:(NSNotification*)noti
{
	NSDictionary *dict = [noti userInfo];
	
	[messageViewController addMessage:[dict objectForKey:@"MESSAGE"] fromUser:[[dict objectForKey:@"FROM"] nickname] highlighted:NO];
}

- (void) userJoins:(NSNotification*)noti
{
	NSDictionary *dict = [noti userInfo];
	
	[messageViewController userJoins:[[dict objectForKey:@"FROM"] nickname] channel:[channel name]];
}

- (void) userLeaves:(NSNotification*)noti
{
	NSDictionary *dict = [noti userInfo];
	
	[messageViewController userLeaves:[[dict objectForKey:@"FROM"] nickname] channel:[channel name]];
}

- (void) userQuit:(NSNotification*)noti
{
	NSDictionary *dict = [noti userInfo];

	[messageViewController userQuit:[[dict objectForKey:@"FROM"] nickname] withMessage:[dict objectForKey:@"MESSAGE"]];
}

- (void)splitView:(NSSplitView*)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
	NSRect newFrame = [sender frame];
	NSView *left = [[sender subviews] objectAtIndex:0];
	NSRect leftFrame = [left frame];
	NSView *right = [[sender subviews] objectAtIndex:1];
	NSRect rightFrame = [right frame];
	
	CGFloat dividerThickness = [sender dividerThickness];
	
	leftFrame.size.height = newFrame.size.height;
	rightFrame.size.height = newFrame.size.height;
	
	leftFrame.size.width = newFrame.size.width - rightFrame.size.width 
	- dividerThickness;
	rightFrame.origin.x = leftFrame.size.width + dividerThickness;
	
	[left setFrame:leftFrame];
	[right setFrame:rightFrame];
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
	NSRect oldInputFrame = [inputField frame];
	oldInputFrame.size.width = [messageView frame].size.width - 16.f;
	[inputField setFrame:oldInputFrame];
}

- (void) sendMessage
{
	if ([[inputField stringValue] isEqualToString:@""])
		return;
	
	[channel sendMessage:[inputField stringValue]];
	[messageViewController addMyMessage:[inputField stringValue] withUserName:[[channel server] nick]];
	[inputField setStringValue:@""];
}

@end