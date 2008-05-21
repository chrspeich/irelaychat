/*
 *  IRCPluginProtocol.h
 *  iRelayChat
 *
 *  Created by Christian Speich on 21.05.08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

@protocol IRCPluginProtocol

- (NSString*) name;
- (NSString*) version;
- (NSString*) author;
- (NSString*) description;
- (NSImage*) icon;
- (bool) load;
- (void) unload;

@end