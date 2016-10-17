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
//  BBCarpeDiemClassifier.m
//  SeqLearning
//
//  Created by Roberto Esposito on 26/9/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBCarpeDiemClassifier.h"
#import <SeqLearning/BBFeature.h>
#import <SeqLearning/BBExceptions.h>
#import <SeqLearning/BBFeaturesManager.h>
#import <SeqLearning/BBCPointerWrapper.h>
#import <string.h>
#import <stdio.h>


NSString* BBViterbiClassifierWillAnalyzeEventAtTimeNotification=@"BBViterbiClassifierWillAnalyzeEventAtTimeNotification";


#define OPEN_NODE_AT_TIME(t,n) { nodesInfo->open[(t)][(n)]=1; ++nodesInfo->numNodesOpenedAtTime[(nodesInfo->curTime)]; }


#pragma mark SORTING FUNCTIONS

typedef struct  {
	NSDictionary* labelsToIndexes;
	double* scores;
	unsigned int t;
} SortInfo;


NSInteger verticalWeightSort(id label1, id label2, void *context) {
	SortInfo* sortInfo = (SortInfo*) context;
	unsigned int firstIndex = [[sortInfo->labelsToIndexes objectForKey:label1] intValue];
	unsigned int secondIndex= [[sortInfo->labelsToIndexes objectForKey:label2] intValue];
	
	//	NSLog(@"%@ %f %@ %f", label1, sortInfo->scores[firstIndex], label2, sortInfo->scores[secondIndex]);
	
	if( sortInfo->scores[firstIndex] < sortInfo->scores[secondIndex] )
		return NSOrderedDescending;
	else if( sortInfo->scores[firstIndex] > sortInfo->scores[secondIndex] )
		return NSOrderedAscending;
	else
		return NSOrderedSame;
}

#pragma mark SUPPORTING DATA STRUCTURES



NodesInfo* 
newNodesInfo(NSArray* labelSet,
			 unsigned int T) {
    if(T==0)
        @throw [NSException exceptionWithName:@"ZeroLenSeqError" reason:@"Zero length sequences are not supported" userInfo:nil];
	
	// alloc-ing memory
	unsigned int numLabels = [labelSet count];
	NodesInfo* info;
	info = (NodesInfo*) malloc( sizeof(NodesInfo) );
	NSCAssert( info!=NULL, 
			   [NSString stringWithCString:strerror(errno)
								  encoding: NSASCIIStringEncoding] );		
	info->scores = (double**) malloc( sizeof(double*) * T );	
	info->ancestors = (int**) malloc( sizeof(int*) * T );
	info->open = (bool**) malloc( sizeof(bool*) * T );
	info->bestPathWeightAtTime = (double*) calloc( T+1, sizeof(double)   );
	info->sortedLabels = malloc( sizeof(NSArray*)*T );
	info->numLabels = numLabels;
	info->T = T;
	info->labelSet = [labelSet retain];
	
	// handling no enough memory error
	NSCAssert( info->scores!=NULL &&
			   info->ancestors!=NULL &&
			   info->open!=NULL &&
			   info->sortedLabels!=NULL,
			   [NSString stringWithCString:strerror(errno)
								  encoding: NSASCIIStringEncoding] );
	
	int t;
	for(t=0; t<T; ++t) {
		info->scores[t] = malloc( sizeof(double) * numLabels );
		info->ancestors[t] = malloc( sizeof(int) * numLabels );		
		// calloc guarantees initialization of open[t][l] to false
		info->open[t] = calloc( numLabels, sizeof(bool) );
		info->sortedLabels[t]=nil;
		
		NSCAssert( info->scores[t]!=NULL &&
				   info->ancestors[t]!=NULL &&
				   info->open[t]!=NULL,
				   [NSString stringWithCString:strerror(errno)
									  encoding: NSASCIIStringEncoding] );
		
	}
	
	NSMutableDictionary* labelsToIndexes = 
		[[NSMutableDictionary alloc] initWithCapacity:numLabels];
	
	int l;
	for(l=0; l<numLabels; ++l) {
		[labelsToIndexes setObject:[NSNumber numberWithInt:l]
							forKey:[labelSet objectAtIndex:l]];
	}			
	
	info->labelsToIndexes = labelsToIndexes;
	
	info->numNodesOpenedAtTime = (int*) malloc( sizeof(int) * info->T );
	for(t=0; t<info->T; ++t)
		info->numNodesOpenedAtTime[t]=0;
	
	info->curTime = 0;
	return info;
}

