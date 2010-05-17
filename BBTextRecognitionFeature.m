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
//  BBTextRecognitionFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 16/7/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBTextRecognitionFeature.h"
NSString* BBTextRecognitionFeatureIdKey = @"Id";
NSString* BBTextRecognitionFeatureNumberKey = @"Number";
NSString* BBTextRecognitionFeatureLabelKey = @"Label";


@implementation BBTextRecognitionFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t{
	NSString* cur_label = [sequence labelAtTime:t];
	NSString* attributeName = [_parameters objectForKey:BBTextRecognitionFeatureIdKey];
	NSNumber* targetValue = [_parameters objectForKey:BBTextRecognitionFeatureNumberKey];
	
	return [targetValue isEqualTo:[sequence valueOfAttributeAtTime:t named:attributeName]]
		&& [cur_label isEqualToString:[_parameters objectForKey:BBTextRecognitionFeatureLabelKey]];
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}

@end
