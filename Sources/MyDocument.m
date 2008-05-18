/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * iRelayChat - A better IRC Client for Mac OS X                             *
 * - Frontend Class -                                                        *
 *                                                                           *
 * Copyright 2008 by Christian Speich <kontakt@kleinweby.de>                 *
 *                                                                           *
 * Licenced under GPL v3 or later. See 'Copying' for details.                *
 *                                                                           *
 * - Description - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
 *                                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "MyDocument.h"
#import "IRCServer.h"
#import "ChannelView.h"
#import <RegexKit/RegexKit.h>
#import "DebugWindow.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
		servers = [[NSMutableArray alloc] init];
		channelViews = [[NSMutableArray alloc] init];
		IRCServer *server = [[IRCServer alloc] initWithHost:@"localhost" andPort:@"6667"];
		[server connect];
		[server joinChannel:@"#Apachefriends"];
		[server joinChannel:@"#Linuxpaten"];
		[server joinChannel:@"#ubuntu"];
		[servers addObject:server];
		[server release];
		[[DebugWindow alloc] initWithServer:server];
    }
    return self;
}

- (NSString *)windowNibName
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
	for (IRCChannel *chan in [[servers objectAtIndex:0] channels]) {
		[channelViews addObject:[[ChannelView alloc] initWithChannel:chan]];
	}
	[[aController window] setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
	[[aController window] setContentBorderThickness:35 forEdge:NSMinYEdge];
	[self performSelector:@selector(splitViewDidResizeSubviews:) withObject:nil];
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item == nil) {
		return [servers count];
	}
	else if ([item isKindOfClass:[IRCServer class]]) {
		return [channelViews count];
	}
	
    return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	if ([item isKindOfClass:[IRCServer class]]) {
		return YES;
	}
	return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView
			child:(int)index
		   ofItem:(id)item
{
    if (item == nil) {
		return [servers objectAtIndex:index];
	}
	else {
		return [channelViews objectAtIndex:index];
	}

	return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
		   byItem:(id)item
{
	if ([[tableColumn identifier] isEqualToString:@"TitleColumn"]) {
		if ([item isKindOfClass:[IRCServer class]]) {
			return [item serverName];
		}
		else {
			return [[item channel] name];
		}
	}
	else {
		return @"";
	}
}

-(BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item
{
	if ([item isKindOfClass:[IRCServer class]]) {
		return YES;
	}
	return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
	if ([item isKindOfClass:[IRCServer class]]) {
		return NO;
	}
	
	if (currentView != item) {
		currentView.inputField = nil;
		[currentView.view removeFromSuperview];
		[contentView addSubview:[item view]];
		currentView = item;
		currentView.inputField = inputField;
		[currentView.view setFrame:[contentView bounds]];
		[inputField setTarget:currentView];
		[inputField setAction:@selector(sendMessage)];
	}
	return YES;
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
	
	rightFrame.size.width = newFrame.size.width - leftFrame.size.width 
	- dividerThickness;
	rightFrame.size.height = newFrame.size.height;
	rightFrame.origin.x = leftFrame.size.width + dividerThickness;
	
	[left setFrame:leftFrame];
	[right setFrame:rightFrame];
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
	NSRect oldInputFrame = [inputField frame];
	oldInputFrame.origin.x = [channelList frame].size.width + [channelList frame].origin.x + 8.f;
	[inputField setFrame:oldInputFrame];
}

@end
