//
//  BBAssertedPassingNoteFeature.m
//  SeqLearning
//
//  Created by nadia senatore on 27/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BBAssertedPassingNoteFeature.h"
#import "BBMusicAnalysisWithAbsValues.h"

#define AV_START_INDEX 3
#define AV_END_INDEX 21


@implementation BBAssertedPassingNoteFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* target_label = [sequence labelAtTime:t];
	int root_pitch = BBChordNameToPitchClass(target_label);
	int third_pitch = (root_pitch+4)%12;
	int fifth_pitch = (root_pitch+7)%12;
	int added_pitch = -1;
	BOOL result = FALSE;
	NSString* addedNote = BBChordNameToAddedNote(target_label);
	
	//se non siamo in uno di questi casi allora  
	if( [addedNote isEqualToString:@""] );
	if( [addedNote isEqualToString:@"7"])	added_pitch = (root_pitch+10)%12;
	if( [addedNote isEqualToString:@"6"])	added_pitch = (root_pitch+9)%12;
	if( [addedNote isEqualToString:@"4"])	added_pitch = (root_pitch+4)%12;

	int av_p; // iterates over notes in the current event
	for(av_p=AV_START_INDEX; av_p<=AV_END_INDEX; av_p+=2) {
		int curr_av = [[sequence valueOfAttributeAtTime:t andPosition:av_p] intValue] % 12;
		if(curr_av==0) break;
		
		
		if( curr_av == root_pitch || curr_av == third_pitch || curr_av == fifth_pitch || curr_av == added_pitch);
		
		else{
			//occorre andare a vedere nella posizione av_p se vi è la nota appartenente all'accordo
			int last_av = [[sequence valueOfAttributeAtTime:t-1 andPosition:av_p] intValue];
			int next_av = [[sequence valueOfAttributeAtTime:t+1 andPosition:av_p] intValue];
			unsigned int distance = curr_av - last_av;
			if (distance == 1 || distance == 2){
				last_av = last_av%12;
				if(last_av == root_pitch || last_av == third_pitch || last_av == fifth_pitch || last_av == added_pitch)
					result = TRUE;
			}
			distance = curr_av - next_av;
			if (!result && (distance == 1 || distance == 2)){
				next_av = next_av % 12;
				if(next_av == root_pitch || next_av == third_pitch || next_av == fifth_pitch || next_av == added_pitch)
					result = TRUE;
			}
			
			

			
			
			
		}
		
	}

/*
 Feature che restituisce TRUE se non è uno dei gradi dell'accordo y, ma è una nota vicina (congiunta) che è 
 presente nell'evento precedente o  nel successivo.
 z ∈ notes[yt] ∧ z ∉ notes[xt] ∧ (grado_cong(z) ∩ notes[xt] ≠ 0) ∧ z ∈ notes[xt-1] ∪ notes[xt+1]
 */
			return result;
}


@end
