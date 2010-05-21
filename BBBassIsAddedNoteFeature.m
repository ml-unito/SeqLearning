//
//  BBBassIsAddedNoteFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 3/3/09.
//  Copyright 2009 University of Turin. All rights reserved.
//

#import "BBBassIsAddedNoteFeature.h"
#import <SeqLearning/BBMusicAnalysis.h>


@implementation BBBassIsAddedNoteFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* target_label = [sequence labelAtTime:t];
	NSString* added_note = BBChordNameToAddedNote(target_label);
	
	if( [added_note isEqualToString:@""] ) {
		return FALSE;
	}
	
	unsigned int added_note_pitch = BBAddedNoteToPitchClass(BBChordNameToPitchClass(target_label), 
															added_note);

	//	[sequence valueOfAttributeAtTime:t named:BBMusicAnalysisBassAttributeName];
	return BBMusicAnalysisBassPitchAtTime(sequence, t) == added_note_pitch;
}


-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}

@end
