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
//  BBMcCallumHorizontalFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 7/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBMcCallumHorizontalFeature.h"

NSString* BBMcCallumFeatureKeyPrevLabel = @"PrevLabel";

@implementation BBMcCallumHorizontalFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	if(t==0)
		return NO;
	
	int featurePos = [[_parameters objectForKey:BBMcCallumFeatureKeyNumber] intValue];
	NSString* targetLabel = [_parameters objectForKey:BBMcCallumFeatureKeyCurrLabel];
	NSString* prevousLabel = [_parameters objectForKey:BBMcCallumFeatureKeyPrevLabel];
	
	return [[sequence valueOfAttributeAtTime:t
								 andPosition:featurePos] intValue]==1 &&
		[[sequence labelAtTime:t] isEqualToString:targetLabel] &&
		[[sequence labelAtTime:t-1] isEqualToString:prevousLabel];
	
}

@end
