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
//  BBChordDistanceFeature.m
//  SeqLearning
//
//  Created by radicion on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBChordDistanceFeature.h>
#import <SeqLearning/BBMusicAnalysis.h>

NSString* BBChordDistanceFeatureKeyDistance=@"Distance";
NSString* BBChordDistanceFeatureKeyPrevMode=@"PrevMode";
NSString* BBChordDistanceFeatureKeyCurrMode=@"CurrMode";
NSString* BBChordDistanceFeatureKeyPrevAddedNote=@"PrevAddedNote";
NSString* BBChordDistanceFeatureKeyCurrAddedNote=@"CurrAddedNote";



@implementation BBChordDistanceFeature


-(NSString*) parametersAsString {
	return [NSString stringWithFormat:@"%@%@_%@_%@%@", 
		[_parameters objectForKey:BBChordDistanceFeatureKeyPrevMode],
		[_parameters objectForKey:BBChordDistanceFeatureKeyPrevAddedNote],
		[_parameters objectForKey:BBChordDistanceFeatureKeyDistance],
		[_parameters objectForKey:BBChordDistanceFeatureKeyCurrMode],
		[_parameters objectForKey:BBChordDistanceFeatureKeyCurrAddedNote]];
}


-(NSString*) description {
	return [NSString stringWithFormat:@"%@_%@%@_%@_%@%@", 
		[self className],
		[_parameters objectForKey:BBChordDistanceFeatureKeyPrevMode],
		[_parameters objectForKey:BBChordDistanceFeatureKeyPrevAddedNote],
		[_parameters objectForKey:BBChordDistanceFeatureKeyDistance],
		[_parameters objectForKey:BBChordDistanceFeatureKeyCurrMode],
		[_parameters objectForKey:BBChordDistanceFeatureKeyCurrAddedNote]];
}

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	
	if(t == 0 || t == [sequence length]-1)
		return FALSE;
	
	NSString* curr_label = [sequence labelAtTime:t];
	NSString* previous_label = [sequence labelAtTime:t-1];
	
/* swapping for reading sequences backward
	NSString* tmp = curr_label;
	curr_label=previous_label;
	previous_label=tmp; */
	
	NSString* prevMode;
	NSString* currMode;
	NSString* prevAddedNote;
	NSString* currAddedNote;
	
	
	@try {
		prevMode = BBChordNameToMode(previous_label);
		currMode = BBChordNameToMode(curr_label);
		prevAddedNote = BBChordNameToAddedNote(previous_label);
		currAddedNote = BBChordNameToAddedNote(curr_label); 
	} @catch (NSException* exception) {
		return FALSE;
	}
	
	if(![[_parameters objectForKey:BBChordDistanceFeatureKeyPrevMode] isEqualToString:prevMode] ||
	   ![[_parameters objectForKey:BBChordDistanceFeatureKeyCurrMode] isEqualToString:currMode] ||
	   ![[_parameters objectForKey:BBChordDistanceFeatureKeyPrevAddedNote] isEqualToString:prevAddedNote] ||
	   ![[_parameters objectForKey:BBChordDistanceFeatureKeyCurrAddedNote] isEqualToString:currAddedNote] )
	   return FALSE;	
	
	
	int lab1=BBChordNameToPitchClass(curr_label);
	int lab2=BBChordNameToPitchClass(previous_label);

	if([[_parameters objectForKey:BBChordDistanceFeatureKeyDistance] intValue] ==
		(lab1 - lab2+12)%12)
		return TRUE;
		
	return FALSE;
}


@end


@implementation BBNegatedChordDistanceFeature
-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	return ![super evalOnSequence:sequence forTime:t];
}

@end