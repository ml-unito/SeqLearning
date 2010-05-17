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
//  BBSequenceReader.m
//  SeqLearningNew
//
//  Created by Roberto Esposito on 14/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBSequenceReader.h"
#import "BBExceptions.h"
#import "BBSeqSet.h"
#import "BBAttributeDescription.h"


@implementation BBSequenceReader

-(id) init {
	if( self = [super init] ) {
		BBFieldsDelimiterString = @" ";
		BBLinesDelimiterString = @"\n";
		BBCommentMarkerString = @"#";
				
		_attribute_descriptions = nil;
		_readers = nil;
		_sequence_id_pos = -1;
	}
	
	return self;
}

-(void) setSequenceIdPosition:(int) pos {
	_sequence_id_pos = pos;
}

-(void) setSequenceIdName:(NSString*) seqId_attribute_name {
	NSAssert( _attribute_descriptions!=nil, 
			  @"Cannot set label attribute name if names vector is empty" );
	
	BBAttributeDescription* description = 
		[_attribute_descriptions objectForKey:seqId_attribute_name];
	
	if( description == nil ) {
		NSString* errMsg = 
		[NSString stringWithFormat:@"Cannot find name:%@ in vector %@",
			seqId_attribute_name,
			_attribute_descriptions];
		
		@throw [NSException exceptionWithName:BBGenericError
									   reason:errMsg
									 userInfo:nil];		
	}
	
	[self setSequenceIdPosition:[description position]];
}


-(void) dealloc {
	if( _readers!=nil )
		[_readers release];
	[super dealloc];
}

-(NSArray*) attributeReaders {
	NSAssert( _attribute_descriptions!=nil,
			  @"Cannot build readers without attribute descriptions" );
	NSMutableArray* readers = [NSMutableArray arrayWithCapacity:[_attribute_descriptions count]];
	int i;
	for(i=0; i<[_attribute_descriptions count]; ++i) {
		[readers addObject:[NSNull null]];
	}

	NSEnumerator* it = [_attribute_descriptions objectEnumerator];
	BBAttributeDescription* current;
	while( current=[it nextObject] ) {
		[readers replaceObjectAtIndex:[current position] 
						   withObject:[current reader]];
	}
	
	return readers;
}




-(BBSequence*) readSequenceUsingScanner:(NSScanner*) scanner {
	BBSequence* sequence = [[BBSequence alloc] init];
	NSObject* sequence_id = nil;
	if( _readers == nil ) {
		_readers = [[self attributeReaders] retain];
	}
	
	@try {
		NSString* line;
		BOOL done = NO;
		while( [scanner isAtEnd] == NO && !done) {
			// backing up scan_location (we wanto to roll back to this position
			// in case the present record is not part of the current sequence.
			unsigned int scan_location = [scanner scanLocation];
			
			// reading current line
			[scanner scanUpToString:BBLinesDelimiterString intoString:&line];
			
			if( [line isEqualToString:@""] || [line hasPrefix:BBCommentMarkerString] )
				continue;

			NSArray* fields = [line componentsSeparatedByString:BBFieldsDelimiterString];
			if( [fields count] < [_readers count] ) {
				NSString* errMsg = [NSString stringWithFormat:
				@"Number of fields in input string ``%@'' smaller than the expected number of attributes:%d",
					line, [_readers count]];
				@throw [NSException exceptionWithName:BBSequenceReadingException
											   reason:errMsg 
											 userInfo:nil];
			}
		
			int i;
			NSMutableArray* decodedFields = [[NSMutableArray alloc] init];
			for(i=0; i<[_readers count]; ++i) {
				id attribute = [[_readers objectAtIndex:i] 
					readAttributeFromString:[fields objectAtIndex:i]];
				
				// saving sequence_id if this is we need to check for it 
				// (i.e., if sequence_id_pos!=-1) and we did not saved it yet
				if(sequence_id==nil && _sequence_id_pos!=-1 && i==_sequence_id_pos) {
					sequence_id = [attribute retain];
				}
				
				[decodedFields addObject: attribute];
			}
			
			if( _sequence_id_pos==-1 || 
				(sequence_id!=nil && [sequence_id isEqualTo:[decodedFields objectAtIndex:_sequence_id_pos]]) ) {
				[sequence addEvent:decodedFields];				
			} else {
				done=YES;
				// last attributes read are not part of the current sequence
				// rolling the scanner back so that the line can be used
				// by the main program
				[scanner setScanLocation:scan_location];
			}
				
			[decodedFields release];			
		}
	} @catch (id exception) {
		[sequence release];
		@throw;
	} @finally {
		if( sequence_id!=nil )
			[sequence_id release];		
	}
	
	return [sequence autorelease];
}

-(BBSequence*) readSequenceFromString:(NSString*) string {
	NSScanner* scanner = [NSScanner scannerWithString:string];
	BBSequence* sequence = [self readSequenceUsingScanner:scanner];
	[sequence setAttributeDescriptions:_attribute_descriptions];
	[sequence setLabelAttributePosition:_label_attribute_pos];
	[sequence setIdAttributePosition:_sequence_id_pos];
	return sequence;
}

-(BBSeqSet*) readSeqSetFromString:(NSString*) string {
	BBSeqSet* ss = [[BBSeqSet alloc] init];
	NSScanner* scanner = [NSScanner scannerWithString:string];
	_readers = [[self attributeReaders] retain];
	
	@try {
		while( [scanner isAtEnd]==NO ) {
			BBSequence* sequence = [self readSequenceUsingScanner:scanner];
			[sequence setAttributeDescriptions:_attribute_descriptions];
			[sequence setLabelAttributePosition:_label_attribute_pos];
			[sequence setIdAttributePosition:_sequence_id_pos];
			[ss appendSequence:sequence];					
		}
	} @catch (id exception) {
		[ss release];
		@throw;
	}
	
	return [ss autorelease];
}

-(void) setAttributeDescriptions:(NSDictionary*) descriptions {
	[_attribute_descriptions autorelease];
	_attribute_descriptions = [descriptions retain];
	if(_readers!=nil) {
		[_readers release];
		_readers=nil;
	}
}

-(void) setLabelAttributePosition:(int) label_attribute_pos {
	_label_attribute_pos = label_attribute_pos;
}

-(void) setLabelAttributeName:(NSString*) label_attribute_name {
	NSAssert( _attribute_descriptions!=nil, 
			  @"Cannot set label attribute name if names vector is empty" );
	
	BBAttributeDescription* description = 
		[_attribute_descriptions objectForKey:label_attribute_name];
	
	if( description == nil ) {
		NSString* errMsg = 
			[NSString stringWithFormat:@"Cannot find name:%@ in vector %@",
				label_attribute_name,
				_attribute_descriptions];
		
		@throw [NSException exceptionWithName:BBGenericError
									   reason:errMsg
									 userInfo:nil];		
	}
	
	[self setLabelAttributePosition:[description position]];
}

@end
