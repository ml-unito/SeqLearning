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
//  BBWeightsEvaluator.h
//  SeqLearning
//
//  Created by Roberto Esposito on 3/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SeqLearning/BBSequence.h"
#import "SeqLearning/BBFeaturesManager.h"

@interface BBWeightsEvaluator : NSObject {
	BBSequence* _sequence;

	NSArray* _verticalFeatures;
	NSArray* _horizontalFeatures;
	NSArray* _verticalWeights;
	NSArray* _horizontalWeights;
	double  _maxTransWeight;
	double*  _sumMaxVertWeights;
	BBFeaturesManager* _featuresManager;
}

-(id) initWithSequence:(BBSequence*) s 
		  vertFeatures:(NSArray*) vFeat 
		 horizFeatures:(NSArray*) hFeat 
		   vertWeights:(NSArray*) vW 
		  horizWeights:(NSArray*) hW;

-(void) dealloc;

+(BBWeightsEvaluator*) evaluatorForSequence:(BBSequence*) s 
							   vertFeatures:(NSArray*) vFeat 
							  horizFeatures:(NSArray*) hFeat 
								vertWeights:(NSArray*) vW 
							   horizWeights:(NSArray*) hW;


-(double) vertWeightForLabel:(NSObject*) label atTime:(int) t;
-(double) horizWeightFromLabel:(NSObject*) label1 toLabel:(NSObject*) label2 atTime:(int) t;
-(double) maxHorizWeightFromTime:(int) t;
-(double) maxVertWeightFromTime:(int) t;

-(int) sequenceLength;

-(NSArray*) labels;
-(double) computeMaxTransWeight;
-(double*) computeMaxVerticals;
-(BBFeaturesManager*) featuresManager;
-(void) setFeaturesManager: (BBFeaturesManager*) featuresManager;
@end
