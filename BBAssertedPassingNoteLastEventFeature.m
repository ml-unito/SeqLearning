//
//  BBAssertedéassingNoteLastEvent.m
//  SeqLearning
//
//  Created by nadia senatore on 01/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BBAssertedPassingNoteLastEventFeature.h"
#import "BBMusicAnalysisWithAbsValues.h"


@implementation BBAsserted_assingNoteLastEvent


/*
 Feature che restituisce TRUE se non è uno dei gradi dell'accordo y, ma è una nota vicina (congiunta) che è 
 presente nell'evento precedente o  nel successivo.
 z ∈ notes[yt] ∧ z ∉ notes[xt] ∧ (grado_cong(z) ∩ notes[xt] ≠ 0) ∧ z ∈ notes[xt-1] ∪ notes[xt+1]
 */

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	if(t==0) return FALSE;
	
	NSString* target_label = [sequence labelAtTime:t];
	int root_pitch = BBChordNameToPitchClass(target_label);
	int degrees[] = { BBChordNameToPitchClass(target_label),
					  (root_pitch+4)%12,
					  (root_pitch+7)%12,
					  BBMusicAnalysisAddedAtTimeAV(sequence, t) };
	
	int i=0;
	for( ; i<3; ++i ) {
		if(!BBMusicAnalysisPitchIsPresent(sequence, t, degrees[i]) && 
			BBMusicAnalysisClosePitchIsPresentAV(sequence, t-1, degrees[i]) )
			return TRUE;
	}
	

	if(degrees[3]!=-1 && 
	   !BBMusicAnalysisPitchIsPresent(sequence, t, degrees[3]) && 
	   BBMusicAnalysisClosePitchIsPresentAV(sequence, t-1, degrees[3]) )
		return TRUE;
	else
		return FALSE;
}


@end
