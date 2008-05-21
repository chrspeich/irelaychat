//
//  TestPlugin.m
//  iRelayChat
//
//  Created by Christian Speich on 21.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "TestPlugin.h"

static int plugins = 0;

@implementation TestPlugin

- (id) init
{
	self = [super init];
	if (self != nil) {
		plugins++;
		_id = plugins;
	}
	return self;
}


- (NSString*) name
{
	return [NSString stringWithFormat:@"Test Plugin %i", _id];
}

- (NSString*) version
{
	return @"0.5.1";
}

- (NSString*) author
{
	return @"Christian Speich";
}

- (NSString*) description
{
	return @"No Description";
}

- (NSImage*) icon
{
	//return nil;
	return [[[NSImage alloc] initWithContentsOfFile:
	  [[NSBundle bundleForClass:[self class]] pathForImageResource:@"Plugin"]
	  ] autorelease];
}

- (bool) active
{
	return active;
}

- (void) setActive:(bool)new
{
	active = new;
	NSLog(@"active=%@", (active?@"YES":@"NO"));
}

@end
