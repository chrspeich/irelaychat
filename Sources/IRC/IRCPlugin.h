//
//  IRCPlugin.h
//  iRelayChat
//
//  Created by Christian Speich on 21.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IRCPluginProtocol.h"

@interface IRCPlugin : NSObject {
	NSString	*pluginPath;
	NSBundle	*pluginBundle;
	NSString	*identifier;
	id<IRCPluginProtocol> pluginInstance;
	bool		loaded;
}

- (id) initWithPath:(NSString*)path;
- (void) load;
- (void) unload;

@property(readonly)	NSString *pluginPath;
@property(readonly) NSString *name;
@property(readonly) NSString *author;
@property(readonly) NSString *description;
@property(readonly) NSImage *icon;
@property bool loaded;

@end
