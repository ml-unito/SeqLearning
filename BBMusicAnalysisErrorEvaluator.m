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
//  BBMusicAnalysisErrorEvaluator.m
//  SeqLearningExperimenter
//
//  Created by Roberto Esposito on 16/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBMusicAnalysisErrorEvaluator.h"
#import <SeqLearning/BBMusicAnalysis.h>
#import <SeqLearning/BBMutableDouble.h>


static BOOL bb_music_labels_differ( NSString* predicted, NSString* correct ) {
	int correct_pitch = BBChordNameToPitchClass(correct);
	NSString* correct_mode = BBChordNameToMode(correct);
	NSString* correct_added_note = BBChordNameToAddedNote(correct);
	
	
	int predicted_pitch = BBChordNameToPitchClass(predicted);
	NSString* predicted_mode = BBChordNameToMode(predicted);
	NSString* predicted_added_note = BBChordNameToAddedNote(predicted);
	
	
	return !( correct_pitch==predicted_pitch &&
			 [correct_mode isEqualToString:predicted_mode] &&
			 [correct_added_note isEqualToString:predicted_added_note]);
}


@implementation BBMusicAnalysisErrorEvaluator

-(BOOL) prediction:(NSString*) predicted differsFrom:(NSString*) correct {
	return bb_music_labels_differ(predicted, correct);
}


-(double) evaluateErrorUsingLabelledSeqSet:(BBSeqSet*) ss {
	int error=0;
	int n, predictions_count=0;
	
	int num_errors_on_parallel_tones=0;
	
	NSEnumerator* seq_enumerator = [ss sequenceEnumerator];
	BBSequence* sequence;
	
	NSDictionary* error_meter_distribution = 
	            [NSDictionary dictionaryWithObjectsAndKeys: 
				 [[[BBMutableDouble alloc] init] autorelease], [NSNumber numberWithInt:1],
				 [[[BBMutableDouble alloc] init] autorelease], [NSNumber numberWithInt:2],
				 [[[BBMutableDouble alloc] init] autorelease], [NSNumber numberWithInt:3],
				 [[[BBMutableDouble alloc] init] autorelease], [NSNumber numberWithInt:4],
				 [[[BBMutableDouble alloc] init] autorelease], [NSNumber numberWithInt:5],				
				 nil];
	
	
	while( sequence = [seq_enumerator nextObject] ) {
		int seq_len = [sequence length];
		predictions_count+=seq_len;
		
		for(n=0; n<seq_len; ++n) {
			NSString* correct = [sequence correctLabelAtTime:n];
			NSString* predicted = [sequence labelAtTime:n];
			
			
			if( bb_music_labels_differ(predicted, correct) ) {
				++error;				
				NSLog(@"Error on sequence:%@ at time:%d", [sequence valueOfIdAttribute], n+1);
				int meter = [[sequence valueOfAttributeAtTime:n named:BBMusicAnalysisMetricRelevanceAttributeName] intValue];
				
				double newVal = [(BBMutableDouble*) [error_meter_distribution objectForKey:[NSNumber numberWithInt:meter]] doubleValue]+1;
				[(BBMutableDouble*) [error_meter_distribution objectForKey:[NSNumber numberWithInt:meter]] setDouble:newVal];
				
				if( BBAreChordsParallelTones(predicted, correct) ) {
					num_errors_on_parallel_tones++;
					NSLog(@"Error on parallel tones: %@ %@", predicted, correct);
				}
			}
		}
	}
	
	NSLog(@"%@", error_meter_distribution);
	NSLog(@"errors on parallel tones:%f", ((double) num_errors_on_parallel_tones)/predictions_count);
	
	NSLog(@"%f",((float)error)/((float)predictions_count));
	return ((double)error)/((double)predictions_count);	
}


@end
