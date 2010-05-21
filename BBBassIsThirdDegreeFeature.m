//
//  BBBassIsThirdDegreeFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 3/3/09.
//  Copyright 2009 University of Turin. All rights reserved.
//

#import <SeqLearning/BBBassIsThirdDegreeFeature.h>
#import <SeqLearning/BBExceptions.h>

@implementation BBBassIsThirdDegreeFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* target_label = [sequence labelAtTime:t];
	
	NSString* mode = BBChordNameToMode(target_label);
	unsigned int root_pitch = BBChordNameToPitchClass(target_label);
	
	unsigned int bass_pitch = BBNoteNameToPitchClass(BBMusicAnalysisValueForAttributeAtTime(sequence, t, BBMusicAnalysisBassAttributeName));
	
	if( mode  == BBMajMode ) {
		return (root_pitch+4)%12 == bass_pitch;
	} else if( mode == BBMinMode || mode == BBDimMode ) {
		return (root_pitch+3)%12 == bass_pitch;
	} else {
		@throw [NSException exceptionWithName:BBGenericError 
									   reason:@"mode is not M,m, or d"
									 userInfo:nil];
	}
	
	// never reached
	return FALSE;
}



-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}

@end
