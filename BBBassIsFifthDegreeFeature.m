//
//  BBBassIsFifthDegreeFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 3/3/09.
//  Copyright 2009 University of Turin. All rights reserved.
//

#import "BBBassIsFifthDegreeFeature.h"
#import <SeqLearning/BBMusicAnalysis.h>


@implementation BBBassIsFifthDegreeFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* target_label = [sequence labelAtTime:t];
	
	unsigned int root_pitch = BBChordNameToPitchClass(target_label);
	
	unsigned int bass_pitch = BBNoteNameToPitchClass([sequence valueOfAttributeAtTime:t named:BBMusicAnalysisBassAttributeName]);
	
	return (root_pitch+7)%12 == bass_pitch;	
}


-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}


@end
