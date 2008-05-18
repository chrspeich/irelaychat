//
//  IRCObserveContainer.m
//  iRelayChat
//
//  Created by Christian Speich on 18.04.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCObserveContainer.h"


@implementation IRCObserveContainer

- (id) init
{
	self = [super init];
	if (self != nil) {
		observer = nil;
		message = nil;
		pattern = nil;
	}
	return self;
}


@synthesize selector,observer,message, pattern;

@end