void releaseNodesInfo(NodesInfo* info) {
	int t;
	for( t=0; t<info->T; ++t ) {
		free( info->scores[t] );
		free( info->ancestors[t] );
		free( info->open[t] );
		[info->sortedLabels[t] release];
	}
	
	free(info->scores);
	free(info->ancestors);
	free(info->open);	
	free(info->sortedLabels);
	free(info->bestPathWeightAtTime);
	
	[info->labelSet release];
	[info->labelsToIndexes release];
	
	free(info->numNodesOpenedAtTime);
	
	free( info );	
}


void dumpNodesInfoStatus(NodesInfo* nodesInfo, int t_end) {
	int t;
	int l;
	
	printf("      ");
	for(t=0; t<=t_end; ++t) {
		printf("%8d ",t);
	}		
	printf("\n");
	
	for(l=0; l<nodesInfo->numLabels; ++l) {
		printf("-%5s ", [[[nodesInfo->labelSet objectAtIndex:l] description] cStringUsingEncoding:NSASCIIStringEncoding] );
		for(t=0; t<=t_end; ++t) {
			if(nodesInfo->open[t][l])
				printf(" %6.1f  ",nodesInfo->scores[t][l]);
			else
				printf("(%6.1f) ", nodesInfo->scores[t][l]);
		}
		printf("\n");
	}	
}


@implementation BBCarpeDiemClassifier

#pragma mark CONSTRUCTOR AND DESTRUCTOR

-(id) init {
	if( (self=[super init]) ) {
		_verticalWeights = nil;
		_verticalFeatures = nil;
		_horizontalWeights = nil;
		_horizontalFeatures = nil;
		_lastExecutionNodesInfo = NULL;
	}
	
	return self;
}

-(void) dealloc {
	if( _lastExecutionNodesInfo!=NULL ) {
		releaseNodesInfo(_lastExecutionNodesInfo);
	}
	
	[_verticalFeatures release];
	[_verticalWeights release];
	[_horizontalFeatures release];
	[_horizontalWeights release];
	[_featuresManager release];
	
	[super dealloc];
}


#pragma mark UTILITIES

-(NSString*) description {
	return [NSString stringWithFormat:
		@"BBCarpeDiemClassifier {weights:%@ features:%@}", _weights, _features];
}


-(NSArray*) numberOfOpenNodesPerLayerInLastExecution {	
//	NSMutableArray* result = [NSMutableArray arrayWithCapacity:_lastExecutionNodesInfo->T];
//	unsigned t;
//	unsigned totClosed = _lastExecutionNodesInfo->numLabels;
//	[result addObject:
//		[NSNumber numberWithFloat:((float)_lastExecutionNodesInfo->numNodesOpenedAtTime[0])/totClosed]];
//	totClosed-=_lastExecutionNodesInfo->numNodesOpenedAtTime[0];
//	
//	for( t=1; t<_lastExecutionNodesInfo->T; ++t ) {
//		totClosed+=_lastExecutionNodesInfo->numLabels;
//		[result addObject:[NSNumber numberWithFloat:((float)_lastExecutionNodesInfo->numNodesOpenedAtTime[t])/totClosed]];
//		totClosed-=_lastExecutionNodesInfo->numNodesOpenedAtTime[t];
//	}
//	
//	return result;

	NSMutableArray* result = [NSMutableArray arrayWithCapacity:_lastExecutionNodesInfo->T];
	unsigned t;
	unsigned numLabels = _lastExecutionNodesInfo->numLabels;
	[result addObject:
		[NSNumber numberWithFloat:((float)_lastExecutionNodesInfo->numNodesOpenedAtTime[0])/numLabels]];
	
	for( t=1; t<_lastExecutionNodesInfo->T; ++t ) {
		[result addObject:[NSNumber numberWithFloat:((float)_lastExecutionNodesInfo->numNodesOpenedAtTime[t])/numLabels]];
	}
	
	return result;
}



