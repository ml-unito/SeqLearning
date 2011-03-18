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
//  BBAttributeDescription.m
//  SeqLearningNew
//
//  Created by Roberto Esposito on 19/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBAttributeDescription.h>
#import <SeqLearning/BBNumberReader.h>
#import <SeqLearning/BBStringReader.h>
#import <SeqLearning/BBNominalValueReader.h>
#import <SeqLearning/BBExceptions.h>


BBAttributeType	BBAttributeTypeNumber = @"Numeric";
BBAttributeType	BBAttributeTypeString = @"String";
BBAttributeType	BBAttributeTypeNominal= @"Nominal";



@implementation BBAttributeDescription

+(BBAttributeDescription*) descriptionWithType:(BBAttributeType) type 
									  position:(unsigned int) pos
									   andInfo:(NSObject*) info {
	return [[[BBAttributeDescription alloc] initWithType:type position:pos andInfo:info] autorelease];
}

-(id)initWithType:(BBAttributeType) type 
		 position:(unsigned int) pos
		  andInfo:(NSObject*) info {
	if( (self=[super init]) ) {
		_type = type;
		_position = pos;
		if( info!=nil )
			_info = [info retain];
		else
			_info = nil;
	}
	
	return self;
}

-(void)dealloc {
	if(_info!=nil)
		[_info release];
	[super dealloc];
}


-(NSObject<BBRawAttributeReading>*) reader {
	if( _type == BBAttributeTypeNumber )
			return [BBNumberReader reader];
	
	if( _type == BBAttributeTypeNominal ) {
		NSAssert( [_info isKindOfClass:[NSSet class]],
				  @"Wrong info type given for nominal value" );
		return [BBNominalValueReader readerWithKeys:(NSSet*)_info];		
	}
	
	if( _type == BBAttributeTypeString ) {
			return [BBStringReader reader];		
	}

	@throw [NSException exceptionWithName:BBGenericError
								   reason:@"Unknown attribute type" 
								 userInfo:nil];
}


// NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeInt:_position forKey:@"position"];
	[encoder encodeObject:_type forKey:@"type"];
	[encoder encodeObject:_info forKey:@"info"];
}

- (id)initWithCoder:(NSCoder *)coder {
	
    if((self = [super init])) {
		_position = [coder decodeIntForKey:@"position"];
		_type = [[coder decodeObjectForKey:@"type"] retain];
		_info = [[coder decodeObjectForKey:@"info"] retain];	
	}
	
    return self;
}

-(NSString*) description {
	return [NSString stringWithFormat:@"att des { pos:%d type:%@ info:%@ }", _position, _type, _info];
}


-(void) setPosition:(unsigned int) position {
	_position = position;
}

-(unsigned int) position {
	return _position;
}

-(void) setType:(BBAttributeType) type {
	[_type autorelease];
	_type = [type retain];
}

-(BBAttributeType) type {
	return _type;
}

-(void) setInfo:(NSObject*) info {
	[_info autorelease];
	_info = [info retain];
}

-(NSObject*) info {
	return _info;
}

-(BOOL) isEqual:(NSObject*) received_object {
	if( ![received_object isMemberOfClass:[self class]] )
		return NO;
	
	BBAttributeDescription* object = (BBAttributeDescription*)received_object;
	
	return _position == [object position] 
		&& [_info isEqual:[object info]]
		&& [_type isEqual:[object type]];
}

@end
