#import "BBMusicAnalysis.h"
#import "BBMusicAnalysisWithPitches.h"

int BBChordNameToPitchClass(NSString* chordName) {
	return BBChordNameToPitchClassWP(chordName);
}

int BBNoteNameToPitchClass(NSString* noteName) {
	return BBNoteNameToPitchClassWP(noteName);
}

int BBAddedNoteToPitchClass(unsigned int root_pitch, NSString* addedNote) {
	return BBAddedNoteToPitchClassWP(root_pitch, addedNote);
}

NSString* BBChordNameToMode(NSString* chordName) {
	return BBChordNameToModeWP(chordName);
}

NSString* BBChordNameToAddedNote(NSString* chordName) {
	return BBChordNameToAddedNoteWP(chordName);
}

unsigned int BBNumberOfChordNotesAssertedInEvent(NSString* target_label, BBSequence* sequence, unsigned int t) {
	return BBNumberOfChordNotesAssertedInEventWP(target_label, sequence, t);
}

BOOL BBAreChordsParallelTones(NSString* chord1, NSString* chord2) {
	return BBAreChordsParallelTonesWP( chord1, chord2 );
}

BOOL BBMusicAnalysisPitchIsPresent(BBSequence* sequence, unsigned int t, unsigned int pitch) {
	return BBMusicAnalysisPitchIsPresentWP( sequence, t, pitch );
}

NSString* BBMusicAnalysisValueForAttributeAtTime(BBSequence* sequence, unsigned int t, NSString* attributeName) {
	return BBMusicAnalysisValueForAttributeAtTimeWP(sequence, t, attributeName);
}



