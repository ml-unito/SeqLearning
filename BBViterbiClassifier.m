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
//  BBViterbiClassifier.m
//  SeqLearningNew
//
//  Created by Roberto Esposito on 19/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBViterbiClassifier.h>
#import <SeqLearning/BBFeature.h>
#import <SeqLearning/BBAttributeDescription.h>
#import <SeqLearning/BBMutableDouble.h>

NSString* BBViterbiClassifierAnalyzedEventAtTimeNotification=@"BBViterbiClassifierAnalyzedEventAtTimeNotification";

int 
skip_nil_features_is_enabled(void) {
	double weight = 0;
	int i,c;
	c = 0;
	for(i=0; i < 1; ++i) {
		skip_nil_feature();
		++c;
	}
	return c==0;
}

@implementation BBViterbiClassifier

-(BOOL) invalid {
	if( _weights == nil || _features == nil )
		return TRUE;
	
	int i;
	int count = [_weights count];
	BOOL found = FALSE;
	for(i=0; i<count && !found; ++i) {
		double current = [[_weights objectAtIndex:i] doubleValue];
		found = current > 0.0001 || current < 0.0001;
	}
	
	return !found;
}

-(void) dumpScoresForTime:(unsigned int) T andLabels: (NSArray*) labels andScores: (ScoreMatrix) scores {
	int t;
	
	printf("         ");
	for(t=0; t<T; ++t) {
		printf("%12d", t);
	}
	printf("\n");
	
	int l;
	for( l=0; l<[labels count]; ++l) {
		printf("%8s ", [[labels objectAtIndex:l] cStringUsingEncoding:NSUTF8StringEncoding]);
		for(t=0; t<T; ++t) {
			printf("%8e ", scores[l][t]);
		}
		printf("\n");
	}
}

-(void) dumpAncestorsForTime:(unsigned int) T andLabels: (NSArray*) labels andAncestors: (AncestorMatrix) ancestors {
	int t;
	
	printf("         ");
	for(t=0; t<T; ++t) {
		printf("%12d", t);
	}
	printf("\n");
	
	int l;
	for( l=0; l<[labels count]; ++l) {
		printf("%8s ", [[labels objectAtIndex:l] cStringUsingEncoding:NSUTF8StringEncoding]);
		for(t=0; t<T; ++t) {
			printf("%8d ", ancestors[l][t]);
		}
		printf("\n");
	}
}



-(void) setFeatures:(NSArray*) features {
	[_features autorelease];
	_features = [features retain];
}

-(void) setWeights:(NSMutableArray*) weights {
	[_weights autorelease];
	_weights = [weights retain];
}

-(int) bestLabelUsingScores:(ScoreMatrix) scores 
					forTime:(int) time 
				  numLabels:(int) numLabels {
	/* Evaluating best label at the end of the sequence */
	double bestLabel=-1;
	double bestScore=-DBL_MAX;
	int i;
	for( i=0; i<numLabels; ++i ) {
		if(scores[i][time]>bestScore) {
			bestLabel=i;
			bestScore=scores[i][time];
		}
	}
	
	return bestLabel;
}

-(double) scoreForTransitionAtTime:(unsigned int) t onSequence:(BBSequence*) sequence{
	double score=0.0;
	int features_count = [_features count];
	int i;
	double weight;
	
	for( i=0; i<features_count; ++i ) {
		weight=[[_weights objectAtIndex:i] doubleValue];

		skip_nil_feature();
		
		if([[_features objectAtIndex:i] evalOnSequence:sequence forTime:t]) {
			score+=weight; 
		}
	}
		
	return score;
}


/*
 * Sets the labels for the given sequence following the chain of 
 * ancestors. It assumes that label for time ``time+1'' has been
 * assigned correctly.
 */

-(void) setLabelsOnResult: (NSMutableArray*) result 
	   followingAncestors: (AncestorMatrix) ancestors 
			 startingFrom: (int) time
		lastAssignedLabel: (int) lastAssignedLabel 
				   labels: (NSArray*) labels
{
	if(time==-1)
		return;
	
	int label = ancestors[lastAssignedLabel][time+1];
	[result replaceObjectAtIndex:time withObject:[labels objectAtIndex:label]];
	[self setLabelsOnResult:result
		 followingAncestors:ancestors
			   startingFrom:time-1
		  lastAssignedLabel: label
					 labels:labels];
}

/*
 * Returns the set of weights on the sequence to the target label following the chain of 
 * ancestors. It assumes that label for time ``time+1'' has been
 * assigned correctly.
 */

