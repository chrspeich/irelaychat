/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * IRCRawMessage                                                           *
 *                                                                         *
 * iRelayChat - 2008 Copyright by Christian Speich <kontakt@kleinweby.de>  *
 *                                                                         *
 * Description:                                                            *
 * IRCRawMessages repesents a IRC-Message as specific in RFC 2812. It      * 
 * handles the Charset Converting, the parsing out of user, command and    *
 * arguments.                                                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Cocoa/Cocoa.h>


@interface IRCRawMessage : NSObject {
	NSStringEncoding	encoding;
	char				*rawCString;
	NSString			*rawString;
	
	NSString			*user;
	NSString			*command;
	NSArray				*args;
}

// Use a recived message to initalinze this.
// It will plitt it into user, command and arguments
- (id) initWithCString:(char*)cstring usingEncoding:(NSStringEncoding) encoding;

// Set this for use a specific encoding.
// IRCRawMessage will change/convert all content to the encoding...
@property NSStringEncoding	encoding;

@property(retain) NSString	*user;
@property(retain) NSString	*command;
@property(retain) NSArray	*args;
@property(readonly)	char	*rawCString;

@end
