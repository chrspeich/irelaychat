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
#import "InternetRelayChat.h"
#import <RegexKit/RegexKit.h>
#import "IRCUserMode.h"
#import "NSObject+Unproxy.h"
#import "HTMLCache.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
		servers = [[NSMutableArray alloc] init];
		channelViews = [[NSMutableArray alloc] init];
		
		[HTMLCache sharedCache];
		
		IRCServer *server = [[IRCServer alloc] initWithHost:@"localhost" andPort:@"6667"];
		[server connect];
		[server joinChannel:@"#ubuntu-de"];
//[server joinChannel:@"#Linuxpaten"];
		[server joinChannel:@"#ubuntu"];
		[servers addObject:server];
		[server release];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserListTable:) name:IRCUserListHasChanged object:nil];
    }
    return self;
}

- (void) applicationDidFinishLaunching:(NSNotification*)noti
{
	[[InternetRelayChat sharedInternetRelayChat] searchForPlugins];
}

- (NSString *)windowNibName
{
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
/*	for (IRCChannel *chan in [[servers objectAtIndex:0] channels]) {
		[channelViews addObject:[[ChannelView alloc] initWithChannel:chan]];
	}*/
	[[aController window] setAutorecalculatesContentBorderThickness:YES forEdge:NSMinYEdge];
	[[aController window] setContentBorderThickness:35 forEdge:NSMinYEdge];
	[contentView bind:@"content" toObject:outlineController withKeyPath:@"selection" options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
																														 forKey:@"NSContinuouslyUpdatesValue"]];
	[outlineController addObserver:contentView forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:nil];
	[self performSelector:@selector(splitViewDidResizeSubviews:) withObject:nil];
}

/*- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
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
*/
-(BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item
{
	if ([[[item self] representedObject] isKindOfClass:[IRCServer class]]) {
		return YES;
	}
	return NO;
}

/*- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
	if ([[[item self] representedObject] isKindOfClass:[IRCServer class]]) {
		return NO;
	}
	
/*	if (currentView != item) {
		currentView.inputField = nil;
		[currentView.view removeFromSuperview];
		[contentView addSubview:[item view]];
		currentView = item;
		currentView.inputField = inputField;
		[currentView.view setFrame:[contentView bounds]];
		[inputField setTarget:currentView];
		[inputField setAction:@selector(sendMessage)];
	}*
	return YES;
}*/

- (void) refreshUserListTable:(NSNotification*)noti
{
	[userListController rearrangeObjects];
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

	if (sender == outlineSplitView) {
		rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;
		rightFrame.origin.x = leftFrame.size.width + dividerThickness;
	}
	else {
		leftFrame.size.width = newFrame.size.width - rightFrame.size.width - dividerThickness;
		rightFrame.origin.x = leftFrame.size.width + dividerThickness;
	}
	
	[left setFrame:leftFrame];
	[right setFrame:rightFrame];
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
	NSRect oldInputFrame = [inputField frame];
	oldInputFrame.origin.x = [channelList frame].size.width + [channelList frame].origin.x + 8.f;
	oldInputFrame.size.width = [contentView frame].size.width - 16.f;
	[inputField setFrame:oldInputFrame];
}

/*- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[userListController arrangedObjects] count];
}*/

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	NSParameterAssert(rowIndex >= 0 && rowIndex < [[userListController arrangedObjects] count]);
	if ([[aTableColumn identifier] isEqualToString:@"Name"]) {
		return [[[userListController arrangedObjects] objectAtIndex:rowIndex] nickname];
	}
	else {
		IRCUserMode *mode = [[[userListController arrangedObjects] objectAtIndex:rowIndex] userModeForChannel:[[outlineController selection] unproxy]];
		
		NSImage *image = nil;
		if ([mode hasOp]) {
			image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"green" ofType:@"tiff"]];
		}
		else if ([mode hasVoice]) {
			image = [[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"yellow" ofType:@"tiff"]];
		}
		else
			image = [[NSImage alloc] init];
		
		[image autorelease];
		return image;
	}
}


@end
