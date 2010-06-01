//
//  BBRepetitionsOfRootNoteFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 21/5/10.
//  Copyright 2010 University of Turin. All rights reserved.
//

#import "BBRepetitionsOfRootNoteFeature.h"
#import "BBMusicAnalysisWithAbsValues.h"


NSString* BBRepetitionsOfRootNoteFeatureKeyNum = @"Number";

@implementation BBRepetitionsOfRootNoteFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* target_label = [sequence labelAtTime:t];
	
	int root_pitch = BBChordNameToPitchClass(target_label);
	int num_repetitions = [[_parameters objectForKey:BBRepetitionsOfRootNoteFeatureKeyNum] intValue];
	int root_rep_in_event = BBMusicAnalysisPitchCountAV(sequence, t, root_pitch);
	
	if( num_repetitions < 3  )
		return num_repetitions == root_rep_in_event;
	else
		return num_repetitions <= root_rep_in_event;
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}

@end
