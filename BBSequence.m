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
//  BBSequence.m
//  SeqLearningNew
//
//  Created by Roberto Esposito on 14/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBSequence.h>
#import <SeqLearning/BBExceptions.h>
#import <SeqLearning/BBAttributeDescription.h>

@implementation BBSequence

-(id) init {
	if(self=[super init]) {
		_events = [[NSMutableArray alloc] init];
		_attribute_descriptions = nil;
		_label_pos = -1;
		_tmp_labels = nil;
	}
	
	return self;
}

-(void)dealloc {
	[_attribute_descriptions release];
	[self clearLabels];
	[_events release];
	[super dealloc];
}

-(NSArray*) rawEventVectorForTime:(unsigned int) time {
	return [_events objectAtIndex:time];
}

-(void) addEvent:(NSArray*) event {
	[_events addObject:event];
}

-(void) setLabel:(NSObject*) label forTime:(int) time {
	if(_tmp_labels==nil) {
		int len = [self length];
		[self setLabels:[NSMutableArray arrayWithCapacity:len]];
		
		int i;
		for(i=0; i<len; ++i) {
			[_tmp_labels addObject:[NSNull null]];
		}
	}
	
	[_tmp_labels replaceObjectAtIndex:time withObject:label];
}

-(void) setLabels:(NSMutableArray*) labels {
	[_tmp_labels autorelease];
	_tmp_labels = [labels retain];
}

-(void) clearLabels {
	if(_tmp_labels!=nil) {
		[_tmp_labels release];
		_tmp_labels=nil;
	}
}

-(void) clearLabelAtTime:(unsigned int) t {
	if(_tmp_labels!=nil) {
		[_tmp_labels replaceObjectAtIndex:t withObject:[NSNull null]];
	}
}

-(void) setAttributeDescriptions:(NSDictionary*) descriptions {
	[_attribute_descriptions autorelease];
	_attribute_descriptions = [descriptions retain];
}

-(void) setLabelAttributeName:(NSString*) name {
	NSAssert( _attribute_descriptions!=nil, 
			  @"setLabelAttrName called, but no list of attribute descriptions has been setted!" );
	BBAttributeDescription* description = [_attribute_descriptions objectForKey:name];
	if( description==nil ) {
		NSString* errMsg = 
			[NSString stringWithFormat:@"Cannot find label %@ in dictionary %@",
				name, _attribute_descriptions];
		@throw [NSException exceptionWithName:BBGenericError
									   reason:errMsg 
									 userInfo:nil];		
	}
	
	[self setLabelAttributePosition:[description position]];
}

-(void) setLabelAttributePosition:(int) pos {
	_label_pos=pos;
}

-(void) setIdAttributePosition:(int) idAttrPos {
	_idAttribute_pos = idAttrPos;
}

-(id) valueOfAttributeAtTime:(unsigned int) t named:(NSString*) attributeName {
	BBAttributeDescription* description=[_attribute_descriptions objectForKey:attributeName];
	if( description==nil ) {
		NSString* errMsg = 
		[NSString stringWithFormat:@"Cannot find label %@ in dictionary %@",
			attributeName, _attribute_descriptions];
		@throw [NSException exceptionWithName:BBGenericError
									   reason:errMsg 
									 userInfo:nil];		
	}
	
	return [[self rawEventVectorForTime:t] objectAtIndex:[description position]];
}

-(id) valueOfAttributeAtTime:(unsigned int) t andPosition:(unsigned int) pos{
	return [[self rawEventVectorForTime:t] objectAtIndex:pos];
}

-(id) labelAtTime:(unsigned int) t {
	if( _tmp_labels == nil || [_tmp_labels objectAtIndex:t]==[NSNull null] )
		return [[self rawEventVectorForTime:t] objectAtIndex:_label_pos];
	else
		return [_tmp_labels objectAtIndex:t];
}

-(id) correctLabelAtTime:(unsigned int) t {
	return [[self rawEventVectorForTime:t] objectAtIndex:_label_pos];
}

-(BBAttributeDescription*) labelDescription {
	NSEnumerator* enumerator = [_attribute_descriptions objectEnumerator];
	BBAttributeDescription* current;
	while( (current=[enumerator nextObject]) && [current position]!=_label_pos)
		; // do nothing
	NSAssert( current!=nil, @"Cannot find label description" );
	return current;
}

-(NSDictionary*) attributeDescriptions {
	return _attribute_descriptions;
}

-(NSArray*) labels {
	int len=[self length];
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:len];
	int i;
	for(i=0; i<len; ++i) {
		[result addObject:[self labelAtTime:i]];
	}
	
	return result;
}

-(unsigned int) length {
	return [_events count];
}

-(unsigned int) labelAttributePosition {
	return _label_pos;
}
-(unsigned int) idAttributePosition {
	return _idAttribute_pos;
}

-(NSString*) valueOfIdAttribute {
	return [self valueOfAttributeAtTime:0 andPosition:_idAttribute_pos];
}

// NSCoding
- (id)initWithCoder:(NSCoder *)coder {
	if( self = [super init] ) {
		_attribute_descriptions = [[coder decodeObjectForKey:@"attribute_descriptions"] retain];
		_label_pos = [coder decodeIntForKey:@"label_pos"];
		_idAttribute_pos = [coder decodeIntForKey:@"idAttribute_pos"];
		_events = [[coder decodeObjectForKey:@"events"] retain];
		_tmp_labels = [[coder decodeObjectForKey:@"tmp_labels"] retain];
	}
	
	return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_attribute_descriptions forKey:@"attribute_descriptions"];
	[encoder encodeInt:_label_pos forKey:@"label_pos"];
	[encoder encodeInt:_idAttribute_pos  forKey:@"idAttribute_pos"];
	[encoder encodeObject:_events forKey:@"events"];
	[encoder encodeObject:_tmp_labels forKey:@"tmp_labels"];
}



@end
