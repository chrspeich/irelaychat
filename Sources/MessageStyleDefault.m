//
//  MessageStyleDefault.m
//  iRelayChat
//
//  Created by Christian Speich on 25.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MessageStyleDefault.h"
#import "IRCUser.h"
#import "IRCChannel.h"

@implementation MessageStyleDefault

+ (NSString*) template
{
	return [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"MessageTemplate" ofType:@"html"]];
}

+ (NSString*) htmlForChannelMessage:(IRCChannelMessage*)message
{
	NSMutableString *html = [[NSMutableString alloc] init];
	
	[html appendString:@"<tr>"];
	
	switch (message.type) {
		case IRCChannelMessageText:
			if (message.action && message.from.isMe) {
				[html appendFormat:@"<td class=\"my_action\" colspan=\"2\">%@ %@</td>", message.from.nickname, [message htmlUseableMessage]];
			} else if (message.from.isMe) {
				[html appendFormat:@"<td class=\"user_self\"><b>%@:</b></td><td class=\"message_self\">%@</td>", message.from.nickname, [message htmlUseableMessage]];
			}
			else if (message.action) {
				[html appendFormat:@"<td class=\"user_action\" colspan=\"2\" style=\"background-color:rgba(%i,%i,%i,0.3)\">%@ %@</td>", (int)([message.from.color redComponent]*255.f), (int)([message.from.color greenComponent]*255.f), (int)([message.from.color blueComponent]*255.f), message.from.nickname, [message htmlUseableMessage]];
			}
			else if (message.highlight) {
				[html appendFormat:@"<td class=\"user\" style=\"background-color:rgba(%i,%i,%i,0.3);\"><b>%@:</b></td><td class=\"message_high\">%@</td>", (int)([message.from.color redComponent]*255.f), (int)([message.from.color greenComponent]*255.f), (int)([message.from.color blueComponent]*255.f), message.from.nickname, [message htmlUseableMessage]];
			}
			else {
				[html appendFormat:@"<td class=\"user\" style=\"background-color:rgba(%i,%i,%i,0.3);\"><b>%@:</b></td><td class=\"message\">%@</td>", (int)([message.from.color redComponent]*255.f), (int)([message.from.color greenComponent]*255.f), (int)([message.from.color blueComponent]*255.f), message.from.nickname, [message htmlUseableMessage]];
			}
			break;
		case IRCChannelMessageJoin:
			[html appendFormat:@"<td class=\"action\" colspan=\"2\"><b>%@ hat %@ betreten.</b></td>", message.from.nickname, message.channel.name];
			break;
		case IRCChannelMessagePart:
			[html appendFormat:@"<td class=\"action\" colspan=\"2\"><b>%@ hat %@ verlassen.</b></td>", message.from.nickname, message.channel.name];
			break;
		case IRCChannelMessageQuit:
			[html appendFormat:@"<td class=\"action\" colspan=\"2\"><b>%@ hat die Verbindung getrennt.</b></td>", message.from.nickname];
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