#pragma mark SETTER AND GETTER METHODS

/**
* ----- Notes on features handling -----
 * In this implementation of the Viterbi classifier, it is important to 
 * distinguish among features that do not exploit the first-order markovian
 * assumption, from the ones that do. The reason is that zero-order features
 * need not to be evaluated a quadratic (in the number of labels) number of
 * times. This is exploited by the algorithm to lower the complexity of the
 * Viterbi decoding process. The new algorithm has still quadratic worst-case 
 * complexity, but it improves on Viterbi in two ways: it has a linear best-case
 * complexity and, anyway, zero-order features are evaluated only when really
 * necessary.
 *
 * In the following we will refer with the term ``vertical features'' to
 * zero-order features, and with the term ``horizontal features'' to the other
 * ones.
 */


/**
* This method is called by setFeatures and should *not* be called directly.
 */
-(void) setHorizontalFeatures:(NSArray*) features {
	[_horizontalFeatures autorelease];
	_horizontalFeatures = [features retain];
}


/**
* This method is called by setFeatures and should *not* be called directly.
 */

-(void) setVerticalFeatures:(NSArray*) features {
	[_verticalFeatures autorelease];
	_verticalFeatures = [features retain];
}


/**
* This method is called by setFeatures and should *not* be called directly.
 */
-(void) setHorizontalWeights:(NSArray*) weights {
	[_horizontalWeights autorelease];
	_horizontalWeights = [weights retain];
}


/**
* This method is called by setWeights and should *not* be called directly.
 */

-(void) setVerticalWeights:(NSArray*) weights {
	[_verticalWeights autorelease];
	_verticalWeights = [weights retain];
}


-(NSArray*) features {
	return _features;
}

-(NSMutableArray*) weights {
	return _weights;
}

/**
 * Sets the set of features that will be used by the classifier. 
 * NOTE: The method complexity is linear in the number of features, the
 * reason is that it needs to examine its input in order to distinguish
 * between horizontal and vertical features.
 */


-(void) setFeatures:(NSArray*) features {
	[_features autorelease];
	_features = [features retain];	
	
	NSMutableArray* horizontalFeatures =
		[NSMutableArray arrayWithCapacity:[features count]];
	NSMutableArray* verticalFeatures =
		[NSMutableArray arrayWithCapacity:[features count]];
	
	int i;
	int featuresCount = [features count];
	for(i=0; i<featuresCount; ++i) {
		BBFeature* feature = [features objectAtIndex:i];
		if( [feature orderOfMarkovianAssumption]==0 )
			[verticalFeatures addObject:feature];
		else
			[horizontalFeatures addObject:feature];
	}
	
	[self setHorizontalFeatures:horizontalFeatures];
	[self setVerticalFeatures:verticalFeatures];
}


/**
* Sets the set of weights that will be used by the classifier. 
 * NOTE: The method complexity is linear in the number of features, the
 * reason is that it needs to examine its input in order to distinguish
 * between horizontal and vertical features.
 * PRE: The features should have been already set.
 */

-(void) setWeights:(NSMutableArray*) weights {
	NSArray* features = [self features];
	if( features==nil || [weights count]!=[features count]) {
		@throw [NSException exceptionWithName:BBGenericError
									   reason:	[NSString stringWithFormat:@"features not set yet, or |features[%ld]|!=|weights[%ld]|",
												 (unsigned long)[weights count],
												 (unsigned long)[features count]]
									 userInfo:nil];
	}
	
	[_weights autorelease];
	_weights = [weights retain];
	
	
	NSMutableArray* horizontalWeights =
		[NSMutableArray arrayWithCapacity:[features count]];
	NSMutableArray* verticalWeights =
		[NSMutableArray arrayWithCapacity:[features count]];
	
	
	int i;
	int featuresCount = [features count];	
	
	for(i=0; i<featuresCount; ++i) {
		BBFeature* feature = [_features objectAtIndex:i];
		if( [feature orderOfMarkovianAssumption]==0 )
			[verticalWeights addObject:[weights objectAtIndex:i]];
		else
			[horizontalWeights addObject:[weights objectAtIndex:i]];
	}
	
	[self setHorizontalWeights:horizontalWeights];
	[self setVerticalWeights:verticalWeights];		
}

