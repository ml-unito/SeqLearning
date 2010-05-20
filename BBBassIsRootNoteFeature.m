//
//  BBBassIsRootNote.m
//  SeqLearning
//
//  Created by Roberto Esposito on 3/3/09.
//  Copyright 2009 University of Turin. All rights reserved.
//

#import "BBBassIsRootNoteFeature.h"
#import <SeqLearning/BBMusicAnalysis.h>


@implementation BBBassIsRootNoteFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* target_label = [sequence labelAtTime:t];
	unsigned int root_pitch = BBChordNameToPitchClass(target_label);
	
	//NSString* bass_note = [sequence valueOfAttributeAtTime:t named:BBMusicAnalysisBassAttributeName];
	NSString* bass_note = BBMusicAnalysisValueForAttributeAtTime(sequence, t, BBMusicAnalysisBassAttributeName);
	
	return root_pitch == BBNoteNameToPitchClass(bass_note);
}

						   
-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}
	
@end
