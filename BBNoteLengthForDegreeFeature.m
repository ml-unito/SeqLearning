//
//  BBNoteLengthForDegreeFeature.m
//  SeqLearning
//
//  Created by nadia senatore on 08/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BBNoteLengthForDegreeFeature.h"

NSString* BBNoteLengthForDegreeFeatureKeyNum = @"Number";
NSString* BBNoteLengthForDegreeFeatureDegreeNum = @"Number";


@implementation BBNoteLengthForDegreeFeature

//bisogna fare il controllo sulla dimensione del vettore di note

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	
	//int rank = [[_parameters objectForKey:BBNoteLengthForDegreeFeatureKeyNum] intValue];
//	int degree = [[_parameters objectForKey:BBNoteLengthForDegreeFeatureDegreeNum] intValue];
	NSString* target_label = [sequence labelAtTime:t];
	ChordPitchClasses degrees = BBMusicAnalysisChordNameToChordPitchClasses(target_label);
	NSMutableArray *anArray = [[NSMutableArray alloc] init];
	NSArray *temp = [[NSArray alloc] init];
	RankPitchClasses elem;

	for(int i=0;i<ChordPitchClasses.size;i++){
		int time_span = BBMusicAnalysisPitchTimeSpanAV(sequence, t, degrees.pitch_classes[i]);
		if(time_span != 0)[anArray addObject:elem(degrees.pitch_classes,time_span)];
	}
	//array ordinato 
	NSArray *sortedArray = [anArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare://confronto i time_span)];
	//ogni indice+1 del vettore ordinato sortedArray corrisponde al rank di ogni pitch class
	

}

@end
