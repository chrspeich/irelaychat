//
//  RegexKitDebug.m
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "RegexKitDebug.h"
#import <RegexKit/RegexKit.h>

@implementation RegexKitDebug

- (id) init
{
	self = [super init];
	if (self != nil) {
		prefsView = nil;
	}
	return self;
}


+ (NSArray*) preferencePanes
{
	return nil;
}

- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefsView) {
        loaded = [NSBundle loadNibNamed:@"RegexKitDebug" owner:self];
    }
    
    if (loaded) {
        return prefsView;
    }
    
    return nil;
}


- (NSString *)paneName
{
    return @"RegexKit";
}


- (NSImage *)paneIcon
{
    return nil;
}


- (NSString *)paneToolTip
{
    return @"RegexKit";
}


- (BOOL)allowsHorizontalResizing
{
    return NO;
}


- (BOOL)allowsVerticalResizing
{
    return NO;
}

- (void) update
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *cacheStatusString = [[RKRegex regexCache] status];
	
	NSArray *components = [cacheStatusString componentsSeparatedByString:@","];
	
	[cacheEnabled setStringValue:[[[components objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:2]];
	[cacheCount setStringValue:[[[components objectAtIndex:3] componentsSeparatedByString:@" "] lastObject]];
	[cacheHitRate setStringValue:[[[components objectAtIndex:4] componentsSeparatedByString:@" "] lastObject]];
	[cacheHits setStringValue:[[[components objectAtIndex:5] componentsSeparatedByString:@" "] lastObject]];
	[cacheMisses setStringValue:[[[components objectAtIndex:6] componentsSeparatedByString:@" "] lastObject]];
	[cacheTotal setStringValue:[[[components objectAtIndex:7] componentsSeparatedByString:@" "] lastObject]];
	[regexVersion setStringValue:[RKRegex PCREVersionString]];
	
	[pool release];
}

@end
