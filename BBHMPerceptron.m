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
//  BBHMPerceptron.m
//  SeqLearning
//
//  Created by Roberto Esposito on 21/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBHMPerceptron.h>
#import <SeqLearning/BBViterbiClassifier.h>
#import <SeqLearning/BBCarpeDiemClassifier.h>
#import <SeqLearning/BBFeature.h>
#import <SeqLearning/BBMutableDouble.h>


NSString* BBHMPerceptronFinishedIterationNotification = @"BBHMPerceptronFinishedIterationNotification";
NSString* BBHMPerceptronFinishedSequenceNotification = @"BBHMPerceptronFinishedSequenceNotification";
NSString* BBHMPerceptronStartedSequenceNotification = @"BBHMPerceptronStartedSequenceNotification";
NSString* BBHMPerceptronNumberOfIterationsOption = @"Number of Iterations";
NSString* BBHMPerceptronViterbiClassifierClassOption = @"Viterbi Classifier";
NSString* BBHMPerceptronUseAveragingParametersOption = @"Use Averaging Parameters";
NSString* BBHMPerceptronViterbiBeamSizeOption = @"Beam size (if applicable)";
NSString* BBHMPerceptronErrorEvaluatorClassOption = @"Error evaluator class name";

#define SAVE_DEBUG_DATA 0

#if SAVE_DEBUG_DATA
// TO BE DELETED
static int tot_chances_for_update = 0;
static int num_sequence = 0;
static int num_iteration = 0;
int counters[255];
FILE* files[255];
//
#endif

@implementation BBHMPerceptron

-(id) init {
	if( self=[super init] ) {
		[_options setObject: [NSNumber numberWithInt:20] 
					 forKey:BBHMPerceptronNumberOfIterationsOption];
		[_options setObject: @"BBCarpeDiemClassifier"
					 forKey:BBHMPerceptronViterbiClassifierClassOption];
		[_options setObject: @"YES"
					 forKey:BBHMPerceptronUseAveragingParametersOption];
		[_options setObject: [NSNumber numberWithDouble:0.2]
					 forKey: BBHMPerceptronViterbiBeamSizeOption];
		[_options setObject: @"BBErrorEvaluator" forKey:BBHMPerceptronErrorEvaluatorClassOption];
	}
	
	return self;
}


-(NSString*) fileNameForFeature:(BBFeature*) feature {
	static int feature_no = 0;
	NSDictionary* parameters = [feature parameters];
	NSEnumerator* keys = [parameters keyEnumerator];
	NSString* key;

	NSMutableString* featureDes = [NSMutableString stringWithString:@"/Users/esposito/tmp/experiments/data/"]; 
	[featureDes appendString:[feature className]];
	while( key = [keys nextObject] ) {
		if( [parameters objectForKey:key] == nil )
			[featureDes appendFormat:@"_%@_", key];			
		else
			[featureDes appendFormat:@"_%@_%@", key, [parameters objectForKey:key]];
	}
	
	[featureDes appendFormat:@"_%d", ++feature_no];
	return featureDes;
}


-(void) incrementAssertedFeaturesOnSequence:(BBSequence*) sequence andTime:(unsigned int) t by:(int) incr {
	int feature_count=[_features count];
	int i;
	for(i=0; i<feature_count; ++i) {
		@try {	 
			if( [(BBFeature*)[_features objectAtIndex:i] evalOnSequence:sequence forTime:t] ) {
				[[_weights objectAtIndex:i] setDouble:[[_weights objectAtIndex:i] doubleValue]+incr];
				
#if SAVE_DEBUG_DATA
//				// TO BE DELETED
				counters[i]++;
				fprintf(files[i],
					"%d %d %d %d %d\n",
					tot_chances_for_update, 
					counters[i],
					num_sequence, 
					num_iteration,
						(int) [[_weights objectAtIndex:i] doubleValue]);
				//
#endif
			}
		} @catch (NSException* exception) {
			@throw [NSException exceptionWithName:[exception name]
										   reason:[NSString stringWithFormat:@"Error analyzing testing feature number:%d at time:%d reason:%@", 
											   i, t, [exception reason]]
										 userInfo:[exception userInfo]];
		}
	}
}

