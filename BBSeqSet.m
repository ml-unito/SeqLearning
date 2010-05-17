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
//  BBSeqSet.m
//  SeqLearningNew
//
//  Created by Roberto Esposito on 14/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBSeqSet.h>
#import <SeqLearning/BBExceptions.h>

NSString* BBSeqSetDidChangeNotification=@"BBSeqSetDidChangeNotification";

@implementation BBSeqSet

-(id)init {
	if(self=[super init]) {
		_ss = [[NSMutableArray alloc] init];
		_preferredFeaturesManagerClassName = nil;
	}
	
	return self;
}

-(void)dealloc {
	[_ss release];
	[super dealloc];
}

-(BBSequence*) sequenceNumber:(unsigned int) t {
	return [_ss objectAtIndex:t];
}

-(unsigned) indexOfSequenceIdenticalTo:(BBSequence*) sequence {
	return [_ss indexOfObjectIdenticalTo:sequence];
}


-(void) removeSequenceNumber:(unsigned int) t {
	[_ss removeObjectAtIndex:t];
	[[NSNotificationCenter defaultCenter] postNotificationName:BBSeqSetDidChangeNotification
														object:self];
}

-(void) appendSequence:(BBSequence*) sequence {
	[_ss addObject:sequence];
	[[NSNotificationCenter defaultCenter] postNotificationName:BBSeqSetDidChangeNotification
														object:self];

}

-(void) appendSequencesFromSeqSet:(BBSeqSet*) seqSet {
	unsigned int count=[seqSet count];
	int n;
	for(n=0; n<count;++n) {
		[self appendSequence: [seqSet sequenceNumber:n]];
	}
}


-(void) insertSequence:(BBSequence*) sequence atIndex:(int) index {
	[_ss insertObject:sequence atIndex:index];
	[[NSNotificationCenter defaultCenter] postNotificationName:BBSeqSetDidChangeNotification
														object:self];

}

-(NSEnumerator*) sequenceEnumerator {
	return [_ss objectEnumerator];
}

-(id) valueOfAttributeAtGlobalTime:(unsigned int) t 
					   andPosition:(unsigned int) pos {
	NSEnumerator* enumerator = [self sequenceEnumerator];
	BBSequence* sequence;
	
	unsigned int cur_t=0;
	while( sequence = [enumerator nextObject] ) {
		if(cur_t+[sequence length]-1>=t) {
			return [sequence valueOfAttributeAtTime:t-cur_t andPosition:pos];  
		} else 
			cur_t += [sequence length];
	}
	
	@throw [NSException exceptionWithName:BBGenericError
								   reason:@"t value too large" 
								 userInfo:nil];
}


-(id) valueOfAttributeAtGlobalTime:(unsigned int) t 
							 named:(NSString*) attributeName {
	NSEnumerator* enumerator = [self sequenceEnumerator];
	BBSequence* sequence;

	unsigned int cur_t=0;
	while( sequence = [enumerator nextObject] ) {
		if(cur_t+[sequence length]-1>=t) {
			return [sequence valueOfAttributeAtTime:t-cur_t named:attributeName];  
		} else 
			cur_t += [sequence length];
	}
	
	@throw [NSException exceptionWithName:BBGenericError
								   reason:@"t value too large" 
								 userInfo:nil];
}

-(id) valueOfLabelAtGlobalTime:(unsigned int) t {
	BBSequence* seq = [self sequenceNumber:0];
	unsigned int labelPosition = [seq labelAttributePosition];
	return [self valueOfAttributeAtGlobalTime:t andPosition:labelPosition];
}

-(id) valueOfSequenceIdAtGlobalTime:(unsigned int) t {
	BBSequence* seq = [self sequenceNumber:0];
	unsigned int idAttributePosition= [seq idAttributePosition];
	return [self valueOfAttributeAtGlobalTime:t andPosition:idAttributePosition];	
}


-(BOOL) hasSequence:(BBSequence*) sequence {
	int i;
	int count = [self count];
	BOOL found = FALSE;
	NSString* targetSeqId = [sequence valueOfIdAttribute];
	
	for(i=0; i<count && !found; ++i) {
		if( [[[self sequenceNumber:i] valueOfIdAttribute] isEqualToString:targetSeqId] )
			found = TRUE;
	}
	
	return found;
}



-(unsigned int) count {
	return [_ss count];
}

-(NSDictionary*) attributeDescriptions {
	if(_ss==nil || [_ss count]==0) 
		@throw [NSException exceptionWithName:BBGenericError 
									   reason: @"Cannot get attribute description for an empty sequence set"
									 userInfo:nil];
	
	return [[_ss objectAtIndex:0] attributeDescriptions];
}

-(NSString*) description {
	return [NSString stringWithFormat:@"seq set {%@}", _ss];
}

-(BBAttributeDescription*) labelDescription {
	if(_ss==nil || [_ss count]==0) 
		@throw [NSException exceptionWithName:BBGenericError
									   reason:@"Cannot get attribute description for an empty sequence set"
									 userInfo:nil];
	
	return [[_ss objectAtIndex:0] labelDescription];
}

-(NSSet*) labels {
	if( _ss==nil || [_ss count] == 0 )
		@throw [NSException exceptionWithName:BBGenericError
									   reason:@"Cannot access label attribute: dataset empty or not loaded"
									 userInfo:nil];
	
	return (NSSet*) [[self labelDescription] info];
}

-(void) setPreferredFeaturesManagerClassName:(NSString*) className {
	if( _preferredFeaturesManagerClassName != nil )
		[_preferredFeaturesManagerClassName autorelease];
	
	_preferredFeaturesManagerClassName = [className retain];
}

-(NSString*) preferredFeaturesManagerClassName {
	return _preferredFeaturesManagerClassName;
}


// NSCoding
- (id)initWithCoder:(NSCoder *)coder {
	if( self = [super init] ) {
		_ss = [[coder decodeObjectForKey:@"ss"] retain];
	}
	
	return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_ss forKey:@"ss"];
}



@end
