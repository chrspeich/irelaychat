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

@interface MyDocument : NSDocument
{
	IBOutlet NSOutlineView	*channelList;
	IBOutlet NSView			*contentView;
	IBOutlet NSTextField	*inputField;
	NSMutableArray			*servers;
	NSMutableArray			*channelViews;
	ChannelView				*currentView;
}
@end
