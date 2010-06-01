//
//  BBMusicAnalysisWithAbsFeaturesManager.m
//  SeqLearning
//
//  Created by Roberto Esposito on 21/5/10.
//  Copyright 2010 University of Turin. All rights reserved.
//

#import "BBMusicAnalysisWithAbsFeaturesManager.h"
#import "BBFeature.h"

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
#import <SeqLearning/BBRepetitionsOfRootNoteFeature.h>
#import <SeqLearning/BBRepetitionsOfThirdDegreeFeature.h>
#import <SeqLearning/BBRepetitionsOfFifthDegreeFeature.h>
#import <SeqLearning/BBRepetitionsOfAddedNoteFeature.h>
#import <SeqLearning/BBAssertedPassingNoteNextEventFeature.h>


@implementation BBMusicAnalysisWithAbsFeaturesManager

-(NSMutableArray*) initFeaturesUsingLabelSet:(NSSet*) labelSet {
	BBFeature* feature;
	NSMutableArray* featureSet;
	unsigned int lastCategory=0;
	
	featureSet = [NSMutableArray arrayWithCapacity:100];
	
	
	// asserted passing note in next event
	[featureSet addObject:[[[BBAssertedPassingNoteNextEventFeature alloc] init] autorelease]];
	[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory++]
									   forKey:[featureSet lastObject]];
	
	
	// asserted root note & third & fifth degree
	int i;
	for(i=0; i<4; ++i) {
		feature= [[[BBRepetitionsOfRootNoteFeature alloc] init] autorelease];
		[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInt:i],BBRepetitionsOfRootNoteFeatureKeyNum, nil]]; 
		[featureSet addObject:feature];		
		[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
										   forKey:feature]; 
	}	
	lastCategory++;
	
	for(i=0; i<4; ++i) {
		feature= [[[BBRepetitionsOfThirdDegreeFeature alloc] init] autorelease];
		[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInt:i],BBRepetitionsOfThirdDegreeFeatureKeyNum, nil]]; 
		[featureSet addObject:feature];
		[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
										   forKey:feature]; 
	}
	lastCategory++;
	
	
	for(i=0; i<4; ++i) {
		feature= [[[BBRepetitionsOfFifthDegreeFeature alloc] init] autorelease];
		[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInt:i],BBRepetitionsOfFifthDegreeFeatureKeyNum, nil]]; 
		[featureSet addObject:feature];
		[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
										   forKey:feature]; 
	}
	lastCategory++;
	
	for(i=0; i<4; ++i) {
		feature= [[[BBRepetitionsOfAddedNoteFeature alloc] init] autorelease];
		[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithInt:i],BBRepetitionsOfAddedNoteFeatureKeyNum, nil]]; 
		[featureSet addObject:feature];
		[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
										   forKey:feature]; 
	}
	lastCategory++;
	
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
