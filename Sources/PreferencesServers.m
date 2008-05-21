//
//  PreferencesServers.m
//  iRelayChat
//
//  Created by Christian Speich on 21.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PreferencesServers.h"
#import "InternetRelayChat.h"

@implementation PreferencesServers

- (id) init
{
	self = [super init];
	if (self != nil) {
		prefsView = nil;
		serversArray = [[InternetRelayChat sharedInternetRelayChat] servers];
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
        loaded = [NSBundle loadNibNamed:@"PreferenceServers" owner:self];
    }
    
    if (loaded) {
        return prefsView;
    }
    
    return nil;
}


- (NSString *)paneName
{
    return @"Servers";
}


- (NSImage *)paneIcon
{
    return [NSImage imageNamed:@"NSNetwork"];
}


- (NSString *)paneToolTip
{
    return @"Servers Preferences";
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
