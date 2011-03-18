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
//  BBNominalValueReader.m
//  SeqLearningNew
//
//  Created by Roberto Esposito on 14/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBNominalValueReader.h>
#import <SeqLearning/BBExceptions.h>


@implementation BBNominalValueReader

+(BBNominalValueReader*) readerWithKeys:(NSSet*) keys {
	return [[[BBNominalValueReader alloc] initWithKeys:keys] autorelease];
}

-(id) initWithKeys:(NSSet*) keys {
	if( (self = [super init]) ) {
		_keys = [keys retain];
	}
	
	return self;
}

-(void) dealloc {
	[_keys release];
	[super dealloc];
}

-(id) readAttributeFromString:(NSString*) origString {
	NSString* string = [origString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if( [_keys containsObject: string] )
		return string;
	else {
		NSString* errMsg = 
			[NSString stringWithFormat:@"Expecting a nominal value in the set:%@ but ``%@'' found",
				_keys, string];
			
		@throw [NSException exceptionWithName:BBAttributeReadingException 
									   reason:errMsg 
									 userInfo:nil];		

	}
}

@end
