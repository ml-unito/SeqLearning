//
//  BBMusicAnalysisWithAbsValues.h
//  SeqLearning
//
//  Created by Roberto Esposito on 21/5/10.
//  Copyright 2010 University of Turin. All rights reserved.
//

#import "BBMusicAnalysis.h"

int BBMusicAnalysisPitchCountAV(BBSequence* sequence, unsigned int t, unsigned int pitch_class);
unsigned int BBNumberOfChordNotesAssertedInEventAV(NSString* target_label, BBSequence* sequence, unsigned int t);
BOOL BBMusicAnalysisPitchIsPresentAV(BBSequence* sequence, unsigned int t, unsigned int pitch);
int BBMusicAnalysisBassPitchAtTimeAV(BBSequence* sequence, unsigned int t);