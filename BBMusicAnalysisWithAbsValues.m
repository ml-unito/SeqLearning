//
//  BBMusicAnalysisWithAbsValues.m
//  SeqLearning
//
//  Created by Roberto Esposito on 21/5/10.
//  Copyright 2010 University of Turin. All rights reserved.
//

#import "BBMusicAnalysisWithAbsValues.h"
#import <SeqLearning/BBExceptions.h>

#define AV_START_INDEX 3
#define AV_END_INDEX 21




unsigned int BBNumberOfChordNotesAssertedInEventAV(NSString* target_label, BBSequence* sequence, unsigned int t) {
	int chordPitchClasses[4] ={-1,-1,-1,-1}; /* belonging to chord in target_label */
	
	
	if( [target_label length]<3 ) {
		@throw [NSException exceptionWithName:BBGenericError
									   reason:[NSString stringWithFormat:
											   @"chord ``%@'' is too short (3 characters at least were expected)",
											   target_label]
									 userInfo: nil];
	}
	
	
	@try {
		chordPitchClasses[0] = BBChordNameToPitchClass(target_label);
	} @catch (NSException* exception) {
		return FALSE;
	}
	
	switch([target_label characterAtIndex:2]){
		case 'M': 
			chordPitchClasses[1] = (chordPitchClasses[0] + 4)%12;
			chordPitchClasses[2] = (chordPitchClasses[0] + 7)%12;
			break;
		case 'm':
			chordPitchClasses[1] = (chordPitchClasses[0] + 3)%12;
			chordPitchClasses[2] = (chordPitchClasses[0] + 7)%12;			
			break;
		case 'd':
		case 'h':
			chordPitchClasses[1] = (chordPitchClasses[0] + 3)%12;
			chordPitchClasses[2] = (chordPitchClasses[0] + 6)%12;			
			break;
			
		default: @throw [NSException exceptionWithName:BBGenericError 
												reason: [NSString stringWithFormat:
														 @"Error in the format of label %@. Expected M,m, or d but ``%c'' found",
														 target_label, [target_label characterAtIndex:2]]
											  userInfo: nil];			
	}
	
	
	if([target_label length]==4) {
		switch([target_label characterAtIndex:3]){
			case '7':
				chordPitchClasses[3] = (chordPitchClasses[0] + 10)%12;
				break;
			case '6':
				chordPitchClasses[3] = (chordPitchClasses[0] + 9)%12;
				break;
			case '4':
				chordPitchClasses[1] = (chordPitchClasses[0] + 5)%12;
				chordPitchClasses[2] = (chordPitchClasses[0] + 7)%12;
				break;
				//			case '9':
				//				break;
			default: @throw [NSException exceptionWithName:BBGenericError 
													reason: [NSString stringWithFormat:
															 @"Error in the format of label %@. Expected 7,6, or 4 but ``%c'' found",
															 target_label, [target_label characterAtIndex:3]]
							 
												  userInfo: nil];			
		}
	}
	
	unsigned int counter=0;
	
	int i; 
	for(i=0;i<4;++i){
		if(chordPitchClasses[i] == -1) continue;
		
		if(BBMusicAnalysisPitchIsPresentAV(sequence, t, chordPitchClasses[i])) {
			counter++;
		}
	}
	
	return counter;
}




BOOL BBMusicAnalysisPitchIsPresentAV(BBSequence* sequence, unsigned int t, unsigned int pitch_class) {
	int av_p; // iterates over notes in the current event
	for(av_p=AV_START_INDEX; av_p<=AV_END_INDEX; av_p+=2) {
		int curr_av = [[sequence valueOfAttributeAtTime:t andPosition:av_p] intValue];
		if(curr_av==0) break;
		
		if( curr_av % 12 == pitch_class )
			return TRUE;
	}
	
	return FALSE;
}


