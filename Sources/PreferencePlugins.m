//
//  PreferencePlugins.m
//  iRelayChat
//
//  Created by Christian Speich on 21.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PreferencePlugins.h"
#import "InternetRelayChat.h"

@implementation PreferencePlugins

- (id) init
{
	self = [super init];
	if (self != nil) {
		prefsView = nil;
		plugins = [[InternetRelayChat sharedInternetRelayChat] plugins];
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
        loaded = [NSBundle loadNibNamed:@"PreferencePlugins" owner:self];
    }
    
    if (loaded) {
        return prefsView;
    }
    
    return nil;
}


- (NSString *)paneName
{
    return @"Plugins";
}


- (NSImage *)paneIcon
{
    return [[[NSImage alloc] initWithContentsOfFile:
			 [[NSBundle bundleForClass:[self class]] pathForImageResource:@"Plugin"]
			 ] autorelease];
}


- (NSString *)paneToolTip
{
    return @"Plugins Preferences";
}


- (BOOL)allowsHorizontalResizing
{
    return NO;
}


- (BOOL)allowsVerticalResizing
{
    return NO;
}

@end
