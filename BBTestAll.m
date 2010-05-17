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
//  BBTestAll.m
//  SeqLearning
//
//  Created by Roberto Esposito on 14/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBTestAll.h"
#import "BBTestFeature.h"

#import <SeqLearning/BBSequenceReader.h>
#import <SeqLearning/BBNumberReader.h>
#import <SeqLearning/BBNominalValueReader.h>
#import <SeqLearning/BBStringReader.h>
#import <SeqLearning/BBAttributeDescription.h>
#import <SeqLearning/BBViterbiClassifier.h>
#import <SeqLearning/BBExceptions.h>
#import <SeqLearning/BBViterbiBeamSearchClassifier.h>
#import <SeqLearning/BBMusicAnalysis.h>
#import <SeqLearning/BBAssertedRootNoteFeature.h>
#import <SeqLearning/BBRootFinderPredictionsFeature.h>
#import <SeqLearning/BBChordChangeOnMetricalPatternFeature.h>
#import <SeqLearning/BBLabelFeature.h>
#import <SeqLearning/BBAssertedNotesOfChordFeature.h>
#import <SeqLearning/BBChordChangeOnMetricalPatternFeature.h>
#import <SeqLearning/BBLabelFeature.h>
#import <SeqLearning/BBAssertedNotesOfChordFeature.h>
#import <SeqLearning/BBArffFormattedSequenceReader.h>
#import <SeqLearning/BBChordDistanceFeature.h>
#import <SeqLearning/BBMusicAnalysisFeaturesManager.h>

@implementation BBTestAll

- (void) setUp {
    // Create data structures here.

	BBArffFormattedSequenceReader* reader = [[BBArffFormattedSequenceReader alloc] init];

	
	[reader setFileName:@"jsbach1_sec1.arff"]; 
	[reader readAttributesDescriptions];
	[reader setSequenceIdPosition:0];
	[reader setLabelAttributeName:@"Chord"];
	
	_ss = [[reader readSeqSet] retain];

	_fm = [[BBMusicAnalysisFeaturesManager alloc] initWithLabelSet:(NSSet*) [[_ss labelDescription] info]];
	[_fm setAsDefaultManager];
	_hmp= [[BBHMPerceptron alloc] init];
	
	[_hmp setFeatures: [_fm features]];
	[_hmp setOptions:[NSDictionary dictionaryWithObjectsAndKeys:
					 [NSNumber numberWithInt:5], BBHMPerceptronNumberOfIterationsOption,
					 @"BBCarpeDiemClassifier", BBHMPerceptronViterbiClassifierClassOption,
					 nil]];

	[reader release];
	
}



- (void) tearDown {
    // Release data structures here.
	[_hmp release];
	[_ss release];
	[_fm release];
}


-(void) testHMPerceptronLearningAccuracy {
	BBSequence* sequence = [_ss sequenceNumber:0];

	NSObject<BBSequenceClassifying>* classifier = [_hmp learn:_ss];
	[sequence setLabels:(NSMutableArray*) [classifier labelsForSequence:sequence]];
	STAssertEqualsWithAccuracy( [[BBErrorEvaluator evaluator] evaluateErrorUsingLabelledSeqSet: _ss], 0.1, 0.1, nil,nil );	
}

-(void) testVBSClassifier {
	BBSequence* sequence = [_ss sequenceNumber:0];

	BBViterbiClassifier* classifier = (BBViterbiClassifier*) [_hmp learn:_ss];
	BBViterbiBeamSearchClassifier* vbs = [[BBViterbiBeamSearchClassifier alloc] init];
	[vbs setBeamSize:0.5];
	
	[vbs setFeatures:[classifier features]];
	[vbs setWeights:[classifier weights]];
	
	NSArray* resultVBS = [vbs labelsForSequence:sequence];
	NSArray* resultSTD = [classifier labelsForSequence:sequence];

	STAssertEquals( [resultSTD count], [resultVBS count], @"BUG found: classifiers result lenght should be equal!" );

	int count_errors = 0;
	int index;
	for( index=0; index<[resultVBS count]; ++index ) {
		if( ![[resultVBS objectAtIndex:index] isEqualToString:[resultSTD objectAtIndex:index]] )
			count_errors += 1;
	}

//	NSLog(@"count_errors = %d", count_errors );
//	for( index = 0; index < [resultVBS count]; ++index ) {
//		NSLog( @"%@ %@", [resultVBS objectAtIndex:index], [resultSTD objectAtIndex:index] );
//	}
	
	STAssertTrue( (double) count_errors < [resultSTD count] * 0.7, @"Probable BUG found: ViterbiBeamSearch makes too many mistakes" );
}

@end
