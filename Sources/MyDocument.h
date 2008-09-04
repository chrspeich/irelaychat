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


#import <Cocoa/Cocoa.h>

@class ChannelView;
@class test;

@interface MyDocument : NSDocument
{
	IBOutlet NSOutlineView	*channelList;
	IBOutlet NSView			*contentView;
	IBOutlet NSTextField	*inputField;
	IBOutlet NSTableView	*userListTable;
	IBOutlet NSSplitView	*outlineSplitView;
	IBOutlet NSSplitView	*userListSplitView;
	IBOutlet NSTreeController *outlineController;
	IBOutlet NSArrayController *userListController;
	NSMutableArray			*servers;
	NSMutableArray			*channelViews;
	ChannelView				*currentView;
	
	NSMutableDictionary		*inputMessagesCache;
	
	id lastSelection;
}

- (IBAction) send:(id)sender;

@end
