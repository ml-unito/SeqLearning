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
//  BBSequence.h
//  SeqLearningNew
//
//  Created by Roberto Esposito on 14/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBAttributeDescription.h>

@interface BBSequence : NSObject <NSCoding, NSMutableCopying> {
	NSDictionary* _attribute_descriptions;
	int _label_pos;
	int _idAttribute_pos;
	NSMutableArray* _events;
	NSMutableArray* _tmp_labels;
}

/* Initialization */

-(id) init;
-(void)dealloc;

/* Querying the sequence */

-(NSArray*) rawEventVectorForTime:(unsigned int) time;
-(id) valueOfAttributeAtTime:(unsigned int) t named:(NSString*) attributeName;
-(id) valueOfAttributeAtTime:(unsigned int) t andPosition:(unsigned int) pos;
-(id) labelAtTime:(unsigned int) t;
-(id) correctLabelAtTime:(unsigned int) t;
-(NSArray*) labels;
-(BBAttributeDescription*) labelDescription;
-(unsigned int) length;
-(NSDictionary*) attributeDescriptions;
-(unsigned int) labelAttributePosition;
-(unsigned int) idAttributePosition;
-(NSString*) valueOfIdAttribute;

/* Sequence manipulation */

-(void) addEvent:(NSArray*) event;
-(void) setLabel:(NSObject*) label forTime:(int) time;
-(void) setLabels:(NSMutableArray*) labels;

/* Restore the initial values for labels */
-(void) clearLabels;
-(void) clearLabelAtTime:(unsigned int) t;

/* Additional info */
-(void) setAttributeDescriptions:(NSDictionary*) descriptions;
-(void) setLabelAttributeName:(NSString*) labelAttributeName;
-(void) setLabelAttributePosition:(int) labelPos;
-(void) setIdAttributePosition:(int) idAttrPos;

	// NSCoding
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)encoder;

    // NSCopying
-(id) mutableCopyWithZone:(NSZone *)zone;

@end
