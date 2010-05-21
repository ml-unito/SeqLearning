/**********************************************************************
This source file belongs to the seqlearning library: a sequence learning objective-c library.
Copyright (C) 2008  Roberto Esposito

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***********************************************************************/
//
//  BBMusicAnalysis.m
//  SeqLearning
//
//  Created by radicion on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBMusicAnalysisWithPitches.h>
#import <SeqLearning/BBExceptions.h>
#import <SeqLearning/BBSequence.h>




unsigned int BBNumberOfChordNotesAssertedInEventWP(NSString* target_label, BBSequence* sequence, unsigned int t) {
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
		if (chordPitchClasses[i] == -1) 
			continue;
		NSString* noteName = BBMusicAnalysisNotesAttributeNames[chordPitchClasses[i]];
		if([[sequence valueOfAttributeAtTime: t named:noteName] isEqualToString:@"YES"]){
			++counter;
		}
	}
	
	return counter;
}




BOOL BBMusicAnalysisPitchIsPresentWP(BBSequence* sequence, unsigned int t, unsigned int pitch) {
	NSString* noteName = BBMusicAnalysisNotesAttributeNames[pitch];
	return [[sequence valueOfAttributeAtTime: t named:noteName] isEqualToString:@"YES"]; 
}

NSString* BBMusicAnalysisValueForAttributeAtTimeWP(BBSequence* sequence, unsigned int t, NSString* attributeName) {
	return [sequence valueOfAttributeAtTime:t named:attributeName];	
}

