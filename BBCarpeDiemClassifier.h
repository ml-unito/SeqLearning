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
//  BBCarpeDiemClassifier.h
//  SeqLearning
//
//  Created by Roberto Esposito on 26/9/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBViterbiClassifier.h>
#import <SeqLearning/BBFeaturesManager.h>


// posted after the ranking evaluation has been done, before any other
// operation on the current layer. Keys associated with the userInfo dictionary:
// time: NSNumber (int) - the time point in time
// nodesInfo: BBCPointerWrapper: NodesInfo struct pointer wrapped with a BBCPointerWrapper.
extern NSString* BBViterbiClassifierWillAnalyzeEventAtTimeNotification;



/*
 * NodesInfo stores information needed in the different steps of the algorithm.
 * The fields are almost all self-explanatory. 
 * scores - scores evaluated for each node at each time step. The score may
 *          be an upper bound to the best path leeding to that node (in such
 *          a case, the node is still 'closed'), or it may be the cost of the
 *          actual path (in such a case, the node is 'open').
 * ancestors - ancestor of each node for each time step (ancestors are valid
 *             for open nodes only).
 * open - specifies whether a node is 'open' or not.
 * bestPathAtTime - for each time step it reports the cost of the best path 
 *                  to reach that time step (the transition from time step t-1
 *                  and t excluded). In other words, is the max of the vector
 *                  scores[t-1].
 * numLabels - number of different labels (i.e., nodes) for the current probem.
 * T - length of the sequence being analyzed 
 * curTime - index of the current layer
 * labelSet - array containing an enumeration of all labels
 * labelsToIndexs - maps objects representing labels to indexes in labelSet
 * sortedLabels - for each time step, it reports a sorted list of labels
 */

typedef struct {
	double** scores;
	int** ancestors;
	bool** open;
	double* bestPathWeightAtTime; 	
	unsigned int numLabels;
	unsigned int T;
	unsigned int curTime;
	double	 wHorizontalFeatures;
	
	NSArray* labelSet;
	NSDictionary* labelsToIndexes;
	NSArray** sortedLabels;
	
	// The following information are stored only as a way to allow easy calculation of
	// the time instant difficulty.
	int* numNodesOpenedAtTime;
} NodesInfo;


@interface BBCarpeDiemClassifier : BBViterbiClassifier {
/*	NSArray* _features;
	NSMutableArray* _weights; */
	
	NSArray* _verticalFeatures;
	NSArray* _horizontalFeatures;
	NSArray* _verticalWeights;
	NSArray* _horizontalWeights;
	
	NodesInfo* _lastExecutionNodesInfo;
	BBFeaturesManager* _featuresManager;
}

#pragma mark UTILITIES

-(NSString*) description;

#pragma mark SETTER AND GETTERS

-(void) setFeatures:(NSArray*) features;
-(void) setWeights:(NSMutableArray*) weights;

-(NSMutableArray*) weights;
-(NSArray*) features;

#pragma mark IMPLEMENTATION OF BBSequenceClassifying

	// returns the best labeling for the whole sequence, given the current set of weights
-(NSArray*) labelsForSequence:(BBSequence*) sequence;
-(NSArray*) numberOfOpenNodesPerLayerInLastExecution;

@end