#pragma mark -

-(NSArray*) verticalFeatures {
	return _verticalFeatures;
}

-(NSArray*) horizontalFeatures {
	return _horizontalFeatures;
}


-(NSArray*) verticalWeights {
	return _verticalWeights;
}

-(NSArray*) horizontalWeights {
	return _horizontalWeights;
}


-(BBFeaturesManager*) featuresManager {
	return _featuresManager;
}

-(void) setFeaturesManager:(BBFeaturesManager *)featuresManager {
	[_featuresManager autorelease];
	_featuresManager = [featuresManager retain];
}


#pragma mark SCORE EVALUATION

-(double) scoreForSequence:(BBSequence*) sequence
					atTime:(unsigned int) t
			 usingFeatures:(NSArray*) features
				andWeights:(NSArray*) weights {
	int i;
	unsigned int numFeatures = [features count];
	double totalWeight=0.0;
	for(i=0; i<numFeatures; ++i) {
		BBFeature* feature = [features objectAtIndex:i];
		double weight = [[weights objectAtIndex:i] doubleValue];

		skip_nil_feature();
		
		if( [feature evalOnSequence:sequence forTime:t] == TRUE ) 
			totalWeight+=weight;
	}
	
	return totalWeight;
}

-(double) verticalScoreForSequence:(BBSequence*) sequence
							atTime:(unsigned int) t {
	return [self scoreForSequence:sequence 
						   atTime:t
					usingFeatures:[self verticalFeatures]
					   andWeights:[self verticalWeights]];
}

-(double) horizontalScoreForTransitionFromNode:(id) from_node
										toNode:(id) to_node
									onSequence:(BBSequence*) sequence
									   endTime:(unsigned int) t {
	[sequence setLabel:from_node forTime:t-1];
	[sequence setLabel:to_node forTime:t];
	
	return [self scoreForSequence:sequence 
						   atTime:t
					usingFeatures:[self horizontalFeatures]
					   andWeights:[self horizontalWeights]];
}

-(double) totalPositiveScoreOfHorizontalFeatures {
	NSMutableDictionary* mapper = [NSMutableDictionary dictionaryWithCapacity:100];
	BBFeaturesManager* featuresManager = [self featuresManager];
	if(!featuresManager) {
		@throw [NSException exceptionWithName:BBGenericError 
									   reason:@"Internal Error (this is a bug!) Features Manager not set!" 
									 userInfo:nil];
	}	
	NSDictionary* featuresToCategory = 
		[featuresManager featuresToMutexCategoryMapper];
	
	int i;
	int n_features = [_horizontalFeatures count];
	for(i=0; i<n_features; ++i) {				
		BBFeature* feature = [_horizontalFeatures objectAtIndex:i];
		
		NSNumber* category = [featuresToCategory objectForKey:feature];
		NSAssert(category!=nil, 
				 ([NSString stringWithFormat:@"Category for feature:%@ not found",
					 feature]));
		
		double cur_weight = [[_horizontalWeights objectAtIndex:i] doubleValue];
		
		NSNumber* best_weight = [mapper objectForKey:category];
		if(cur_weight>0 && (best_weight==nil || cur_weight>[best_weight doubleValue]) ) {
			[mapper setObject:[NSNumber numberWithDouble: cur_weight]
					   forKey: category];			
		}		
	}
	
	NSEnumerator* catEnumerator = [mapper objectEnumerator];
	NSNumber* weight;
	double totScore = 0.0;
	
	while( (weight = [catEnumerator nextObject]) ) {
		totScore += [weight doubleValue];
	}
	
	return totScore;
}

