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
	int number_of_notes_in_chord = ([target_label length] == 4 ? 4 : 3);
	
	
	int completing_pitch = BBMusicAnalysisPitchCompletingChordAV(sequence, t, target_label);
	if( completing_pitch == -1 ) return FALSE;
	
	return BBMusicAnalysisClosePitchIsPresentAV(sequence, t, completing_pitch) &&
	       BBNumberOfChordNotesAssertedInEventAV(target_label, sequence, t+1) == number_of_notes_in_chord;
}





@end
