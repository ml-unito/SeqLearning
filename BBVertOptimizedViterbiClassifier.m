//
//  BBVertOptimizedViterbiClassifier.m
//  SeqLearning
//
//  Created by Roberto Esposito on 16/12/08.
//  Copyright 2008 University of Turin. All rights reserved.
//

#import <SeqLearning/BBVertOptimizedViterbiClassifier.h>
#import <SeqLearning/BBFeature.h>
#import <SeqLearning/BBExceptions.h>

@implementation BBVertOptimizedViterbiClassifier

-(void) setVertHorizParams {	
	int features_count = [_features count];

	NSMutableArray* verticalFeatures   = [[NSMutableArray alloc] initWithCapacity:features_count];
	NSMutableArray* horizontalFeatures = [[NSMutableArray alloc] initWithCapacity:features_count];
	NSMutableArray* verticalWeights    = [[NSMutableArray alloc] initWithCapacity:features_count];
	NSMutableArray* horizontalWeights  = [[NSMutableArray alloc] initWithCapacity:features_count];
	
	int i;
	for( i=0; i<features_count; ++i) {
		BBFeature* feature = [_features objectAtIndex:i];
		int markov_order = [feature orderOfMarkovianAssumption];
		switch (markov_order) {
			case 0:
				[verticalFeatures addObject: feature];
				[verticalWeights  addObject: [_weights objectAtIndex:i]];
				break;
			case 1:				
				[horizontalFeatures addObject: feature];
				[horizontalWeights  addObject: [_weights objectAtIndex:i]];
				break;
			default:
				[verticalFeatures release];
				[horizontalFeatures release];
				[verticalWeights release];
				[horizontalWeights release];
				
				@throw [NSException exceptionWithName:BBGenericError reason:@"Markov order not in {0,1}" userInfo:nil];
		}		
	}
	
	[_verticalFeatures release];
	[_horizontalFeatures release];
	[_verticalWeights release];
	[_horizontalWeights release];
	
	_verticalFeatures = verticalFeatures;
	_horizontalFeatures = horizontalFeatures;	
	_verticalWeights = verticalWeights;
	_horizontalWeights = horizontalWeights;
}

-(void) setWeights:(NSMutableArray*) weights {	
	[super setWeights:weights];
	if( _features!=nil && [_features count] == [weights count] )
		[self setVertHorizParams];
}

-(void) setFeatures:(NSArray*) features {
	[super setFeatures:features];
	if( _weights!=nil && [features count] == [_weights count] )
		[self setVertHorizParams];
}

-(void) updateVertWeightsCacheForSequence: (BBSequence*) sequence andTime:(unsigned int) t {
	_currentLabel = [sequence labelAtTime:t];
	_currentT = t;
	_currentVerticalWeight = 0;
	
	int i;
	int feature_count = [_verticalFeatures count];
	for( i=0; i<feature_count; ++i ) {
		BBFeature* feature = [_verticalFeatures objectAtIndex:i];
		if([feature evalOnSequence:sequence forTime:t])
			_currentVerticalWeight += [[_verticalWeights objectAtIndex:i] doubleValue];
	}
}

-(double) scoreForTransitionAtTime:(unsigned int) t onSequence:(BBSequence*) sequence{
	if( t!=_currentT || ![_currentLabel isEqualToString: [sequence labelAtTime: t]] ) {
		[self updateVertWeightsCacheForSequence: sequence 
										andTime: t];
	}
	
	
	double score=0.0;
	int features_count = [_horizontalFeatures count];
	int i;
	double weight;
	for( i=0; i<features_count; ++i ) {
		weight=[[_horizontalWeights objectAtIndex:i] doubleValue];
		// skip_nil_feature NEEDS weight variable, do not move the assignment below!
		skip_nil_feature();
		
		if([[_horizontalFeatures objectAtIndex:i] evalOnSequence:sequence forTime:t]) 
			score+=weight; 
	} 

	return score + _currentVerticalWeight;
}


-(double) unoptimizedScoreForTransitionAtTime:(unsigned int) t onSequence:(BBSequence*) sequence {
	return [super scoreForTransitionAtTime:t onSequence:sequence];
}



-(NSArray*) labelsForSequence:(BBSequence*) sequence {
	_currentLabel = @"__EMPTY LABEL FOR INTERNAL PURPOSES__";
	_currentT = -1;
	return [super labelsForSequence:sequence];
}

@end
