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
		inputMessagesCache = [[NSMutableDictionary alloc] init];
		
		[HTMLCache sharedCache];
		
		IRCServer *server = [[IRCServer alloc] initWithHost:@"localhost" andPort:@"6667"];
		[server connect];
		[server joinChannel:@"#ubuntu"];
//		[server joinChannel:@"#Linuxpaten"];
//		[server joinChannel:@"#test"];
		[servers addObject:server];
		[server release];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserListTable:) name:IRCUserListHasChanged object:nil];
    }
    return self;
}

- (void) applicationDidFinishLaunching:(NSNotification*)noti
{
	NSLog(@"test");
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
	[outlineController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:nil];
	[self performSelector:@selector(splitViewDidResizeSubviews:) withObject:nil];
}

-(BOOL)outlineView:(NSOutlineView*)outlineView isGroupItem:(id)item
{
	if ([[[item self] representedObject] isKindOfClass:[IRCServer class]]) {
		return YES;
	}
	return NO;
}

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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"selection"]) {
		if ([[outlineController.selection unproxy] supportInputField]) {
			[inputField setHidden:NO];
		}
		else {
			[inputField setHidden:YES];
		}

		if (![[inputField stringValue] isEqualToString:@""] && lastSelection != nil) {
			[inputMessagesCache setObject:[inputField stringValue] forKey:[lastSelection name]];
		}
		
		if ([inputMessagesCache objectForKey:[[outlineController.selection unproxy] name]] != nil) {
			[inputField setStringValue:[inputMessagesCache objectForKey:[[outlineController.selection unproxy] name]]];
		}
		else {
			[inputField setStringValue:@""];
		}
		
		lastSelection = [outlineController.selection unproxy];
	}
}

- (IBAction) send:(id)sender
{
	if (![[inputField stringValue] isEqualToString:@""]) {
		[[outlineController.selection unproxy] sendMessage:[inputField stringValue]];
		[inputMessagesCache removeObjectForKey:[[outlineController.selection unproxy] name]];
		[inputField setStringValue:@""];
	}
}

@end