-(void) trainClassifier:(BBViterbiClassifier*) classifier 
			 onSequence:(BBSequence*) sequence
		 targetLabeling:(NSArray*) sequence_labels {

	NSArray* predicted_labels = [classifier labelsForSequence:sequence];
	
		
	int T=[sequence length];
	int t;
	for(t=0; t<T; ++t) {
		@try {
#if SAVE_DEBUG_DATA			
			// TO BE DELETED
			++tot_chances_for_update;
			//
#endif
			if([_errorEvaluator prediction: [predicted_labels objectAtIndex:t]
							   differsFrom: [sequence_labels  objectAtIndex:t]]) {
//			if(![[predicted_labels objectAtIndex:t] isEqual:[sequence_labels objectAtIndex:t]]) {
				// **** wrong classification ***
				// first we decrement each feature asserted for the incorrect label
				[sequence setLabel:[predicted_labels objectAtIndex:t] forTime:t];
				[self incrementAssertedFeaturesOnSequence: sequence andTime:t by:-1];
				
				// then we restore the correct label
				[sequence clearLabelAtTime: t];
				// and increment each feature asserted for the correct label
				[self incrementAssertedFeaturesOnSequence: sequence andTime:t by:1];
			}
			
		} @catch (id exception) {
			// Debugger();
			NSLog(@"Exception catched during -trainClassifier, reason:%@", [exception reason]);
			@throw;
		}
	}
	
}

-(void) copyWeightsIntoVector:(double*) vector {
	int i;
	int weights_count = [_weights count];
	for(i=0; i<weights_count; ++i) {
		vector[i] = [[_weights objectAtIndex:i] doubleValue];
	}	
}

-(void) updateWeightsAccordingToWeightsHistory:(double**) weightsHistory 
								 numIterations:(int) num_iterations {
	int i,n;
	int weights_count = [_weights count];
	for(i=0; i<weights_count; ++i) {
		double cur_average = 0;
		for(n=0; n<num_iterations; ++n) {
			cur_average+=weightsHistory[n][i];
		}
		[[_weights objectAtIndex:i] setDouble:cur_average/num_iterations];
	}
}