-(void) setWeightsOnResult: (NSMutableArray*) result 
		followingAncestors: (AncestorMatrix) ancestors 
			   usingScores: (ScoreMatrix) scores
			  startingFrom: (int) time
		 lastAssignedLabel: (int) lastAssignedLabel
					labels: (NSArray*) labels
{
	if(time==-1)
		return;
	
	int label = ancestors[lastAssignedLabel][time+1];
	[[result objectAtIndex:time] setDouble:scores[label][time]];
//	[result replaceObjectAtIndex:time withObject:[NSNumber numberWithDouble:scores[label][time]]];
	[self setWeightsOnResult:result
		 followingAncestors:ancestors
				 usingScores:scores
				startingFrom:time-1
		   lastAssignedLabel:label
					  labels:labels];
}




-(void) viterbiForwardWithScores:(ScoreMatrix) scores
						   ancestors:(AncestorMatrix) ancestors
							sequence:(BBSequence*) sequence 
							  labels:(NSArray*) labels 
 						  stopAtSize:(unsigned int) seqSize{
	int numLabels = [labels count];
	double   bestScore=-DBL_MAX;
	int bestAncestor=-1;
	int i,j,t;
	
	/* initialization of first column */
	for(i=0; i<numLabels; ++i) {
		[sequence setLabel:[labels  objectAtIndex:i] forTime:0];
		scores[i][0] =  [self scoreForTransitionAtTime:0
											onSequence:sequence];
		ancestors[i][0] = -1;
	}

	/* Evaluation of best label sequence */
	for(t=1; t<seqSize; ++t) {
		for(i=0; i<numLabels; ++i) {
			bestAncestor = -1;
			bestScore=-DBL_MAX;
			
			[sequence setLabel:[labels objectAtIndex:i] forTime:t];
			for(j=0; j<numLabels; ++j) {
				double score;
				
				[sequence setLabel:[labels objectAtIndex:j] forTime:t-1];
				
				score = scores[j][t-1] +
					[self scoreForTransitionAtTime:t onSequence:sequence];

				
				if( score>bestScore ) {
					bestScore = score;
					bestAncestor = j;
				}
			}
						
			scores[i][t] = bestScore;
			ancestors[i][t] = bestAncestor;
		}
		
				
		// [self dumpAncestorsForTime: t andLabels: labels andAncestors: ancestors];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:BBViterbiClassifierAnalyzedEventAtTimeNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:t]
																							   forKey:@"time"]];
	}		
}

-(NSArray*) bestLabelingEndingOnLabelNumber:(unsigned int) label
								   inVector:(NSArray*) labels
									 atTime:(unsigned int) t 
						 followingAncestors:(AncestorMatrix) ancestors {
	unsigned int seqSize = t+1;
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:seqSize];
	int i;
	for(i=0; i<seqSize; ++i)
		[result addObject:[NSNull null]];
	
	[result replaceObjectAtIndex:seqSize-1 withObject:[labels  objectAtIndex:label]];
	
	[self setLabelsOnResult: result 
		 followingAncestors: ancestors
			   startingFrom: seqSize-2
		  lastAssignedLabel: label 
					 labels: labels]; 
	return result;		
}

-(NSArray*) bestWeightsEndingOnLabelNumber:(unsigned int) label
								  inVector:(NSArray*) labels
									atTime:(unsigned int) t 
							   usingScores:(ScoreMatrix) scores
							  andAncestors:(AncestorMatrix) ancestors {
	unsigned int seqSize = t+1;
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:seqSize];
	int i;
	for(i=0; i<seqSize; ++i)
		[result addObject:[NSNull null]];
	
	[[result objectAtIndex:seqSize-1] setDouble:scores[label][seqSize-1]];
//	[result replaceObjectAtIndex:seqSize-1 withObject:[NSNumber numberWithDouble:scores[label][seqSize-1]]];
	
	[self setWeightsOnResult: result 
		  followingAncestors: ancestors
				 usingScores: scores
				startingFrom: seqSize-2
		   lastAssignedLabel: label 
					  labels: labels]; 
	return result;		
}

