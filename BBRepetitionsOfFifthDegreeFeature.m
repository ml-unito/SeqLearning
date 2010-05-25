//
//  BBRepetitionsOfFifthDegreeFeature.m
//  SeqLearning
//
//  Created by nadia senatore on 22/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BBRepetitionsOfFifthDegreeFeature.h"
#import "BBMusicAnalysisWithAbsValues.h"
#import <SeqLearning/BBExceptions.h>


NSString* BBRepetitionsOfFifthDegreeFeatureKeyNum = @"Number";

@implementation BBRepetitionsOfFifthDegreeFeature


-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* target_label = [sequence labelAtTime:t];
	
	int root_pitch = BBChordNameToPitchClass(target_label);
	
	int fifth_pitch = (root_pitch+7)%12;
	
	int num_repetitions = [[_parameters objectForKey:BBRepetitionsOfFifthDegreeFeatureKeyNum] intValue];
	
	int fifth_rep_in_event = BBMusicAnalysisPitchCountAV(sequence, t, fifth_pitch);
	
	if( num_repetitions < 3  )
		return num_repetitions == fifth_rep_in_event;
	else
		return num_repetitions >= num_repetitions;
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}


@end
