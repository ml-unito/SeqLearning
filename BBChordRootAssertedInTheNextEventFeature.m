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
//  BBChordRootAssertedInTheNextEventFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 4/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBChordRootAssertedInTheNextEventFeature.h"
#import "BBMusicAnalysis.h"


@implementation BBChordRootAssertedInTheNextEventFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	if( t>[sequence length]-2 )
		return NO;
	
	NSString* target_label = [sequence labelAtTime:t];
	NSString* rootNoteName = BBMusicAnalysisNotesAttributeNames[BBChordNameToPitchClass(target_label)];
	
	// If the root note is already stated in the current chord, we are not interested in investigating
	// following chord.
	
	if([[sequence valueOfAttributeAtTime: t named:rootNoteName] isEqualToString:@"YES"])
		return NO;
	
	if( BBNumberOfChordNotesAssertedInEvent(target_label,sequence,t)<2 )
		return NO;
	
	if( BBNumberOfChordNotesAssertedInEvent(target_label,sequence,t+1)<2 )
		return NO;
	
	if([[sequence valueOfAttributeAtTime: t+1 named:rootNoteName] isEqualToString:@"YES"])
		return YES;
	
	return NO;	
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}


@end
