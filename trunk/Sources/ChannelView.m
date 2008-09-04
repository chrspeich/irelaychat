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

#import "ChannelView.h"
#import "IRCServer.h"
#import "IRCUser.h"
#import "IRCChannel.h"
#import "IRCUserMode.h"

@implementation ChannelView

@synthesize view=channelView, inputField, channel;

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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userQuit:) name:@"test" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLooesMode:) name:IRCUserHasLoseMode object:channel];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userGotMode:) name:IRCUserHasGotMode object:channel];
		[messageView setMaintainsBackForwardList:NO];
		[messageView setPolicyDelegate:self];
		messageViewController = [[MessageViewController alloc] initWithMessageView:messageView];
		NSImageCell *cell = [[NSImageCell alloc] init];
		[cell setImageAlignment:NSImageAlignCenter];
		[cell autorelease];
		[[userTable tableColumnWithIdentifier:@"Status"] setDataCell:cell];
	}
	return self;
}

- (void) reloadUserTable:(NSNotification*)unused
{
	[userTable reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [channel.userList count];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	NSParameterAssert(rowIndex >= 0 && rowIndex < [channel.userList count]);
	if ([[aTableColumn identifier] isEqualToString:@"Name"]) {
		return [[channel.userList objectAtIndex:rowIndex] nickname];
	}
	else {
		IRCUserMode *mode = [[channel.userList objectAtIndex:rowIndex] userModeForChannel:channel];
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

- (void) newMessage:(NSNotification*)noti
{
	NSDictionary *dict = [noti userInfo];
	
	[messageViewController addMessage:[dict objectForKey:@"MESSAGE"]];
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
	NSLog(@"quittttt %@", noti);
	[messageViewController userQuit:[[dict objectForKey:@"FROM"] nickname] withMessage:[dict objectForKey:@"MESSAGE"]];
}

- (void) userLooesMode:(NSNotification*)noti
{
	NSDictionary *dict = [noti userInfo];

	[messageViewController user:[[dict objectForKey:@"FROM"] nickname] remove:[dict objectForKey:@"MODE"] toUser:[[dict objectForKey:@"USER"] nickname]];
}

- (void) userGotMode:(NSNotification*)noti
{
	NSDictionary *dict = [noti userInfo];
	
	[messageViewController user:[[dict objectForKey:@"FROM"] nickname] give:[dict objectForKey:@"MODE"] toUser:[[dict objectForKey:@"USER"] nickname]];
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
	[inputField setStringValue:@""];
}

- (void)webView:(WebView *)sender
decidePolicyForNavigationAction:(NSDictionary *)actionInformation
		request:(NSURLRequest *)request
		  frame:(WebFrame *)frame
decisionListener:(id<WebPolicyDecisionListener>)listener
{
	NSLog(@"test");
	int actionKey = [[actionInformation objectForKey: WebActionNavigationTypeKey] intValue];
	if (actionKey == WebNavigationTypeOther) {
		[listener use];
	} else {
		NSURL *url = [actionInformation objectForKey:WebActionOriginalURLKey];
		
		//Ignore file URLs, but open anything else
		if (![url isFileURL]) {
			[[NSWorkspace sharedWorkspace] openURL:url];
		}
		
		[listener ignore];
	}
}

@end
