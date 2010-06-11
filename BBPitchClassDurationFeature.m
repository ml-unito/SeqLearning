//
//  BBPitchClassDurationFeature.m
//  SeqLearning
//
//  Created by nadia senatore on 09/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BBPitchClassDurationFeature.h"
#import "BBMusicAnalysisWithAbsValues.h"


NSString* BBPitchClassDurationFeaturePitchClass = @"PosInScale";
NSString* BBPitchClassDurationFeatureNumRepetitions = @"NumRep";


@implementation BBPitchClassDurationFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	
	NSString* target_label = [sequence labelAtTime:t];
	int root_pitch = BBChordNameToPitchClass(target_label);
	
	int pitch = [[_parameters objectForKey:BBPitchClassDurationFeaturePitchClass] intValue];
	int num_rep = [[_parameters objectForKey:BBPitchClassDurationFeatureNumRepetitions] intValue];
	int res = 0;
	
	unsigned int* modePitchClasses = BBScalePitchClassesForChord(target_label);
	if( modePitchClasses == NULL ) return FALSE;
	
	res = BBMusicAnalysisEventSpanAV(sequence,t,(modePitchClasses[pitch]+root_pitch)%12);
	
	if( num_rep < 4 )
		return num_rep == res;
	else
		return num_rep <= res;
	
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}


@end
