//
//  IRCPlugin.m
//  iRelayChat
//
//  Created by Christian Speich on 21.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCPlugin.h"


@implementation IRCPlugin

@synthesize pluginPath;

+ (void)initialize{
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
								 dictionaryWithObject:[NSArray array] forKey:@"LoadedPlugins"];
	
    [defaults registerDefaults:appDefaults];
}

- (id) initWithPath:(NSString*)path;
{
	self = [super init];
	if (self != nil) {
		pluginPath = [path retain];
		
		pluginBundle = [NSBundle bundleWithPath:path];
		
		if (!pluginBundle) {
			[self release];
			return nil;
		}
		
		/* Check if the PrincipalClass already exists */
		NSDictionary *pluginDict = [pluginBundle infoDictionary];
		NSString *pluginClassName = [pluginDict objectForKey:@"NSPrincipalClass"];
		if (!pluginClassName) {
			[self release];
			return nil;
		}
		identifier = [[pluginDict objectForKey:@"CFBundleIdentifier"] retain];

		Class pluginClass = NSClassFromString(pluginClassName);
		
		if (pluginClass) {
			[self release];
			return nil;
		}

		pluginClass = [pluginBundle principalClass];
		
		if (![pluginClass conformsToProtocol:@protocol(IRCPluginProtocol)]) {
			[self release];
			return nil;
		}
		
		pluginInstance = [[pluginClass alloc] init];
		
		NSArray *loadedPlugins = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoadedPlugins"];
		if ([loadedPlugins containsObject:identifier]) {
			[self load];
		}
	}
	return self;
}

- (NSString*) name
{
	return [pluginInstance name];
}

- (NSString*) version
{
	return [pluginInstance version];
}

- (NSString*) author
{
	return [pluginInstance author];
}

- (NSString*) description
{
	return [pluginInstance description];
}

- (NSImage*) icon
{
	return [pluginInstance icon];
}

- (bool) loaded
{
	return loaded;
}

- (void) setLoaded:(bool)new
{
	if (loaded != new) {
		if (new == YES)
			[self load];
		else
			[self unload];
	}
}

- (void) load
{
	if ([pluginInstance load]) {
		loaded = YES;
		NSMutableArray *tmp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LoadedPlugins"] mutableCopy];
		[tmp addObject:identifier];
		[[NSUserDefaults standardUserDefaults] setObject:tmp forKey:@"LoadedPlugins"];
		[tmp release];
	} else
		loaded = NO;
}

- (void) unload
{
	[pluginInstance unload];
	loaded = NO;
	NSMutableArray *tmp = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LoadedPlugins"] mutableCopy];
	[tmp removeObject:identifier];
	[[NSUserDefaults standardUserDefaults] setObject:tmp forKey:@"LoadedPlugins"];
	[tmp release];
}

@end
