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
//  BBSeqSet.h
//  SeqLearningNew
//
//  Created by Roberto Esposito on 14/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBSequence.h>

extern NSString* BBSeqSetDidChangeNotification;

@interface BBSeqSet : NSObject <NSCoding> {
	NSMutableArray* _ss;
	NSString* _preferredFeaturesManagerClassName;
}

-(id)init;
-(void) dealloc;
-(BBSequence*) sequenceNumber:(unsigned int) t;
-(unsigned) indexOfSequenceIdenticalTo:(BBSequence*) sequence;

-(NSEnumerator*) sequenceEnumerator;
-(void) appendSequence:(BBSequence*) sequence;
-(void) appendSequencesFromSeqSet:(BBSeqSet*) seqSet;
-(void) insertSequence:(BBSequence*) sequence atIndex:(int) index;

-(void) removeSequenceNumber:(unsigned int) t;

-(unsigned int) count;
-(NSString*) description;

/**
 * @return the description of the attributed currently marked as the 'label' attribute.
 */
-(BBAttributeDescription*) labelDescription;

/**
 * @returns the set of values that can be taken by the attribute currently marked as
 * the 'label' attribute. It throws a BBException if the dataset has not already be
 * loaded or if the label attribute is not of type BBNominalAttribute.
 */
-(NSSet*) labels;

/** 
 * The following method returns the value of attribute named "attributeName"
 * at global time t. "Global time" means the time the event would have been
 * found if the set of sequences were flattened into a single long sequence.
 */
-(id) valueOfAttributeAtGlobalTime:(unsigned int) t named:(NSString*) attributeName;
-(id) valueOfAttributeAtGlobalTime:(unsigned int) t andPosition:(unsigned int) pos;
-(id) valueOfLabelAtGlobalTime:(unsigned int) t;
-(id) valueOfSequenceIdAtGlobalTime:(unsigned int) t;


/**
 * Returns TRUE if the given sequence belongs to the seqset, FALSE otherwise
 */
-(BOOL) hasSequence:(BBSequence*) sequence;

/**
 * Returns the description of the attributes of sequences in this SeqSet.
 * The returned object is an NSDictionary having attributes names as keys and
 * BBAttributeDescription objects as values.
 */ 

-(NSDictionary*) attributeDescriptions;

/**
 * Sets the preferred features manager class name. This is an hint about which
 * is the correct attribute manager to be used with this SeqSet. Is can be used
 * by other pieces of software in order to select the appropriate features manager
 * without user intervention.
 */
-(void) setPreferredFeaturesManagerClassName:(NSString*) className;

/**
 * Returns the preferred features manager class name. See setPreferredFeaturesManagerClassName
 * for more information about what the preferredFeaturesManagerClassName is.
 */

-(NSString*) preferredFeaturesManagerClassName;

// NSCoding
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)encoder;


@end