-(NSObject<BBSequenceClassifying>*) learn:(BBSeqSet*) ss {
	NSAssert( _features!=nil,
			  @"Cannot learn without using any feature" );
	
#if SAVE_DEBUG_DATA
	// TO BE DELETED
	int f;
	for(f=0; f<[_features count]; ++f) {
		counters[f]=0;
		
		files[f] = fopen( [[self fileNameForFeature:[_features objectAtIndex:f]] cString], "w" );
		if( files[f]==NULL ) {
			NSAssert(FALSE, @"should not be reached!");
			@throw [NSException exceptionWithName:@"FileOpenError" 
										   reason:[NSString stringWithFormat:@"Cannot open file named:%@", [_features objectAtIndex:f]]
										 userInfo:nil];			
		}
		else {
			fprintf(files[f],"# tot_potential_updates tot_updates seq_num iteration weight\n0 0 0 0 0\n");
		}
			
	}
	//
#endif
	int num_repetitions = 
		[[[self options] objectForKey:BBHMPerceptronNumberOfIterationsOption] intValue];
	BOOL useAveragingParameters = 
		[[[self options] objectForKey:BBHMPerceptronUseAveragingParametersOption] isEqualToString:@"YES"];
	
	double** weightsHistory;
	if( useAveragingParameters ) 
		weightsHistory = (double**) calloc( num_repetitions, sizeof(double*) );
	
	unsigned int features_count = [_features count];
	_weights = [NSMutableArray arrayWithCapacity:features_count];
	
	int i;
	for(i=0; i<features_count; ++i) {
		[_weights addObject:[BBMutableDouble numberWithDouble:0.0]];
	}
	
	
	Class errorEvaluatorClass = NSClassFromString([_options objectForKey:BBHMPerceptronErrorEvaluatorClassOption]);
	_errorEvaluator = [[[errorEvaluatorClass alloc] init] autorelease];
	
	Class classifierClass = NSClassFromString([_options objectForKey:BBHMPerceptronViterbiClassifierClassOption]);
	BBViterbiClassifier* classifier = [[[classifierClass alloc] init] autorelease];
	if( [classifier respondsToSelector: @selector(setBeamSizeUsingNSNumber:)] ) {
		[classifier performSelector:@selector(setBeamSize:) withObject:[_options objectForKey:BBHMPerceptronViterbiBeamSizeOption] ];
	}
	
	[classifier setFeaturesManager:_featuresManager];
	[classifier setFeatures:_features];	
	[classifier setWeights:_weights];

	
	_correct_labels = [[NSMutableArray alloc] initWithCapacity:[ss count]];
	int seq_num;
	for(seq_num=0; seq_num<[ss count]; ++seq_num) {
		[_correct_labels addObject:[[ss sequenceNumber:seq_num] labels]];
	}
	
	
	int num;
	for(num=0; num<num_repetitions; ++num) {		
#if SAVE_DEBUG_DATA
		// TO BE DELETED
		num_iteration = num;
		//
#endif
		
		NSEnumerator* sequenceEnumerator = [ss sequenceEnumerator];
		BBSequence* sequence;
		seq_num=0;
		while( sequence=[sequenceEnumerator nextObject] ) {
#if SAVE_DEBUG_DATA
			// TO BE DELETED
			num_sequence = seq_num;
			//
#endif
			NSAutoreleasePool* autoreleasePool = [[NSAutoreleasePool alloc] init];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:BBHMPerceptronStartedSequenceNotification
																object:self
															  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																		[NSNumber numberWithInt:seq_num+1],@"number",
																		classifier, @"classifier",
																		NULL]];
			
			@try {			
				[self trainClassifier:classifier 
						   onSequence:sequence
					   targetLabeling:[_correct_labels objectAtIndex:seq_num]];				
			} @catch (NSException* exception) {
				if(useAveragingParameters) {
					// thrashing partially allocated vectors
					int i;
					for(i=0; i<num; ++i) {
						free(weightsHistory[i]);
					}
					free(weightsHistory);					
				}
				
				// rethrowing the exception
				@throw [NSException exceptionWithName:[exception name]
											   reason:[NSString stringWithFormat:@"Error analyzing sequence number %d, reason:%@", 
												   seq_num, [exception reason]]
											 userInfo:[exception userInfo]];
			}
									
			[[NSNotificationCenter defaultCenter] postNotificationName:BBHMPerceptronFinishedSequenceNotification
																object:self
															  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																		[NSNumber numberWithInt:seq_num+1],@"number",
																		classifier, @"classifier",
																		NULL]];
			[autoreleasePool release];
			++seq_num;
		}
		
		// storing actual contents of the weights vector
		if(useAveragingParameters) {
			weightsHistory[num] = (double*) malloc( sizeof(double) * [_weights count] );
			[self copyWeightsIntoVector:weightsHistory[num]];							
		}		
		
		[[NSNotificationCenter defaultCenter] postNotificationName:BBHMPerceptronFinishedIterationNotification
															object:self
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	[NSNumber numberWithInt:num+1],@"number",
																	classifier, @"classifier",
																	NULL]];
		
		
	}
	
	if(useAveragingParameters) {
		[self updateWeightsAccordingToWeightsHistory:weightsHistory 
									   numIterations:num_repetitions];
		int i;
		for(i=0; i<num_repetitions; ++i) {
			free(weightsHistory[i]);
		}
		free(weightsHistory);
	}
	
	// cleaning up	
	[_correct_labels release];
	_weights=nil;
	_errorEvaluator = nil;
	
#if SAVE_DEBUG_DATA	
	// TO BE DELETED
	for(f=0; f<[_features count]; ++f) {
		fclose( files[f] );
	}
#endif
	
	
	
	return classifier;
}

-(void) setFeaturesManager:(BBFeaturesManager *)featuresManager {
	[_featuresManager autorelease];
	_featuresManager = [featuresManager retain];
}

-(BBFeaturesManager*) featuresManager {
	return _featuresManager;
}

@end
