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
//  BBWeightsEvaluator.m
//  SeqLearning
//
//  Created by Roberto Esposito on 3/7/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SeqLearning/BBWeightsEvaluator.h"
#import "SeqLearning/BBFeature.h"
#import "SeqLearning/BBViterbiClassifier.h"
#import "SeqLearning/BBExceptions.h"


@implementation BBWeightsEvaluator



-(id) initWithSequence:(BBSequence*) s 
		  vertFeatures:(NSArray*) vFeat 
		 horizFeatures:(NSArray*) hFeat 
		   vertWeights:(NSArray*) vW 
		  horizWeights:(NSArray*) hW {
	
	if( (self=[super init]) ) {
		_sequence = [s retain];
		
		_verticalFeatures = [vFeat retain];
		_horizontalFeatures = [hFeat retain];
		_verticalWeights = [vW retain];
		_horizontalWeights = [hW retain];		
		_maxTransWeight = [self computeMaxTransWeight];
		_sumMaxVertWeights = [self computeMaxVerticals];
		
	}
	
	return self;
}


-(void) dealloc {
	[_sequence release];
	[_verticalFeatures release];
	[_horizontalFeatures release];
	[_verticalWeights release];
	[_horizontalWeights release];
	[_featuresManager release];
	free(_sumMaxVertWeights);
	[super dealloc];
}



+(BBWeightsEvaluator*) evaluatorForSequence:(BBSequence*) s 
							   vertFeatures:(NSArray*) vFeat 
							  horizFeatures:(NSArray*) hFeat 
								vertWeights:(NSArray*) vW 
							   horizWeights:(NSArray*) hW {
	return [[[BBWeightsEvaluator alloc] initWithSequence:s 
											vertFeatures:vFeat 
										   horizFeatures:hFeat
											 vertWeights:vW
											horizWeights:hW] autorelease];
}

//-(double) computeMaxVerticals {
//	double result = 0;
//	
//	for(NSNumber* weight in _verticalWeights) {
//		double d_weight = [weight doubleValue];
//		if( d_weight > 0)
//			result += d_weight;
//	}
//	
//	return result;
//}

-(double) maxVertWeightAtTime:(int) t {
	double max = [self vertWeightForLabel:[[_sequence labels] objectAtIndex:0] atTime:t];
	for( NSObject* label in [_sequence labels] ) {
		double val = [self vertWeightForLabel:label atTime:t];
		if(max<val)
			max = val;
	}
	
	return max;
}


-(double*) computeMaxVerticals {
	double* result = calloc(sizeof(double), [_sequence length]);
	int t = [_sequence length]-1;
	result[t] =	0;
	
	for( t=t-1; t>=0; --t ) {
		double tmp_result = [self maxVertWeightAtTime:t+1] + result[t+1];
		result[t] = tmp_result > 0 ? tmp_result : 0;
	}
	
	return result;
}

-(double) computeMaxTransWeight {
	NSMutableDictionary* mapper = [NSMutableDictionary dictionaryWithCapacity:100];
	BBFeaturesManager* featuresManager = [self featuresManager];
	if(!featuresManager) {
		@throw [NSException exceptionWithName:BBGenericError 
									   reason:@"Internal Error (this is a bug!) Features Manager not set!" 
									 userInfo:nil];
	}
	
	NSDictionary* featuresToCategory = [featuresManager featuresToMutexCategoryMapper];
	
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

-(double) vertWeightForLabel:(NSObject*) label atTime:(int) t {
	[_sequence setLabel: label forTime: t];
	return [self scoreForSequence:_sequence 
						   atTime:t
					usingFeatures:_verticalFeatures
					   andWeights:_verticalWeights];
}

-(double) horizWeightFromLabel:(NSObject*) label1 toLabel:(NSObject*) label2 atTime:(int) t {
	[_sequence setLabel:label1 forTime:t-1];
	[_sequence setLabel:label2 forTime:t];
	
	return [self scoreForSequence:_sequence 
						   atTime:t
					usingFeatures:_horizontalFeatures
					   andWeights:_horizontalWeights];
}



-(int) sequenceLength {
	return [_sequence length];
}


-(NSArray*) labels {
	return  [(NSSet*) [[_sequence labelDescription] info] allObjects];
}


-(double) maxHorizWeightFromTime:(int) t {
	return ([_sequence length]-1 - t) * _maxTransWeight;
}


-(double) maxVertWeightFromTime:(int) t {
	return _sumMaxVertWeights[t];
}

-(BBFeaturesManager*) featuresManager {
	return _featuresManager;
}

-(void) setFeaturesManager: (BBFeaturesManager*) featuresManager {
	[_featuresManager autorelease];
	_featuresManager = featuresManager;
}


@end
