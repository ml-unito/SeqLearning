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
//  BBAssertedNotesOfChordFeature.m
//  SeqLearning
//
//  Created by radicion on 7/19/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBAssertedNotesOfChordFeature.h>
#import <SeqLearning/BBMusicAnalysis.h>
#import <SeqLearning/BBExceptions.h>

NSString* BBAssertedNotesOfChordFeatureKeyNumber = @"Number";

@implementation BBAssertedNotesOfChordFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	int numberOfAssertedNotes = [[_parameters objectForKey:BBAssertedNotesOfChordFeatureKeyNumber] intValue];
	
	if( numberOfAssertedNotes >= 0 )
		return numberOfAssertedNotes ==	BBNumberOfChordNotesAssertedInEvent([sequence labelAtTime:t],sequence,t);
	else {
		@throw [NSException exceptionWithName:BBGenericError reason:@"Num asserted notes requested is < 0" userInfo:nil];
	}
		//return numberOfAssertedNotes !=	BBNumberOfChordNotesAssertedInEvent([sequence labelAtTime:t],sequence,t);
}


-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}


@end
