/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * iRelayChat - A better IRC Client for Mac OS X                             *
 * - Frontend Class -                                                        *
 *                                                                           *
 * Copyright 2008 by Christian Speich <kontakt@kleinweby.de>                 *
 *                                                                           *
 * Licenced under GPL v3 or later. See 'Copying' for details.                *
 *                                                                           *
 * - Description - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - *
 *                                                                           *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "MessageStyleDefault.h"
#import "IRCUser.h"
#import "IRCChannel.h"

@implementation MessageStyleDefault

+ (NSString*) template
{
	return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MessageTemplate" ofType:@"html"]];
}

+ (NSString*) htmlForChannelMessage:(IRCConversationMessage*)message
{
	NSMutableString *html = [[NSMutableString alloc] init];
	
	[html appendString:@"<tr>"];
	
	NSLog(@"html begins");
	
	switch (message.type) {
		case IRCConversationMessageText:
			if (message.action && message.user.isMe) {
				[html appendFormat:@"<td class=\"my_action\" colspan=\"2\">%@ %@</td>", message.user.nickname, [message htmlString]];
			} else if (message.user.isMe) {
				[html appendFormat:@"<td class=\"user_self\"><b>%@:</b></td><td class=\"message_self\">%@</td>", message.user.nickname, [message htmlString]];
			}
			else if (message.action) {
				[html appendFormat:@"<td class=\"user_action\" colspan=\"2\" style=\"background-color:rgba(%i,%i,%i,0.3)\">%@ %@</td>", (int)([message.user.color redComponent]*255.f), (int)([message.user.color greenComponent]*255.f), (int)([message.user.color blueComponent]*255.f), message.user.nickname, [message htmlString]];
			}
			else if (message.highlight) {
				[html appendFormat:@"<td class=\"user\" style=\"background-color:rgba(%i,%i,%i,0.3);\"><b>%@:</b></td><td class=\"message_high\">%@</td>", (int)([message.user.color redComponent]*255.f), (int)([message.user.color greenComponent]*255.f), (int)([message.user.color blueComponent]*255.f), message.user.nickname, [message htmlString]];
			}
			else {
				[html appendFormat:@"<td class=\"user\" style=\"background-color:rgba(%i,%i,%i,0.3);\"><b>%@:</b></td><td class=\"message\">%@</td>", (int)([message.user.color redComponent]*255.f), (int)([message.user.color greenComponent]*255.f), (int)([message.user.color blueComponent]*255.f), message.user.nickname, [message htmlString]];
			}
			break;
		case IRCConversationMessageJoin:
			[html appendFormat:@"<td class=\"action\" colspan=\"2\"><b>%@ hat %@ betreten.</b></td>", message.user.nickname, message.conversation.name];
			break;
		case IRCConversationMessagePart:
			[html appendFormat:@"<td class=\"action\" colspan=\"2\"><b>%@ hat %@ verlassen.</b></td>", message.user.nickname, message.conversation.name];
			break;
		case IRCConversationMessageQuit:
			[html appendFormat:@"<td class=\"action\" colspan=\"2\"><b>%@ hat die Verbindung getrennt.</b></td>", message.user.nickname];
			break;
		default:
			[html appendString:@"Unknown Message"];
			break;
	}
	
	[html appendFormat:@"<td class=\"time\">%@</td></tr><tr height=\"4px\"></tr>", [message.date descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil
																					locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]]];
		
	return [html autorelease];
}

@end
