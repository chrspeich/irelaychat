//
//  IRCUserMode.m
//  iRelayChat
//
//  Created by Christian Speich on 07.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "IRCUserMode.h"


@implementation IRCUserMode

@synthesize hasOp, hasVoice;

- (id) initFromUserString:(NSString*)string;
{
	self = [super init];
	if (self != nil) {
		/* We only look at the first character of the string */
		unichar c = [string characterAtIndex:0];
		
		hasVoice = NO;
		hasOp = NO;
		
		if (c == '+')
			hasVoice = YES;
		
		if (c == '@')
			hasOp = YES;
	}
	return self;
}

- (id) initOp;
{
	self = [super init];
	if (self != nil) {
		hasVoice = NO;
		hasOp = YES;
	}
	return self;
}

- (id) initVoice;
{
	self = [super init];
	if (self != nil) {
		hasVoice = YES;
		hasOp = NO;
	}
	return self;
}

- (id) initOpAndVoice;
{
	self = [super init];
	if (self != nil) {
		hasVoice = YES;
		hasOp = YES;
	}
	return self;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		hasVoice = NO;
		hasOp = NO;
	}
	return self;
}

@end
