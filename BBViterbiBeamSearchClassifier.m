//
//  BBViterbiBeamSearchClassifier.m
//  SeqLearning
//
//  Created by Roberto Esposito on 12/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BBViterbiBeamSearchClassifier.h"
#import "BBFeature.h"
#include <stdlib.h>



typedef enum {
	SKIP_LABEL,
	ACCEPT_LABEL
} LabelSelectionStatus;

typedef struct {
	unsigned int originalIndex;
	double score;
} SelectionScoreInfo;

int scoresComparisonFunction(const void *fst, const void *snd) {
	SelectionScoreInfo* fst_score = (SelectionScoreInfo*)fst;
	SelectionScoreInfo* snd_score = (SelectionScoreInfo*)snd;

	if( fst_score->score > snd_score->score )
		return -1;
	
	if( fst_score->score == snd_score->score )
		return 0;
	
	return 1;
}

typedef int** LabelsSelection;

@implementation BBViterbiBeamSearchClassifier

-(id) init {
	if( (self=[super init]) ) {
		_beamSize = 0.1;
		_optimizeVerticalWeights = FALSE;
	}
	
	return self;
}


-(void) setOptimizeVerticalWeights:(bool) value {
	_optimizeVerticalWeights = value;
}



-(double) scoreForTransitionAtTime:(unsigned int) t onSequence:(BBSequence*) sequence {
	if( _optimizeVerticalWeights )
		return [super scoreForTransitionAtTime:t onSequence:sequence];
	else 
		return [self unoptimizedScoreForTransitionAtTime:t onSequence: sequence];
}


-(void) setBeamSize:(double) size {
	_beamSize = size;
}

-(void) setBeamSizeUsingNSNumber:(NSNumber*) size {
	[self setBeamSize:[size doubleValue]];
}


-(double) beamSize {
	return _beamSize;
}



//-(void) setBe

-(double) verticalScoreAtTime:(unsigned int) t onSequence:(BBSequence*) sequence{
	double score=0.0;
	int features_count = [_features count];
	int i;
	double weight;
	for( i=0; i<features_count; ++i ) {
		BBFeature* feature = [_features objectAtIndex:i];
		if([feature orderOfMarkovianAssumption]>0)
			continue;
		
		weight=[[_weights objectAtIndex:i] doubleValue];
		
		skip_nil_feature();
		
		if([[_features objectAtIndex:i] evalOnSequence:sequence forTime:t]) 
			score+=weight; 
	} 
	
	return score;
}


// for the time being the heuristic is only a placeholder for something
// that will be used in the future. Vertical weights and a beam size are
// used as heuristic

-(void) selectLabels:(NSArray*) labels
	   withHeuristic: (void*) h
		   storeInto:(LabelsSelection) indexes
		  onSequence:(BBSequence*) sequence
			  atTime:(unsigned int) t {
	// initialization
	SelectionScoreInfo* scores = (SelectionScoreInfo*) malloc( sizeof(SelectionScoreInfo) * [labels count] );
	NSObject* cur_label = [sequence labelAtTime:t];
	
	// acquiring scores
	int count = 0;
	for( NSObject* label in labels ) {
		[sequence setLabel:label forTime:t];
		scores[count].score = [self verticalScoreAtTime:t onSequence:sequence];
		scores[count].originalIndex = count;
		++count;
	}
	
	// sorting according to scores
	qsort(scores, [labels count], sizeof(SelectionScoreInfo), scoresComparisonFunction);
	
	// selecting the first beam_size elements
	unsigned int i;
	unsigned int beamSize = _beamSize * [labels count] + 0.5;
	if(beamSize < 2) beamSize = 2;
//	NSLog(@"Using beam size = %d", beamSize);
	
	for(  i=0; i<beamSize; ++i ) {
		indexes[ scores[i].originalIndex ][t] = ACCEPT_LABEL;
//		NSLog(@"pos = %d original pos = %d vertical score = %f", i, scores[i].originalIndex, scores[i].score );
	}
	
	// Finalization
	[sequence setLabel:cur_label forTime:t];
	free(scores);
}

-(void) viterbiForwardWithScores:(ScoreMatrix) scores
					   ancestors:(AncestorMatrix) ancestors 
						sequence:(BBSequence*) sequence 
						  labels:(NSArray*) labels 
					  stopAtSize:(unsigned int) seqSize{
	
	int numLabels = [labels count];
	double bestScore=-DBL_MAX;
	int bestAncestor=-1;
	int i,j,t;
	
	
	/* initialization of data structures */
	LabelsSelection labelsSelection = (LabelsSelection) malloc( sizeof(int*) * numLabels );
	
	for(i=0; i<numLabels; ++i) {
		[sequence setLabel:[labels  objectAtIndex:i] forTime:0];
		scores[i][0] =  [self scoreForTransitionAtTime:0
											onSequence:sequence];
		ancestors[i][0] = -1;

		labelsSelection[i] = (int*) malloc( sizeof(int) * seqSize);
		for( t=0; t<seqSize; ++t) {
			labelsSelection[i][t] = SKIP_LABEL;
		}
	}
	
	[self selectLabels:labels withHeuristic:nil storeInto:labelsSelection onSequence: sequence atTime:0];
		 
	/* Evaluation of best label sequence */
	for(t=1; t<seqSize; ++t) {
		[self selectLabels:labels withHeuristic:nil storeInto:labelsSelection onSequence: sequence atTime:t];

		for(i=0; i<numLabels; ++i) {
			bestAncestor = -1;
			bestScore=-DBL_MAX;

			scores[i][t] = bestScore;
			ancestors[i][t] = bestAncestor;

			if( labelsSelection[i][t] == SKIP_LABEL )
				continue;
			

			
			[sequence setLabel:[labels objectAtIndex:i] forTime:t];			
			for(j=0; j<numLabels; ++j) {				
				if( labelsSelection[j][t-1] == SKIP_LABEL )
					continue;

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
		
		[[NSNotificationCenter defaultCenter] postNotificationName:BBViterbiClassifierAnalyzedEventAtTimeNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:t]
																							   forKey:@"time"]];
	}
	
	
	// Thrashing the thrashable
	for(i=0; i<numLabels; ++i) {
		free( labelsSelection[i] );
	}
	
	free(labelsSelection);
}


@end
