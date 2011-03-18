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
//  BBAstarViterbiClassifier.m
//  SeqLearning
//
//  Created by Roberto Esposito on 3/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SeqLearning/BBSequence.h"
#import "SeqLearning/BBFeature.h"
#import "SeqLearning/BBExceptions.h"
#import "SeqLearning/BBAstarViterbiClassifier.h"
#import "SeqLearning/BBAstarNode.h"



NSString* enqueuedKeyForNode(BBAstarNode* node) {
	return [NSString stringWithFormat:@"%@t:%d", node.label, node.t];
}


#pragma mark -

@implementation BBAstarViterbiClassifier

#pragma mark FEATURE HANDLING

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
	if( features==nil ||
	   [weights count]!=[features count]) {
		@throw [NSException exceptionWithName:BBGenericError
									   reason:
				[NSString stringWithFormat:@"features not set yet, or |features[%d]|!=|weights[%d]|",
				 [weights count],
				 [features count]]
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


#pragma mark -
#pragma mark ASTAR IMPLEMENTATION


-(BBAstarNode*) aStarSearch {
	BOOL found = FALSE;
	BBAstarNode* current;
	int largest_t = 0;
	int count = 0;
	int count_reopened = 0;
	
	while(![_openNodes isEmpty] && !found) {
		++count;
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		
		current = (BBAstarNode*) [_openNodes removeFirst];
		
		[_enqueuedInClosedNodes setObject:current 
								   forKey:enqueuedKeyForNode(current)];

		largest_t = (current.t > largest_t ? current.t : largest_t); // get max(largest_t,current.t)
		
		if( [current goal] ) {
			[current retain];
			found = TRUE;			
		} else {
			NSArray* successors = [current successors];

			for( BBAstarNode* successor in successors ) {
				NSString* successor_key = enqueuedKeyForNode(successor);
				BBAstarNode* found_node = [_enqueuedInOpenNodes objectForKey: successor_key];
				
				BOOL found_in_closed_nodes = NO;				
				if(!found_node ) {
					found_node = [_enqueuedInClosedNodes objectForKey: successor_key];
					found_in_closed_nodes = YES;
				}
				
				if( found_node!=nil ) {
					if( [found_node accumulatedWeight] < [successor accumulatedWeight] ) {
						NSAssert( [[found_node pathToParentNode] count] == [[successor pathToParentNode] count],
								 ([NSString stringWithFormat: @"found path size (%d) != successor path size (%d)\nfound:%@\nsuccessor:%@",
								  [[found_node pathToParentNode] count],
								  [[successor pathToParentNode] count],
								  found_node, 
								  successor]));
					
						
						
						[found_node setPath:[successor pathToParentNode]];
						[found_node setAccumulatedWeight:[successor accumulatedWeight]];
						
						if( found_in_closed_nodes ) {
							[_openNodes addObject:found_node];
							[_enqueuedInClosedNodes removeObjectForKey: successor_key];
							++count_reopened;
						}
					}
				} else {
					[_openNodes addObject: successor];					
				}
			}
		}
		
		
		NSDictionary* notificationOptions = [NSDictionary dictionaryWithObjectsAndKeys:
											 [NSNumber numberWithInt:largest_t], @"time",
											 nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:BBViterbiClassifierAnalyzedEventAtTimeNotification
															object:self
														  userInfo:notificationOptions];			

		[pool release];
	}
	
	
	NSLog(@"Number of iterations of main cycle:%d", count);
	NSLog(@"Number of reopenings:%d", count_reopened);
	
	if(found)
		return [current autorelease];
	else
		@throw [NSException exceptionWithName:@"AstarException" reason: @"Optimal node not found" userInfo:nil];
}


-(void) addObjectToEnqueuedNodes:(NSNotification*) notification {
	BBAstarNode* node = (BBAstarNode*) [[notification userInfo] objectForKey:@"object"];
	NSAssert( node!=nil && [[node className] isEqualToString:@"BBAstarNode"], @"Expecting object of type BBAstarNode" );
	
	[_enqueuedInOpenNodes setObject:node forKey:enqueuedKeyForNode(node)];
}

-(void) removeObjectFromEnqueuedNodes:(NSNotification*) notification {
	BBAstarNode* node = (BBAstarNode*) [[notification userInfo] objectForKey:@"object"];
	NSAssert( node!=nil && [[node className] isEqualToString:@"BBAstarNode"] , @"Expecting object of type BBAstarNode" );

	[_enqueuedInOpenNodes removeObjectForKey:enqueuedKeyForNode(node)];
}

-(NSArray*) labelsForSequence:(BBSequence*) sequence {
	NSArray* result = nil;
	_openNodes = [[BBPriorityQueueWithUpdatableKeys alloc] initWithOrder:BBPriorityQueueLargeFirst];
	_enqueuedInOpenNodes = [[NSMutableDictionary alloc] initWithCapacity:1000];
	_enqueuedInClosedNodes = [[NSMutableDictionary alloc] initWithCapacity:1000];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(addObjectToEnqueuedNodes:) 
												 name:BBPriorityQueueObjectAddedNotification
											   object:_openNodes];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(removeObjectFromEnqueuedNodes:) 
												 name:BBPriorityQueueRemovedFirstNotification
											   object:_openNodes];
	
	BBWeightsEvaluator* evaluator = [BBWeightsEvaluator evaluatorForSequence:sequence
																vertFeatures:_verticalFeatures 
															   horizFeatures:_horizontalFeatures 
																 vertWeights:_verticalWeights
																horizWeights:_horizontalWeights];	
	@try {		
		NSArray* labels =  [(NSSet*) [[sequence labelDescription] info] allObjects];
		for( NSObject* label in labels ) {
			BBAstarNode* node = [BBAstarNode nodeForLabel: label 
												evaluator: evaluator 
												  forTime: 0];
			[node setAccumulatedWeight:[evaluator vertWeightForLabel:label atTime:0]];
			[_openNodes addObject: node];		 		
		}
						
		result = [[self aStarSearch] path];
		
	} @finally {
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:BBPriorityQueueObjectAddedNotification
													  object:_openNodes];
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:BBPriorityQueueRemovedFirstNotification
													  object:_openNodes];
				
		[_enqueuedInOpenNodes release];
		[_enqueuedInClosedNodes release];

		[_openNodes release];
	}
	
	return result;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_features forKey:@"features"];
	[encoder encodeObject:_weights forKey:@"weights"];
}

- (id)initWithCoder:(NSCoder *)coder {
	
    if((self = [super init])) {
		NSArray* features = [coder decodeObjectForKey:@"features"];
		NSMutableArray* weights = [coder decodeObjectForKey:@"weights"];		
		[self setFeatures:features];
		[self setWeights:weights];
	}
	
    return self;
}




@end