/*
 * This is a recursive procedure that evaluates the ``real'' weight for node
 * at rank cur_rank at time t. The procedure analyzes the nodes at time t-1
 * in the order given by nodesInfo->sortedNodes[t-1]. For each of them we may
 * be in two situations:
 *  the node is open: we already know the best path to that node. We can evaluate
 *				      the cost of going from that node to the node we need and
 *                    check if this outperform the current best one.
 *  the node is closed: we evaluate an upper-bound to the cost to reach that node.
 *					    if it outperform the current cost, we (recursively) open 
 *                      that node and work as before. Otherwise, the algorithm
 *                      stops (neither that node, nor any following node can
							   *						outperform the current best).
 *
 * At the end of the procedure, nodesInfo->scores[t][cur_rank_index] will be
 * set to the weight of the path leading to the node indexed by cur_rank_index
 * and that node will be reported as closed. Also, the ancestor for that node
 * will be set to the correct value.
 */ 

-(void) openNodeAtRank:(unsigned int) cur_rank
			   andTime:(unsigned int) t
			 nodesInfo:(NodesInfo*) nodesInfo 
			onSequence:(BBSequence*) sequence {	
	id target_node = [nodesInfo->sortedLabels[t] objectAtIndex:cur_rank];
	int target_node_index = [[nodesInfo->labelsToIndexes objectForKey:target_node] intValue];
	if( nodesInfo->open[t][target_node_index] )
		return;
	
	
	id best_node = [nodesInfo->sortedLabels[t-1] objectAtIndex:0];
	int best_node_index = [[nodesInfo->labelsToIndexes objectForKey:best_node] intValue];
	
	NSAssert( nodesInfo->numLabels>0 &&
			  nodesInfo->open[t-1][best_node_index],
			  ([NSString stringWithFormat:@"Internal error: numLabels>0 && nodesInfo->open[t-1][best_node_index]; t:%d b_n_i:%d numLabels:%d",
				  t, best_node_index, nodesInfo->numLabels]));
				  
	
	double best_weight = 
		nodesInfo->scores[t-1][best_node_index] +
		[self horizontalScoreForTransitionFromNode:best_node 
											toNode:target_node
										onSequence:sequence
										   endTime:t]+
		nodesInfo->scores[t][target_node_index];
	bool found = false;
	int l;
	for(l=1; l<nodesInfo->numLabels && !found; ++l ) {
		id cur_node = [nodesInfo->sortedLabels[t-1] objectAtIndex:l];
		int cur_node_index = [[nodesInfo->labelsToIndexes objectForKey:cur_node] intValue];
		
		if( !nodesInfo->open[t-1][cur_node_index] ) {
			// CUR NODE IS CLOSED
			if(nodesInfo->bestPathWeightAtTime[t-1] +   //weight for landing on the best nod at time t-2
			   nodesInfo->wHorizontalFeatures +			//bound to the weight for transition to node at time t-1
			   nodesInfo->scores[t-1][cur_node_index] + //vertical weight for node at time t-1
			   nodesInfo->wHorizontalFeatures +			//bound to the weight for transition to node at time t
			   nodesInfo->scores[t][target_node_index]  // vertical weight of node at time t
			   < best_weight) {
				// there cannot be a better node than the current one
				found=1;
				continue;
			}			   			
			
			// cur node can outbeat the best one, let's open it
			[self openNodeAtRank:l
						 andTime:t-1
					   nodesInfo:nodesInfo
					  onSequence:sequence];			
		}
		
		
		if( nodesInfo->scores[t-1][cur_node_index] + 
			nodesInfo->wHorizontalFeatures +
			nodesInfo->scores[t][target_node_index]
			< best_weight ) {
			// we avoid evaluating horizontal features on that node
			// they cannot make this node be better than current best			
			continue; 	
		}
		
		// here - cur_node is open and it is a valid candidate
		double horizontal_weight = 
			[self horizontalScoreForTransitionFromNode:cur_node 
												toNode:target_node
											onSequence:sequence
											   endTime:t];
		if( nodesInfo->scores[t-1][cur_node_index] + 
			horizontal_weight +
			nodesInfo->scores[t][target_node_index]	> best_weight ) {
			// congratulations ;-) - we found a new best node 
			// best_node = cur_node; -- At this point in the algorithm, to store the best_node reference is not really needed
			best_node_index = cur_node_index;
			best_weight =  nodesInfo->scores[t-1][cur_node_index] + 
				horizontal_weight + 
				nodesInfo->scores[t][target_node_index];
		}
 	}
	
	/*	nodesInfo->open[t][target_node_index]=1;*/
	OPEN_NODE_AT_TIME(t,target_node_index);
	nodesInfo->scores[t][target_node_index]=best_weight;
	nodesInfo->ancestors[t][target_node_index]=best_node_index;
}



