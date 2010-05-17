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
//  BBViterbiClassifier.h
//  SeqLearningNew
//
//  Created by Roberto Esposito on 19/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBSequenceClassifying.h>

#if 1
#define skip_nil_feature(); if( weight==0 ) continue; 
#else
#warning Not skipping nil features.
#define skip_nil_feature(); 
#endif

extern NSString* BBViterbiClassifierAnalyzedEventAtTimeNotification;
extern int skip_nil_features_is_enabled(void);

typedef double** ScoreMatrix;
typedef int** AncestorMatrix;

@interface BBViterbiClassifier : NSObject <BBSequenceClassifying,NSCoding> {
	NSArray* _features;
	NSMutableArray* _weights;
}

-(NSString*) description;

-(void) setFeatures:(NSArray*) features;
-(void) setWeights:(NSMutableArray*) weights;

-(NSMutableArray*) weights;
-(NSArray*) features;

// returns the best labeling for the whole sequence, given the current set of weights
-(NSArray*) labelsForSequence:(BBSequence*) sequence;

// returns a dictionary containing two arrays. The array whose key is "labels"
// contains the best sequence of labels leading to ``label'', the array whose
// key is ``weights'' contains the corresponding sequence of weights.
// Notiche that the algorithm is Viterbi decoding (i.e., it is linear in t, but
// quadratic in the number of different labels).
//-(NSDictionary*) bestLabelingEndingOnLabel:(id) label 
//									atTime:(unsigned int) t 
//								onSequence:(BBSequence*) sequence;
								
// returns the weights gained by each label assignment in ``labels'' for the given sequence
// the algorithm is linear in t.
-(NSArray*) weigthsForSequenceOf:(unsigned int) t
						  labels:(NSArray*) labels 
					  onSequence:(BBSequence*) sequence;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)encoder;



-(double) scoreForTransitionAtTime:(unsigned int) t onSequence:(BBSequence*) sequence;


@end
