//
//  BBAssertedPassingNoteNextEventFeature.m
//  SeqLearning
//
//  Created by nadia senatore on 29/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BBAssertedPassingNoteNextEventFeature.h"
#import "BBMusicAnalysisWithAbsValues.h"

@implementation BBAssertedPassingNoteNextEventFeature

/*
 Feature che restituisce TRUE se non è uno dei gradi dell'accordo y, ma è una nota vicina (congiunta) che è 
 presente nell'evento precedente o  nel successivo.
 z ∈ notes[yt] ∧ z ∉ notes[xt] ∧ (grado_cong(z) ∩ notes[xt] ≠ 0) ∧ z ∈ notes[xt-1] ∪ notes[xt+1]
 */

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	
	if(t==[sequence length]-1) return FALSE;
	
	NSString* target_label = [sequence labelAtTime:t];
	int root_pitch = BBChordNameToPitchClass(target_label);
	int degrees[] = { BBChordNameToPitchClass(target_label),
		(root_pitch+4)%12,
		(root_pitch+7)%12,
		BBMusicAnalysisAddedAtTimeAV(sequence, t) };
	
	int num_degrees = degrees[3] != -1 ? 4 : 3;
	
	int i=0;
	for( ; i<num_degrees; ++i ) {
		if(!BBMusicAnalysisPitchIsPresent(sequence, t, degrees[i]) && 
		    BBMusicAnalysisPitchIsPresent(sequence, t+1, degrees[i]) &&
		    BBMusicAnalysisClosePitchIsPresentAV(sequence, t, degrees[i]))
			return TRUE;
	}
	
	
	return FALSE;
}





@end
