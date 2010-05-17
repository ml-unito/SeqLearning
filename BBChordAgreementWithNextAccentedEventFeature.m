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
//  BBChordAgreementWithNextAccentedEventFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 30/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBChordAgreementWithNextAccentedEventFeature.h"


@implementation BBChordAgreementWithNextAccentedEventFeature

//-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
//	int sequenceLenght = [sequence length];
//	if( !(t<sequenceLenght) )
//		return NO;
//
//	NSString* target_label = [sequence labelAtTime:t];
//	int numAssertedNotes = 
//		BBNumberOfChordNotesAssertedInEvent(target_label,sequence,t);
//	
//	NSString* noteName = BBMusicAnalysisNotesAttributeNames[BBChordNameToPitchClass(target_label)];
//	int rootNoteAsserted = [[sequence valueOfAttributeAtTime: t named:noteName] isEqualToString:@"YES"];
//		
//	if( numAssertedNotes>=3 )
//		return NO;
//	
//	if( numAssertedNotes==2 && rootNoteAsserted )
//		return NO;
//
//	int nextAccentedEvent;
//	
//	BOOL found=NO;
//	for( nextAccentedEvent=t; 
//		 nextAccentedEvent<sequenceLenght && !found; 
//		 ++nextAccentedEvent ) {
//		found = [[sequence valueOfAttributeAtTime:nextAccentedEvent
//											named:BBMusicAnalysisMetricRelevanceAttributeName] intValue] >= 3;
//		
//	}
//
//	
//	
//}

@end
