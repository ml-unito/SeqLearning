/**********************************************************************
This source file belongs to the seqlearning library: a sequence learning objective-c library.
Copyright (C) 2008  Roberto Esposito

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***********************************************************************/
//
//  BBStringReader.m
//  SeqLearningNew
//
//  Created by Roberto Esposito on 18/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBStringReader.h>


@implementation BBStringReader

+(BBStringReader*) reader {
	return [[[BBStringReader alloc] init] autorelease];
}

-(id) readAttributeFromString:(NSString*) string {
	NSString* trimmedString=[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if([trimmedString characterAtIndex:0]=='"' &&
	   [trimmedString characterAtIndex:[trimmedString length]-1]=='"')
		return [trimmedString substringWithRange:NSMakeRange(1,[trimmedString length]-2)];
	else
		return trimmedString;
}

@end
