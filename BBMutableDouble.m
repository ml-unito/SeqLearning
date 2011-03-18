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
//  BBMutableDouble.m
//  SeqLearning
//
//  Created by Roberto Esposito on 16/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBMutableDouble.h"


@implementation BBMutableDouble

+(BBMutableDouble*) numberWithDouble:(double) value {
	return [[[BBMutableDouble alloc] initWithDouble:value] autorelease];
}

-(id) initWithDouble:(double) value {
	if((self=[super init])) {
		_value=value;		
	}

	return self;
}

-(void) setDouble:(double) value {
	_value=value;
}

-(double) doubleValue {
	return _value;
}

-(NSString*) description {
	return [NSString stringWithFormat:@"%f", _value];
}

- (id)copyWithZone:(NSZone *)zone {
	return [[BBMutableDouble alloc] initWithDouble:_value];
}


- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeDouble:_value forKey:@"value"];
}

- (id)initWithCoder:(NSCoder *)coder {
	
    if((self = [super init])) {
		[self setDouble:[coder decodeDoubleForKey:@"value"]];
	}
	
    return self;
}


@end
