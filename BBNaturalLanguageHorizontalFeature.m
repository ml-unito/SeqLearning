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
//  BBNaturalLanguageHorizontalFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 2/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBNaturalLanguageHorizontalFeature.h"

NSString* BBNaturalLanguageHorizontalFeatureKeyPrevLabel = @"PrevLabel";
NSString* BBNaturalLanguageHorizontalFeatureKeyCurrLabel = @"CurrLabel";

@implementation BBNaturalLanguageHorizontalFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	if( t==0 )
		return NO;
	
	NSString* prevLabel = [_parameters objectForKey:BBNaturalLanguageHorizontalFeatureKeyPrevLabel];
	NSString* currLabel = [_parameters objectForKey:BBNaturalLanguageHorizontalFeatureKeyCurrLabel];
	
	return 
		[[sequence labelAtTime:t-1] isEqualToString:prevLabel] &&
		[[sequence labelAtTime:t] isEqualToString:currLabel];
			

}


@end
