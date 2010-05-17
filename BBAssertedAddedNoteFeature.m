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
//  BBAssertedAddedNoteFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 2/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBAssertedAddedNoteFeature.h"
#import "BBMusicAnalysis.h"

@implementation BBAssertedAddedNoteFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* label = [sequence labelAtTime:t];
	NSString* addedNote = BBChordNameToAddedNote(label);
	BOOL foundAddedNoteInData = FALSE;
	
	int rootPitchClass = BBChordNameToPitchClass( label );

	NSString* noteName = BBMusicAnalysisNotesAttributeNames[(rootPitchClass+10)%12];
	if([[sequence valueOfAttributeAtTime: t named:noteName] isEqual:@"YES"]) {
		if( [addedNote isEqualToString:@"7"] )
			return YES;
		foundAddedNoteInData = TRUE;
	}
	
	noteName = BBMusicAnalysisNotesAttributeNames[(rootPitchClass+9)%12];
	if([[sequence valueOfAttributeAtTime: t named:noteName] isEqual:@"YES"]) {
		if( [addedNote isEqualToString:@"6"] )
			return YES;
		foundAddedNoteInData = TRUE;
	}

	noteName = BBMusicAnalysisNotesAttributeNames[(rootPitchClass+5)%12];
	NSString* relatedNoteName = BBMusicAnalysisNotesAttributeNames[(rootPitchClass+4)%12];
	if([[sequence valueOfAttributeAtTime: t named:noteName] isEqual:@"YES"]
	   && [[sequence valueOfAttributeAtTime: t named:relatedNoteName] isEqual:@"NO"] ) {
		if( [addedNote isEqualToString:@"4"] )
			return YES;
		foundAddedNoteInData = TRUE;
	}

	// we found one of the added note in the current event, BUT not the
	// corresponding added note is in the label.
	if( foundAddedNoteInData )
		return FALSE;		
	
	// we did not find any added note AND the current label does not require	
	// it. The current event supports the current label.
	if( [addedNote isEqualToString:@""] )
		return TRUE;
 
	// current label REQUIRES the added not, but we did not find any.
	return FALSE;
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}


@end
