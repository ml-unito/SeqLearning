//
//  BBRepetitionsOfThirdDegreeFeature.m
//  SeqLearning
//
//  Created by nadia senatore on 22/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BBRepetitionsOfThirdDegreeFeature.h"
#import "BBMusicAnalysisWithAbsValues.h"
#import <SeqLearning/BBExceptions.h>


NSString* BBRepetitionsOfThirdDegreeFeatureKeyNum = @"Number";

@implementation BBRepetitionsOfThirdDegreeFeature


-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* target_label = [sequence labelAtTime:t];
	
	NSString* mode = BBChordNameToMode(target_label);
	
	int root_pitch = BBChordNameToPitchClass(target_label);
	
	int third_pitch;
	
	if( mode  == BBMajMode ) {
		
		third_pitch = (root_pitch+4)%12;
	} else if( mode == BBMinMode || mode == BBDimMode ) {
		third_pitch = (root_pitch+3)%12;
	} else {
		@throw [NSException exceptionWithName:BBGenericError 
									   reason:@"mode is not M,m, or d"
									 userInfo:nil];
	}
	
	int num_repetitions = [[_parameters objectForKey:BBRepetitionsOfThirdDegreeFeatureKeyNum] intValue];
	int third_rep_in_event = BBMusicAnalysisPitchCountAV(sequence, t, third_pitch);
	
	if( num_repetitions < 3  )
		return num_repetitions == third_rep_in_event;
	else
		return num_repetitions >= num_repetitions;
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}


@end

