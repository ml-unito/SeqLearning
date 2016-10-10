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
//  BBTextRecognitionFeatureManager.m
//  SeqLearning
//
//  Created by Roberto Esposito on 16/7/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBTextRecognitionFeatureManager.h"
#import <SeqLearning/BBFeature.h>
#import <SeqLearning/BBTextRecognitionFeature.h>
#import <SeqLearning/BBTextRecognitionHorizontalFeature.h>


@implementation BBTextRecognitionFeatureManager

-(NSMutableArray*) arrayWithFeaturesUsingLabelSet:(NSSet*) labelSet {	
	BBFeature* feature;
	NSMutableArray* featureSet;
	
	featureSet = [NSMutableArray arrayWithCapacity:100];
	
	/* --- Vertical features ---
	   The input file contains 16 features each one having 16 possible values.
	   Vertical features simply code the 16 values as a boolean vector of length
	   16 (the vector contains all zero except in a single place, the position
	   of the non zero value specifies the value of the feature).
	   We end up with 16 times 16 features, each one of them is paired with
	   each possible label.
	   In the following:
		fId -> feature position in the source dataset
		fNum -> feature value in the source dataset
		ch -> ranges over the possible labels
		*/
	
	int fId, fNum;
	char ch;
	unsigned int lastCategory=0;
	
	for(fId=1; fId<=16; ++fId ) {
		for(fNum=0; fNum<16; ++fNum ) {
			for(ch='A'; ch<='Z'; ++ch) {
				feature = [[[BBTextRecognitionFeature alloc] init] autorelease];
				[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
					[NSString stringWithFormat:@"f%d", fId], BBTextRecognitionFeatureIdKey,
					[NSNumber numberWithInt:fNum], BBTextRecognitionFeatureNumberKey,
					[NSString stringWithFormat:@"%c",ch], BBTextRecognitionFeatureLabelKey,
					nil]];
				[featureSet addObject:feature];
				[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
												   forKey:feature];		
			}
			
			feature = [[[BBTextRecognitionFeature alloc] init] autorelease];
			[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat:@"f%d", fId], BBTextRecognitionFeatureIdKey,
				[NSNumber numberWithInt:fNum], BBTextRecognitionFeatureNumberKey,
				@"_", BBTextRecognitionFeatureLabelKey,
				nil]];
			[featureSet addObject:feature];
			[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
											   forKey:feature];		
		}
	}
	
	/* --- Horizontal features --- 
		All possible pairs (label,label) are codified.
		*/
	
	char ch1;
	char ch2;
	for(ch1='A'; ch1<='Z'; ++ch1) {
		for(ch2='A'; ch2<='Z'; ++ch2) {
			feature = [[[BBTextRecognitionHorizontalFeature alloc] init] autorelease];
			[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
				[NSString stringWithFormat:@"%c", ch1], BBTextRecognitionPreviousLabelKey,
				[NSString stringWithFormat:@"%c", ch2], BBTextRecognitionCurrLabelKey,
				nil]];
			[featureSet addObject:feature];
			[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
											   forKey:feature];
		}
		feature = [[[BBTextRecognitionHorizontalFeature alloc] init] autorelease];
		[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
			[NSString stringWithFormat:@"%c", ch1], BBTextRecognitionPreviousLabelKey,
			[NSString stringWithFormat:@"%c", '_'], BBTextRecognitionCurrLabelKey,
			nil]];
		[featureSet addObject:feature];
		[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
										   forKey:feature];
	}
	
	for(ch2='A'; ch2<='Z'; ++ch2) {
		feature = [[[BBTextRecognitionHorizontalFeature alloc] init] autorelease];
		[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
			[NSString stringWithFormat:@"%c", '_'], BBTextRecognitionPreviousLabelKey,
			[NSString stringWithFormat:@"%c", ch2], BBTextRecognitionCurrLabelKey,
			nil]];
		[featureSet addObject:feature];
		[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
										   forKey:feature];
	}
	
	
	
	return featureSet;
}



@end
