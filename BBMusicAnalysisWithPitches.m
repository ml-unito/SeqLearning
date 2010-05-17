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

NSString* BBMusicAnalysisNotesAttributeNames[12]=
	{@"C",@"C#",@"D",@"D#",@"E",@"F",@"F#",@"G",@"G#",@"A",@"A#",@"B"};

NSString* BBMusicAnalysisMetricRelevanceAttributeName = @"Meter";
NSString* BBMusicAnalysisRootFinderPredictionAttributeNames[5] =
	{@"RF1", @"RF2", @"RF3", @"RF4", @"RF5"};
NSString* BBMusicAnalysisLabelAttributeName = @"Chord";
NSString* BBMusicAnalysisBassAttributeName = @"Bass";


NSString* BBMusicAnalysisInternalException = @"BBMusicAnalysisInternalException";

NSString* BBMajMode=@"M";
NSString* BBMinMode=@"m";
NSString* BBDimMode=@"d";


int BBNoteNameToPitchClassWP(NSString* noteName) {
	static int firstCharToPitch[7] ={9,11,0,2,4,5,7}; /* from A to G */
	int rootPitchNumber = firstCharToPitch[[noteName characterAtIndex:0]-'A'];
	
	if( [noteName length]<2 ) {
		return rootPitchNumber;
	}
	
	switch([noteName characterAtIndex:1]){
		case '_':
		 	break;
		case '#':
			++rootPitchNumber; 
			break;
		case 'b':
			--rootPitchNumber; 
			break;
		default: @throw 
			[NSException exceptionWithName:BBGenericError 
									reason: [NSString stringWithFormat:
											 @"Error in the format of label %@. Expected #,b, or _ but ``%c'' found",
											 noteName, [noteName characterAtIndex:1]]
								  userInfo: nil];
	}
	
	return rootPitchNumber;
}

int BBAddedNoteToPitchClassWP(unsigned int root_pitch, NSString* addedNote) {		
	switch ([addedNote intValue]) {
		case 7:
			return (root_pitch+10)%12;
		case 6:
			return (root_pitch+9)%12;
		case 4:
			return (root_pitch+5)%12;
	}
	
	@throw [NSException exceptionWithName:BBGenericError
								   reason:[NSString stringWithFormat:@"Added note expected, but got %@", addedNote]
								 userInfo:nil];
}


int BBChordNameToPitchClassWP(NSString* chordName) {
	return BBNoteNameToPitchClass(chordName);
}

NSString* BBChordNameToAddedNoteWP(NSString* chordName) {
	static NSString* seven=@"7";
	static NSString* six=@"6";
	static NSString* four=@"4";
	
	if([chordName length]<4)
		return @"";
	
	switch( [chordName characterAtIndex:3] ) {
		case '7': return seven;
		case '6': return six;
		case '4': return four;
		default: @throw [NSException exceptionWithName:BBMusicAnalysisInternalException
												reason:[NSString stringWithFormat:@"Added note different note in chord %@ is not supported", chordName]
											  userInfo:nil];
	}
}

NSString* BBChordNameToModeWP(NSString* chordName) {
	if( [chordName length]<3 ) {
		@throw [NSException exceptionWithName:BBGenericError
									   reason:[NSString stringWithFormat:
												@"chord ``%@'' is too short (3 characters at least were expected)",
												chordName]
									 userInfo: nil];
	}

	
	switch([chordName characterAtIndex:2]) {
		case 'M': return BBMajMode;
		case 'm': return BBMinMode;
		case 'd': return BBDimMode;
		case 'h': return BBDimMode;
		default: @throw 
			[NSException exceptionWithName:BBGenericError 
									reason: [NSString stringWithFormat:
											 @"Error in the format of label %@. Expected M,m, or d but ``%c'' found",
											 chordName, [chordName characterAtIndex:2]]
							userInfo: nil];
	}
}


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


BOOL BBAreChordsParallelTonesWP(NSString* chord1, NSString* chord2) {
	NSString* mode1=BBChordNameToMode(chord1);
	NSString* mode2=BBChordNameToMode(chord2);
	
	if( mode1 == BBDimMode || mode2 == BBDimMode || mode1 == mode2 ) {
		return NO;
	}
	
	int maj_pitch = (mode1 == BBMajMode ? BBChordNameToPitchClass(chord1) : BBChordNameToPitchClass(chord2) );
	int min_pitch = (mode1 == BBMinMode ? BBChordNameToPitchClass(chord1) : BBChordNameToPitchClass(chord2) );
	
	return maj_pitch == (min_pitch+3)%12;	
}

BOOL BBMusicAnalysisPitchIsPresentWP(BBSequence* sequence, unsigned int t, unsigned int pitch) {
	NSString* noteName = BBMusicAnalysisNotesAttributeNames[pitch];
	return [[sequence valueOfAttributeAtTime: t named:noteName] isEqualToSt1ring:@"YES"]; 
//
//	
//	return BBMusicAnalysisPitchIsPresentWP( s, p );
}


