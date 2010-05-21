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
//  BBRootFinderPredictionsFeature.m
//  SeqLearning
//
//  Created by radicion on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBRootFinderPredictionsFeature.h>
#import <SeqLearning/BBMusicAnalysis.h>

NSString* BBRootFinderPredictionsFeatureKeyRFNumber=@"RFNumber";

@implementation BBRootFinderPredictionsFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	int rfNumber = [[_parameters objectForKey:BBRootFinderPredictionsFeatureKeyRFNumber] intValue];
	
	NSObject* rf_label = BBMusicAnalysisValueForAttributeAtTime(sequence, t, BBMusicAnalysisRootFinderPredictionAttributeNames[rfNumber]);
	
	//NSObject* rf_label = [sequence valueOfAttributeAtTime: t named:BBMusicAnalysisRootFinderPredictionAttributeNames[rfNumber]];
	
	NSObject* target_label = [sequence labelAtTime:t];

	return [rf_label isEqual:target_label];
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}


@end




