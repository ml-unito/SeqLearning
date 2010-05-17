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
//  BBTextRecognitionHorizontalFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 17/7/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBTextRecognitionHorizontalFeature.h"

NSString* BBTextRecognitionPreviousLabelKey = @"PrevLabel";
NSString* BBTextRecognitionCurrLabelKey = @"CurrLabel";



@implementation BBTextRecognitionHorizontalFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t{
	if( t==0 )
		return FALSE;
	
	NSString* curr_label = [sequence labelAtTime:t];
	NSString* prev_label = [sequence labelAtTime:t-1];
	NSString* target_current  = [_parameters objectForKey:BBTextRecognitionCurrLabelKey];
	NSString* target_previous = [_parameters objectForKey:BBTextRecognitionPreviousLabelKey];
	
	return	[curr_label isEqualToString:target_current] &&
			[prev_label isEqualToString:target_previous];
}

-(unsigned int) orderOfMarkovianAssumption {
	return 1;
}


@end