-(int) bestNodeForSequence:(BBSequence*) sequence
				 nodesInfo:(NodesInfo*) nodesInfo {
	// preliminaries -- initializating supporting structures
	int l;
	for(l=0; l<nodesInfo->numLabels; ++l) {
		nodesInfo->ancestors[0][l] = -1;		
		/*		nodesInfo->open[0][l]=1;*/
		OPEN_NODE_AT_TIME(0,l);
	}
	
	
	// preliminaries evaluating W_h
	
	nodesInfo->wHorizontalFeatures = [self totalPositiveScoreOfHorizontalFeatures];
	// to reach a node at time 0, the weight of the path is at most 0
	nodesInfo->bestPathWeightAtTime[0] = 0.0;
	
	// main work
	
#define INDEX_OF_LABEL_WITH_RANK(rank) [[nodesInfo->labelsToIndexes objectForKey:[nodesInfo->sortedLabels[t] objectAtIndex:(rank)]] intValue]	
	
	int cur_rank;
	int cur_rank_index = -1;
	int next_rank;
	int next_rank_index;
	int t;
	for(t=0; t<nodesInfo->T; ++t) {
		nodesInfo->curTime = t;
		
		for(l=0; l<nodesInfo->numLabels; ++l) {
			[sequence setLabel:[nodesInfo->labelSet objectAtIndex:l]
					   forTime:t];
			nodesInfo->scores[t][l] = [self verticalScoreForSequence:sequence 
															  atTime:t];
		}
		
		SortInfo si;
		si.scores = nodesInfo->scores[t];
		si.labelsToIndexes = nodesInfo->labelsToIndexes;
		nodesInfo->sortedLabels[t] =
			[[nodesInfo->labelSet sortedArrayUsingFunction:verticalWeightSort
												   context:&si] retain];
		
		//{
		//			int k;
		//			for(k=0; k<nodesInfo->numLabels; ++k) {
		//				NSString* label = [nodesInfo->sortedLabels[t] objectAtIndex:k];
		//				NSLog(@"%d %@ %@ %f", 
		//					  k,
		//					  [nodesInfo->labelSet objectAtIndex:k],
		//					  [nodesInfo->sortedLabels[t] objectAtIndex:k],
		//					  nodesInfo->scores[t][[[nodesInfo->labelsToIndexes objectForKey:label]  intValue]]
		//					  );
		//			}
		//			
		//			NSLog(@"-----------------------------------------------");
		//		}
			
			NSDictionary* notificationOptions = 
			[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:t], @"time",
				[NSNumber numberWithFloat:nodesInfo->bestPathWeightAtTime[t]+nodesInfo->wHorizontalFeatures], @"bound",
				[BBCPointerWrapper wrapperWithPointer:nodesInfo], @"nodesInfo",
				nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:BBViterbiClassifierWillAnalyzeEventAtTimeNotification
																object:self
															  userInfo:	notificationOptions ];
			
			
			cur_rank=0;		
			[self openNodeAtRank:cur_rank
						 andTime:t
					   nodesInfo:nodesInfo
					  onSequence:sequence];
			// now nodesInfo->scores[t][index_of_cur_rank] contains the correct weight
			// for node corresponding to rank cur_rank.		
			NSAssert( nodesInfo->numLabels > 1, 
					  @"Learning using less than two labels seems a little bit trivial..." );
			cur_rank_index = INDEX_OF_LABEL_WITH_RANK(0);
			
			next_rank=1;
			next_rank_index = INDEX_OF_LABEL_WITH_RANK(1);		
			
			
			while( next_rank<nodesInfo->numLabels &&
				   nodesInfo->scores[t][cur_rank_index] < 
				   (nodesInfo->bestPathWeightAtTime[t] + 
					nodesInfo->scores[t][next_rank_index] + 
					nodesInfo->wHorizontalFeatures) ) {
				// node at rank next_rank can actually beat cur_rank
				
				[self openNodeAtRank:next_rank
							 andTime:t
						   nodesInfo:nodesInfo
						  onSequence:sequence];
				
				if( nodesInfo->scores[t][cur_rank_index] < nodesInfo->scores[t][next_rank_index] ) {
					// next_rank is actually the best node
					cur_rank=next_rank;
					cur_rank_index = INDEX_OF_LABEL_WITH_RANK(cur_rank);
				} 
				
				++next_rank;
				if( next_rank<nodesInfo->numLabels )
					next_rank_index = INDEX_OF_LABEL_WITH_RANK(next_rank);
				
			}
			
			//		if(t==9 || t==10) {
			//			printf("t==%d\n",t);
			//			printf("Sigma1*:%f\n", nodesInfo->wHorizontalFeatures);
			//			for(l=0; l<nodesInfo->numLabels; ++l) {
			//				[sequence setLabel:[nodesInfo->labelSet objectAtIndex:l]
			//						   forTime:t];
			//				double vScore = 
			//					[self verticalScoreForSequence:sequence
			//											atTime:t];
			//				
			//				printf("%-5s (%6.1f)\n", 
			//					   [[[nodesInfo->labelSet objectAtIndex:l] description] cString],
			//					   vScore );
			//			}
			//			
			//
			//			dumpNodesInfoStatus(nodesInfo,t);
			//		}
			
			
			
			// cur_rank is the index in nodesInfo->sortedLabels corresponding to
			// the best node at time t. It is, then, the score of the best path
			// at time t+1.		
			
			nodesInfo->bestPathWeightAtTime[t+1] = nodesInfo->scores[t][cur_rank_index];
			
			// note: the notification options we're giving to this post has been built
			// at the beginning of this iteration. Since "time" is not yet changed and
			// the nodesInfo ptr points to the same location as before (even though its
			// content changed), then it is safe to pass the same dictionary object to 
			// the notification.
			[[NSNotificationCenter defaultCenter] postNotificationName:BBViterbiClassifierAnalyzedEventAtTimeNotification
																object:self
															  userInfo:notificationOptions];			
	}
