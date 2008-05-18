//
//  MyDocument.h
//  iRelayChat
//
//  Created by Christian Speich on 17.04.08.
//  Copyright __MyCompanyName__ 2008 . All rights reserved.
//


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
