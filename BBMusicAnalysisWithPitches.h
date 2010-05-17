#import "BBMusicAnalysis.h"

int BBChordNameToPitchClassWP(NSString* chordName);
int BBNoteNameToPitchClassWP(NSString* noteName);
int BBAddedNoteToPitchClassWP(unsigned int root_pitch, NSString* addedNote);

NSString* BBChordNameToModeWP(NSString* chordName);
NSString* BBChordNameToAddedNoteWP(NSString* chordName);
unsigned int BBNumberOfChordNotesAssertedInEventWP(NSString* target_label, BBSequence* sequence, unsigned int t);

BOOL BBAreChordsParallelTonesWP(NSString* chord1, NSString* chord2);
BOOL BBMusicAnalysisPitchIsPresentWP(BBSequence* sequence, unsigned int t, unsigned int pitch);
NSString* BBMusicAnalysisValueForAttributeAtTimeWP(BBSequence* sequence, unsigned int t, NSString* attributeName);