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
//  BBAssertedRootNoteFeature.m
//  SeqLearning
//
//  Created by radicion on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBAssertedRootNoteFeature.h>
#import <SeqLearning/BBMusicAnalysis.h>


@implementation BBAssertedRootNoteFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* target_label = [sequence labelAtTime:t];
	
	@try {
		NSString* noteName = BBMusicAnalysisNotesAttributeNames[BBChordNameToPitchClass(target_label)];
		return [[sequence valueOfAttributeAtTime: t named:noteName] isEqualToString:@"YES"]; 
	} @catch (NSException* exception) {
		return NO;
	}
	
	return NO;
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}


@end
