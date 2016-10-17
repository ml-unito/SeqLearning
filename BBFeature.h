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
//  BBFeature.h
//  SeqLearningNew
//
//  Created by Roberto Esposito on 19/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBSequence.h>

@interface BBFeature: NSObject <NSCoding,NSCopying> {
	NSDictionary* _parameters;
}

-(id)init;
-(void)dealloc;

-(NSString*) description;

-(void) setParameters:(NSDictionary*) parameters;
-(NSDictionary*) parameters;

-(void) setParametersFromString:(NSString*) parametersDescription;
-(NSString*) parametersAsString;


-(NSString*) parametersSnakeCaseDescription;

#pragma mark BBFeatures methods to be implemented
-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t;

// This method is used by BBCarpeDiemClassifier to distinguish
// between horizontal features (orderOfMarkovianAssumption>=1) and 
// vertical ones (orderOfMarkovianAssumption==0). The method should return
// the number of past labels that are inspected to evaluate the features.
// e.g., the feature inspects only the current label -> result should be 0
//		 the feature inspects the current and the previous label -> result=1
// If not reimplemented, this method returns 1.
-(unsigned int) orderOfMarkovianAssumption; 

// NSCoding
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)encoder;

// NSCopying
- (id)copyWithZone:(NSZone *)zone;
@end
