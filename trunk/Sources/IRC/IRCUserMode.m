/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * iRelayChat - A better IRC Client for Mac OS X                             *
 * - Backend Class -                                                         *
 *                                                                           *
 * Copyright 2008 by Christian Speich <kontakt@kleinweby.de>                 *
 *                                                                           *
 * Licenced under GPL v3 or later. See 'Copying' for details.                *
 *                                                                           *
 * - Description - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
 *                                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