-(NSDictionary*) bestLabelingEndingOnLabel:(id) label 
							   atTime:(unsigned int) t 
						   onSequence:(BBSequence*) sequence {
	int seqSize   = [sequence length];
	NSArray* labels = [(NSSet*) [[sequence labelDescription] info] allObjects];
	int numLabels = [labels count];
	int labelNumber = -1;
	int i;
	
	/* initializing scores and ancestors */
	ScoreMatrix scores =
		(ScoreMatrix) malloc(sizeof(double*)*numLabels);
	AncestorMatrix ancestors =
		(AncestorMatrix) malloc(sizeof(int*)*numLabels);
	
	for(i=0; i<numLabels; i++) {
		scores[i] = (double*) malloc(sizeof(double)*seqSize);
		ancestors[i] = (int*) malloc(sizeof(int)*seqSize);
		if(labelNumber==-1 && [[labels objectAtIndex:i] isEqualToString:label])
			labelNumber=i;
	}
	
	
	[self viterbiForwardWithScores:scores 
						 ancestors:ancestors 
						  sequence:sequence
							labels:labels
					    stopAtSize:[sequence length]];
	
	
	NSArray* labelsResult = [self bestLabelingEndingOnLabelNumber:labelNumber
														 inVector:labels
														   atTime:t 
											   followingAncestors:ancestors];
	
	NSArray* weightResult = [self bestWeightsEndingOnLabelNumber:labelNumber
														inVector:labels
														  atTime:t
													 usingScores:scores
													andAncestors:ancestors];
	
	[sequence clearLabels];
		
	/* trashing the trashable */
	for(i=0; i<numLabels; i++) {
		free(scores[i]);
		free(ancestors[i]);
	}
	free(scores);
	free(ancestors);
	
	return [NSDictionary dictionaryWithObjectsAndKeys:
						labelsResult, @"labels",
						weightResult, @"weights",
						nil];										 
	
}


-(NSArray*) labelsForSequence:(BBSequence*) sequence {
	NSAssert( [_features count] == [_weights count],
			  @"Different number of features and weights" );
	
	int seqSize   = [sequence length];
	NSArray* labels = [(NSSet*) [[sequence labelDescription] info] allObjects];
	int numLabels = [labels count];
	int i;
	
	/* initializing scores and ancestors */
	ScoreMatrix scores =
		(ScoreMatrix) malloc(sizeof(double*)*numLabels);
	AncestorMatrix ancestors =
		(AncestorMatrix) malloc(sizeof(int*)*numLabels);
	
	for(i=0; i<numLabels; i++) {
		scores[i] = (double*) malloc(sizeof(double)*seqSize);
		ancestors[i] = (int*) malloc(sizeof(int)*seqSize);
	}
	

	[self viterbiForwardWithScores:scores 
						 ancestors:ancestors 
						  sequence:sequence
							labels:labels
					    stopAtSize:[sequence length]
	];
	
	unsigned int bestLabel = 
		[self bestLabelUsingScores:scores forTime:seqSize-1 numLabels:numLabels];

	NSArray* result = [self bestLabelingEndingOnLabelNumber:bestLabel 
												   inVector:labels
													 atTime:seqSize-1
										 followingAncestors:ancestors];													 
	
	[sequence clearLabels];
	
	/* trashing the trashable */
	for(i=0; i<numLabels; i++) {
		free(scores[i]);
		free(ancestors[i]);
	}
	free(scores);
	free(ancestors);
	
	return result;
}

// returns the weights gained by each label assignment in ``labels'' for the given sequence
// the algorithm is linear in n.
-(NSArray*) weigthsForSequenceOf:(unsigned int) n
						  labels:(NSArray*) labels 
					  onSequence:(BBSequence*) sequence {
	int t;
	NSMutableArray* result = [NSMutableArray arrayWithCapacity:n];
	double totalWeight=0;

	for(t=0; t<n; ++t) {
		[sequence setLabel:[labels objectAtIndex:t] forTime:t];
		int f;
		for( f=0; f<[_features count]; ++f) {
			BBFeature* feature = [_features objectAtIndex:f];

			if( [feature evalOnSequence:sequence forTime:t] )
				totalWeight += [(BBMutableDouble*) [_weights objectAtIndex:f] doubleValue];
		}
		
		[result addObject:[NSNumber numberWithDouble:totalWeight]];
	}
	
	[sequence clearLabels];
	return result;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_features forKey:@"features"];
	[encoder encodeObject:_weights forKey:@"weights"];
}

- (id)initWithCoder:(NSCoder *)coder {
	
    if((self = [self init])) {
		NSArray* features = [coder decodeObjectForKey:@"features"];
		NSMutableArray* weights = [coder decodeObjectForKey:@"weights"];
		[self setFeatures:features];
		[self setWeights:weights];
	}
	
    return self;
}

-(NSString*) description {
	return [NSString stringWithFormat:
		@"BBViterbiClassifier {weights:%@ features:%@}", _weights, _features];
}

-(NSMutableArray*) weights {
	return _weights;
}

-(NSArray*) features {
	return _features;
}


-(BBFeaturesManager*) featuresManager {
	return nil;
}

-(void) setFeaturesManager:(BBFeaturesManager *)featuresManager {
	return;
}

@end