#undef INDEX_OF_LABEL_WITH_RANK

	if( cur_rank_index == -1 ) {
		@throw [NSException exceptionWithName:BBGenericError 
									   reason:@"An internal error occured while evaluating the CarpeDiem classifier. This is certainly a bug, please contact the support team." 
									 userInfo:nil];
	}
	
// cur_rank is the index in nodesInfo->sortedLabels corresponding to
// the best node at time T-1.		
return cur_rank_index;
}


-(NSArray*) pathWithEndNodeAtIndex:(unsigned int) endNode
					usingNodesInfo:(NodesInfo*) nodesInfo {
	id* path = (id*) malloc( sizeof(id) * nodesInfo->T );
	int cur_node = endNode;
	int t=nodesInfo->T-1;
	
	while( cur_node!=-1 && t>=0 ) {
		path[t] = [nodesInfo->labelSet objectAtIndex:cur_node];
		cur_node=nodesInfo->ancestors[t][cur_node];
		--t;
	}
	
	NSAssert( cur_node==-1 && t==-1, 
			  @"Ancestor not initialized for t!=-1");
	NSArray* result = [NSArray arrayWithObjects:path
										  count:nodesInfo->T];
	
	free( path );
	return result;
}


#pragma mark FASTER VITERBI DECODING


