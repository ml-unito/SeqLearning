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
//  BBFeature.m
//  SeqLearningNew
//
//  Created by Roberto Esposito on 19/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBFeature.h>
#import <SeqLearning/BBExceptions.h>


@implementation BBFeature

-(id)init {
	if( self=[super init] ) {
		_parameters=nil;
	}
	
	return self;
}

-(void)dealloc {
	if(_parameters!=nil)
		[_parameters release];
	[super dealloc];
}

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	@throw [NSException exceptionWithName:BBGenericError 
								   reason:@"Not implemented" 
								 userInfo:nil];
}

-(void) setParameters:(NSDictionary*) parameters {
	[_parameters autorelease];
	_parameters = [parameters retain];
}

-(NSDictionary*) parameters {
	return _parameters;
}


-(NSString*) description {
	return [NSString stringWithFormat:
		  @"BBFeature {type:%@ parameters:%@}", [self class], _parameters];
	
	
}

-(void) setParametersFromString:(NSString*) parametersDescription {
	NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
	
	
	NSArray* parametersArray = [parametersDescription componentsSeparatedByString:@","];
	NSEnumerator* paramEnumerator = [parametersArray objectEnumerator];
	NSString* singleParamDescription;
	while( singleParamDescription = [paramEnumerator nextObject] ) {
		NSArray* keyValuePair = [singleParamDescription componentsSeparatedByString:@"="];
		if( [keyValuePair count]!=2 ) {
			@throw [NSException exceptionWithName:BBGenericError
										   reason:@"Parameters Description string badly formatted" 
										 userInfo:nil];
		}
		
		[parameters setObject:[keyValuePair objectAtIndex:1]
					   forKey:[keyValuePair objectAtIndex:2]];
	}
	
	[self setParameters:parameters];	
}
-(NSString*) parametersAsString {
	if( _parameters==nil )
		return nil;
	
	NSMutableString* parametersDescription = [NSMutableString stringWithCapacity:10];
	NSEnumerator* keyEnumerator = [_parameters keyEnumerator];
	NSString* key;
	BOOL first=TRUE;
	while(key=[keyEnumerator nextObject]) {
		if(first) {
			first=FALSE;
		} else {
			[parametersDescription appendString:@","];
		}
		
		[parametersDescription appendString:
			[NSString stringWithFormat:@"%@=%@", key, [_parameters objectForKey:key]]];
	}

	return parametersDescription;
}

// NSCoding
- (id)initWithCoder:(NSCoder *)coder {
	if( self = [super init] ) {
		_parameters = [[coder decodeObjectForKey:@"parameters"] retain];
	}
	
	return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
		[encoder encodeObject:_parameters forKey:@"parameters"];	
}

-(unsigned int) orderOfMarkovianAssumption {
	return 1;
}

- (id)copyWithZone:(NSZone *)zone {
	return [self retain];
}

@end
