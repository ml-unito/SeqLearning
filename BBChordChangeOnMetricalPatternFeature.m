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
//  BBChordChangeOnMetricalPatternFeature.m
//  SeqLearning
//
//  Created by radicion on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBChordChangeOnMetricalPatternFeature.h>
#import <SeqLearning/BBMusicAnalysis.h>

NSString* BBChordChangeOnMetricalPatternFeatureKeyPattern = @"Pattern";

@implementation BBChordChangeOnMetricalPatternFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t{
	if(t == 0 || t == [sequence length]-1)
		return FALSE;
	
	NSObject* cur_label = [sequence labelAtTime:t];
	NSObject* previous_label = [sequence labelAtTime:t-1];
	
	if([cur_label isEqual:previous_label])
		return FALSE;

	char metric_pattern[4] = "000";
	
	 /*
	 if ([parseInt(BBMusicAnalysisValueForAttributeAtTime(sequence, t-1, 
	 BBMusicAnalysisMetricRelevanceAttributeName)) intValue] >= 3){
	 metric_pattern[0] = '1';
	 }
	 if ([[parseInt(BBMusicAnalysisValueForAttributeAtTime(sequence, t, 
	 BBMusicAnalysisMetricRelevanceAttributeName)) intValue] >= 3){
	 metric_pattern[1] = '1';
	 }
	 if ([[parseInt(BBMusicAnalysisValueForAttributeAtTime(sequence, t+1, 
	 BBMusicAnalysisMetricRelevanceAttributeName)) intValue] >= 3){
	 metric_pattern[2] = '1';
	 }
	 */
	
	if ([[sequence valueOfAttributeAtTime:t-1 
									named:BBMusicAnalysisMetricRelevanceAttributeName] intValue] >= 3){
		metric_pattern[0] = '1';
	}
	if ([[sequence valueOfAttributeAtTime:t 
									named:BBMusicAnalysisMetricRelevanceAttributeName] intValue] >= 3){
		metric_pattern[1] = '1';
	}
	if ([[sequence valueOfAttributeAtTime:t+1 
									named:BBMusicAnalysisMetricRelevanceAttributeName] intValue] >= 3){
		metric_pattern[2] = '1';
	}
		
	NSString* target_metrical_pattern = 
		[_parameters objectForKey:BBChordChangeOnMetricalPatternFeatureKeyPattern];
	
	int i;
	for( i=0; i<3; ++i ) {
		if(metric_pattern[i]!=[target_metrical_pattern characterAtIndex:i])
			return FALSE;
	}

	return TRUE;	
}



@end
