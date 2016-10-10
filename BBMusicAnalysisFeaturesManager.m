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
//  BBMusicAnalysisFeaturesManager.m
//  SeqLearning
//
//  Created by Roberto Esposito on 12/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBMusicAnalysisFeaturesManager.h"

#import <SeqLearning/BBAssertedRootNoteFeature.h>
#import <SeqLearning/BBChordChangeOnMetricalPatternFeature.h>
#import <SeqLearning/BBChordDistanceFeature.h>
#import <SeqLearning/BBRootFinderPredictionsFeature.h>
#import <SeqLearning/BBAssertedNotesOfChordFeature.h>
#import <SeqLearning/BBLabelFeature.h>
#import <SeqLearning/BBHMPerceptron.h>
#import <SeqLearning/BBAssertedAddedNoteFeature.h>
#import <SeqLearning/BBCompletelyStatedChordFeature.h>
#import <SeqLearning/BBChordRootAssertedInTheNextEventFeature.h>
#import <SeqLearning/BBBassIsRootNoteFeature.h>
#import <SeqLearning/BBBassIsThirdDegreeFeature.h>
#import <SeqLearning/BBBassIsFifthDegreeFeature.h>
#import <SeqLearning/BBBassIsAddedNoteFeature.h>


#define USE_NEW_CHORD_TRANSITIONS 0

@implementation BBMusicAnalysisFeaturesManager

-(NSMutableArray*) arrayWithFeaturesUsingLabelSet:(NSSet*) labelSet {    
	BBFeature* feature;
	NSMutableArray* featureSet;
	unsigned int lastCategory=0;
	
	featureSet = [NSMutableArray arrayWithCapacity:100];
	
	// asserted root note
	[featureSet addObject:[[[BBAssertedRootNoteFeature alloc] init] autorelease]];	
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory++]
									   forKey:[featureSet lastObject]]; 
		
	[featureSet addObject:[[[BBAssertedAddedNoteFeature alloc] init] autorelease]];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory++]
								 forKey:[featureSet lastObject]];

	[featureSet addObject:[[[BBCompletelyStatedChordFeature alloc] init] autorelease]];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory++]
								 forKey:[featureSet lastObject]];

	[featureSet addObject:[[[BBChordRootAssertedInTheNextEventFeature alloc] init] autorelease]];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory++]
								 forKey:[featureSet lastObject]];

	
	
	[featureSet addObject:[[[BBBassIsRootNoteFeature alloc] init] autorelease]];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
									   forKey:[featureSet lastObject]];
	
	[featureSet addObject:[[[BBBassIsThirdDegreeFeature alloc] init] autorelease]];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
									   forKey:[featureSet lastObject]];
	
	[featureSet addObject:[[[BBBassIsFifthDegreeFeature alloc] init] autorelease]];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
									   forKey:[featureSet lastObject]];

	[featureSet addObject:[[[BBBassIsAddedNoteFeature alloc] init] autorelease]];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory++]
									   forKey:[featureSet lastObject]];
	
	
	// metrical patterns
	feature= [[[BBChordChangeOnMetricalPatternFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		@"000",BBChordChangeOnMetricalPatternFeatureKeyPattern, nil]]; 
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];

	
	feature= [[[BBChordChangeOnMetricalPatternFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		@"001",BBChordChangeOnMetricalPatternFeatureKeyPattern, nil]]; 
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	feature= [[[BBChordChangeOnMetricalPatternFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		@"010",BBChordChangeOnMetricalPatternFeatureKeyPattern, nil]]; 
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	feature= [[[BBChordChangeOnMetricalPatternFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		@"011",BBChordChangeOnMetricalPatternFeatureKeyPattern, nil]]; 
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	feature= [[[BBChordChangeOnMetricalPatternFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		@"100",BBChordChangeOnMetricalPatternFeatureKeyPattern, nil]]; 
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	feature= [[[BBChordChangeOnMetricalPatternFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		@"101",BBChordChangeOnMetricalPatternFeatureKeyPattern, nil]]; 
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	feature= [[[BBChordChangeOnMetricalPatternFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		@"110",BBChordChangeOnMetricalPatternFeatureKeyPattern, nil]]; 
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	feature= [[[BBChordChangeOnMetricalPatternFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		@"111",BBChordChangeOnMetricalPatternFeatureKeyPattern, nil]]; 
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	++lastCategory;
	

	// M 5 M
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:5], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	// M 7 M
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:7], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	// M 2 M7
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:2], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"7", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
									   forKey:feature];
	
	// m 5 M
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:5], BBChordDistanceFeatureKeyDistance,
		@"m", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
									   forKey:feature];
	
	// M 5 m
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:5], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"m", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
									   forKey:feature];

	// M 2 m
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:2], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"m", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
									   forKey:feature];
	
	// M7 5 m
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:5], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"m", BBChordDistanceFeatureKeyCurrMode,
		@"7", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
									   forKey:feature];

	// M7 5 M
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:5], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"7", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
									   forKey:feature];
	
	
	// M 2 M
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:2], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	
	// M4 0 M7
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:0], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"4", BBChordDistanceFeatureKeyPrevAddedNote,
		@"7", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	
	// m 3 M
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:3], BBChordDistanceFeatureKeyDistance,
		@"m", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	// m 8 M
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:8], BBChordDistanceFeatureKeyDistance,
		@"m", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	// M 7 M7
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:7], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"7", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	// M 9 m
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:9], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"m", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	// m6 2 M
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:2], BBChordDistanceFeatureKeyDistance,
		@"m", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"6", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	// m6 2 M7
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:2], BBChordDistanceFeatureKeyDistance,
		@"m", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"6", BBChordDistanceFeatureKeyPrevAddedNote,
		@"7", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	// M 9 m7
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:9], BBChordDistanceFeatureKeyDistance,
		@"M", BBChordDistanceFeatureKeyPrevMode,
		@"m", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"7", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	// m7 5 M
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:5], BBChordDistanceFeatureKeyDistance,
		@"m", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"7", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	// m7 5 M7
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:5], BBChordDistanceFeatureKeyDistance,
		@"m", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"7", BBChordDistanceFeatureKeyPrevAddedNote,
		@"7", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	// m 5 M7
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:5], BBChordDistanceFeatureKeyDistance,
		@"m", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"7", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	// d 1 M
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:1], BBChordDistanceFeatureKeyDistance,
		@"d", BBChordDistanceFeatureKeyPrevMode,
		@"M", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	// d 1 m
	feature = [[[BBChordDistanceFeature alloc] init] autorelease];
	[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:1], BBChordDistanceFeatureKeyDistance,
		@"d", BBChordDistanceFeatureKeyPrevMode,
		@"m", BBChordDistanceFeatureKeyCurrMode,
		@"", BBChordDistanceFeatureKeyPrevAddedNote,
		@"", BBChordDistanceFeatureKeyCurrAddedNote,
		nil]];
	[featureSet addObject:feature];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
								 forKey:feature];
	
	++lastCategory;	
	
	
	int numNotes;
	for( numNotes=0; numNotes<5; ++numNotes ) {
		feature = [[[BBAssertedNotesOfChordFeature alloc] init] autorelease];
		[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:numNotes], BBAssertedNotesOfChordFeatureKeyNumber,
			nil]];
		[featureSet addObject:feature];
		[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
									 forKey:feature];
	}

	
	return featureSet;
}


@end
