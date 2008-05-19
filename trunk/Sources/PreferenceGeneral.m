//
//  PreferenceGeneral.m
//  iRelayChat
//
//  Created by Christian Speich on 19.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PreferenceGeneral.h"


@implementation PreferenceGeneral

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
        loaded = [NSBundle loadNibNamed:@"PreferenceGeneral" owner:self];
    }
    
    if (loaded) {
        return prefsView;
    }
    
    return nil;
}


- (NSString *)paneName
{
    return @"General";
}


- (NSImage *)paneIcon
{
    return [NSImage imageNamed:@"NSPreferencesGeneral"];
}


- (NSString *)paneToolTip
{
    return @"General Preferences";
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