//-(void) dumpWeights {
//	NSArray* vWeights = [self verticalWeights];
//	NSArray* hWeights = [self horizontalWeights];
//	
//	FILE* vWeightsFile = fopen("/Users/esposito/Desktop/vWeights.txt", "w");
//	fprintf(vWeightsFile, "Vertical Weights\n");	
//	for( NSNumber* weight in  vWeights) {
//		double w = [weight doubleValue];
//		if(w!=0.0)
//			fprintf( vWeightsFile, "%f", w);
//	}
//	fclose(vWeightsFile);
//	
//	FILE* hWeightsFile = fopen("/Users/esposito/Desktop/hWeights.txt", "w");
//	fprintf(hWeightsFile, "Horizontal Weights\n");	
//	for( NSNumber* weight in  hWeights) {
//		double w = [weight doubleValue];
//		if(w!=0.0)
//			fprintf( hWeightsFile, "%f", w);
//	}
//	fclose(hWeightsFile);
//}

//-(void) dumpFeatures {
//	NSArray* vFeatures = [self verticalFeatures];
//	NSArray* hFeatures = [self horizontalFeatures];
//	
//	FILE* vFeaturesFile = fopen("/Users/esposito/Desktop/vFeatures.txt", "w");
//	fprintf(vFeaturesFile, "Vertical Features\n");	
//	
//	int vCount = [vFeatures count];
//	int i;
//	for( i=0; i<vCount; ++i ) {
//		double w = [[[self verticalWeights] objectAtIndex:i] doubleValue];
//		if(w!=0.0)
//			fprintf( vFeaturesFile, "%s\n", [[[vFeatures objectAtIndex:i] description] cString]);
//	}
//	fclose(vFeaturesFile);
//
//
//	FILE* hFeaturesFile = fopen("/Users/esposito/Desktop/hFeatures.txt", "w");
//	fprintf(hFeaturesFile, "Horizontal Features\n");	
//	
//	int hCount = [hFeatures count];
//	for( i=0; i<hCount; ++i ) {
//		double w = [[[self horizontalWeights] objectAtIndex:i] doubleValue];
//		if(w!=0.0)
//			fprintf( hFeaturesFile, "%s\n", [[[hFeatures objectAtIndex:i] description] cString]);
//	}
//	fclose(hFeaturesFile);
//	
//}

-(NSArray*) labelsForSequence:(BBSequence*) sequence {
	NSArray* labelSet = [(NSSet*) [[sequence labelDescription] info] allObjects];
	// Initialization of supporting data structures
	if(_lastExecutionNodesInfo!=NULL) {
		// thrashing the trashable
		releaseNodesInfo(_lastExecutionNodesInfo);
		_lastExecutionNodesInfo=NULL;
	}
	
//	[self dumpWeights];
//	[self dumpFeatures];
	
	NodesInfo* nodesInfo = newNodesInfo(labelSet,[sequence length]);
	
	unsigned int endNode = [self bestNodeForSequence:sequence
										   nodesInfo:nodesInfo];
		
	NSArray* result = [self pathWithEndNodeAtIndex:endNode
									usingNodesInfo:nodesInfo];
	
	_lastExecutionNodesInfo = nodesInfo;
	[sequence clearLabels];
	
	return result;
}

#pragma mark CODING PROTOCOL

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_features forKey:@"features"];
	[encoder encodeObject:_weights forKey:@"weights"];
	[encoder encodeObject:_featuresManager forKey:@"featuresManager"];
}

- (id)initWithCoder:(NSCoder *)coder {
	
    if((self = [self init])) {
		NSArray* features = [coder decodeObjectForKey:@"features"];
		NSMutableArray* weights = [coder decodeObjectForKey:@"weights"];
		BBFeaturesManager* manager = [coder decodeObjectForKey:@"featuresManager"];
		[self setFeatures:features];
		[self setWeights:weights];
		[self setFeaturesManager:manager];
		_lastExecutionNodesInfo = nil;
	}
	
    return self;
}


@end
