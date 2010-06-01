//
//  BBRepetitionsOfAddedNoteFeature.m
//  SeqLearning
//
//  Created by nadia senatore on 25/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BBRepetitionsOfAddedNoteFeature.h"
#import "BBMusicAnalysisWithAbsValues.h"
#import <SeqLearning/BBExceptions.h>

NSString* BBRepetitionsOfAddedNoteFeatureKeyNum = @"Number";

@implementation BBRepetitionsOfAddedNoteFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* target_label = [sequence labelAtTime:t];
	NSString* addedNote = BBChordNameToAddedNote(target_label);
	int num_repetitions = [[_parameters objectForKey:BBRepetitionsOfAddedNoteFeatureKeyNum] intValue];
	int notePitch = -1;
	int relatedNotePitch = -1;

	
	int root_pitch = BBChordNameToPitchClass(target_label);
	
	if( [addedNote isEqualToString:@""] )	return FALSE;
	if( [addedNote isEqualToString:@"7"])	notePitch = (root_pitch+10)%12;
	if( [addedNote isEqualToString:@"6"])	notePitch = (root_pitch+9)%12;
	if( [addedNote isEqualToString:@"4"]){	notePitch = (root_pitch+5)%12;relatedNotePitch = (root_pitch+4)%12; }
	
	if( notePitch == -1 ) return FALSE;
	
	int found_repetitions = BBMusicAnalysisPitchCountAV(sequence, t, notePitch);
	BOOL result = found_repetitions == num_repetitions;
	if( relatedNotePitch == -1 ) {
		return result;
	} else {
		return result && !BBMusicAnalysisPitchIsPresent(sequence, t, relatedNotePitch);
	}
}

@end