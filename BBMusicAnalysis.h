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
//  BBMusicAnalysis.h
//  SeqLearning
//
//  Created by radicion on 7/20/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBAssertedAddedNoteFeature.h>
#import <SeqLearning/BBChordRootAssertedInTheNextEventFeature.h>
#import <SeqLearning/BBAssertedRootNoteFeature.h>
#import <SeqLearning/BBChordChangeOnMetricalPatternFeature.h>
#import <SeqLearning/BBChordDistanceFeature.h>
#import <SeqLearning/BBRootFinderPredictionsFeature.h>
#import <SeqLearning/BBLabelFeature.h>
#import <SeqLearning/BBAssertedNotesOfChordFeature.h>
#import <SeqLearning/BBCompletelyStatedChordFeature.h>

@class BBSequence;


typedef struct {
	int pitch_classes[4];
	int chord_size;
} ChordPitchClasses;


extern unsigned int majorModePitchClasses[];
extern unsigned int minorModePitchClasses[];

extern NSString* BBMusicAnalysisNotesAttributeNames[12];
extern NSString* BBMusicAnalysisMetricRelevanceAttributeName;
extern NSString* BBMusicAnalysisRootFinderPredictionAttributeNames[5];
extern NSString* BBMusicAnalysisBassAttributeName;
extern NSString* BBMusicAnalysisLabelAttributeName;

extern NSString* BBMajMode;
extern NSString* BBMinMode;
extern NSString* BBDimMode;

extern NSString* BBMusicAnalysisInternalException;

int BBChordNameToPitchClass(NSString* chordName);
int BBNoteNameToPitchClass(NSString* noteName);
int BBAddedNoteToPitchClass(unsigned int root_pitch, NSString* addedNote);
unsigned int* BBScalePitchClassesForChord(NSString*);

NSString* BBChordNameToMode(NSString* chordName);
NSString* BBChordNameToAddedNote(NSString* chordName);
int BBChordNameToAddedNotePitchClass(NSString* chordName, int root_pitch);
unsigned int BBNumberOfChordNotesAssertedInEvent(NSString* target_label, BBSequence* sequence, unsigned int t);

BOOL BBAreChordsParallelTones(NSString* chord1, NSString* chord2);
BOOL BBMusicAnalysisPitchIsPresent(BBSequence*, unsigned int, unsigned int p);
NSString* BBMusicAnalysisValueForAttributeAtTime(BBSequence*, unsigned int time, NSString* attributeName);
int BBMusicAnalysisBassPitchAtTime(BBSequence* sequence, unsigned int t);

ChordPitchClasses BBMusicAnalysisChordNameToChordPitchClasses(NSString* chord);