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
//  BBArffFormattedSequenceReader.h
//  SeqLearning
//
//  Created by Roberto Esposito on 25/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBSequenceReader.h>

@interface BBArffFormattedSequenceReader : BBSequenceReader {
	NSMutableDictionary* _knownDescriptions;
	NSString* _preferredFeaturesManagerClassName;
	NSScanner* _scanner;
}

-(id)init;

-(void) setFileName:(NSString*) fileName;
-(void) readAttributesDescriptions;
-(BBSeqSet*) readSeqSet;
-(NSMutableDictionary*) attributeDescriptions;


@end
