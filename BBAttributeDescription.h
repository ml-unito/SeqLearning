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
//  BBAttributeDescription.h
//  SeqLearningNew
//
//  Created by Roberto Esposito on 19/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBRawAttributeReading.h>


typedef NSString* BBAttributeType;

extern BBAttributeType	BBAttributeTypeNumber;
extern BBAttributeType	BBAttributeTypeString;
extern BBAttributeType	BBAttributeTypeNominal;


/**
 * Describe an attribute type. Supported attributes are of type:
 * - BBAttributeTypeString: any string allowed
 * - BBAttributeTypeNumber: any number allowed
 * - BBAttributeTypeNominal: only a limited number of values are allowed.
 *
 * In case the attribute is of type 'nominal', allowed values can be found using
 * the -info method.
 */

@interface BBAttributeDescription : NSObject  <NSCoding> {
	unsigned int _position;
	BBAttributeType _type;
	NSObject* _info;
}

/**
 * Create a new attribute description.
 * @param type: Attribute type (one of BBAttributeTypeNumber, BBAttributeTypeString, BBAttributeTypeNominal)
 * @param pos:  Position (identifier) of the attribute
 * @param info: Additional informations. 
 * @return an autoreleased instance of BBAttributeDescription
 */
+(BBAttributeDescription*) descriptionWithType:(BBAttributeType) type  
									  position:(unsigned int) pos 
									   andInfo:(NSObject*) info; 

/**
 * Initializes a new attribute description. @see descriptionWithType:position:andInfo:
 */
-(id)initWithType:(BBAttributeType) type 
		 position:(unsigned int) pos
		  andInfo:(NSObject*) info;

/**
 * @return the position that identifies this attribute.
 */
-(unsigned int) position;

/**
 * @return the current attribute type
 */
-(BBAttributeType) type;

/**
 * Returns additional pieces of information associated with this attribute.
 * For BBAttributeTypeNominal, this is an NSSet containing the possible values.
 * @returns an NSObject (this should be casted to the proper type by the user).
 */
-(NSObject*) info;

/**
 * Returns a BBRawAttributeReading object capable of reading this kind of attribute
 */
-(NSObject<BBRawAttributeReading>*) reader;

	// NSCoding
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)encoder;


@end
