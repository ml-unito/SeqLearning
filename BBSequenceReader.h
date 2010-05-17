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
//  BBSequenceReader.h
//  SeqLearningNew
//
//  Created by Roberto Esposito on 14/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBRawAttributeReading.h>
#import <SeqLearning/BBSequence.h>
#import <SeqLearning/BBSeqSet.h>

@class BBSeqSet;

@interface BBSequenceReader : NSObject {
	NSString* BBFieldsDelimiterString;
	NSString* BBLinesDelimiterString;
	NSString* BBCommentMarkerString;
	
	
	NSDictionary* _attribute_descriptions;
	NSMutableArray* _readers;
	int _sequence_id_pos;
	int _label_attribute_pos;
}

-(id) init;
-(void) setSequenceIdPosition:(int) pos;
-(void) setSequenceIdName:(NSString*) name;


/* The reader will pass the information to newly built sequences */
-(void) setAttributeDescriptions:(NSDictionary*) descriptions;


/* The reader will pass the information to newly built sequences */
-(void) setLabelAttributePosition:(int) label_attribute_pos;
-(void) setLabelAttributeName:(NSString*) label_attribute_name;


-(BBSeqSet*) readSeqSetFromString:(NSString*) string;
-(BBSequence*) readSequenceFromString:(NSString*) string;


@end
