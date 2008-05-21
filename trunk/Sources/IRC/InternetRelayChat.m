//
//  InternetRelayChat.m
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "InternetRelayChat.h"
#import "IRCPlugin.h"

@implementation InternetRelayChat

@synthesize servers, plugins;

- (id) init
{
	self = [super init];
	if (self != nil) {
		servers = [[NSMutableArray alloc] init];
		plugins = [[NSMutableArray alloc] init];
		[self searchForPlugins];
	}
	return self;
}

- (void) searchForPlugins
{
	NSString *pluginPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/Contents/PlugIns/"];

	NSArray *pluginsDirArray = [[NSFileManager alloc] directoryContentsAtPath:pluginPath];
	
	for (NSString *path in pluginsDirArray) {
		IRCPlugin *plugin = [[IRCPlugin alloc] initWithPath:path];
		if (plugin)
			[plugins addObject:plugin];
		[plugin release];
	}
}

+ (id) sharedInternetRelayChat
{
	static id shared = nil;
	
	if (!shared)
		shared = [[self alloc] init];
	
	return shared;
}

@end
