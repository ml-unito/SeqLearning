#import "BBMusicAnalysis.h"
#import <SeqLearning/BBExceptions.h>
#import "BBMusicAnalysisWithPitches.h"
#import "BBMusicAnalysisWithAbsValues.h"

#define min(x,y) (x) < (y) ? (x) : (y)


NSString* BBMusicAnalysisNotesAttributeNames[12]=
{@"C",@"C#",@"D",@"D#",@"E",@"F",@"F#",@"G",@"G#",@"A",@"A#",@"B"};

NSString* BBMusicAnalysisMetricRelevanceAttributeName = @"Meter";
NSString* BBMusicAnalysisRootFinderPredictionAttributeNames[5] =
{@"RF1", @"RF2", @"RF3", @"RF4", @"RF5"};
NSString* BBMusicAnalysisLabelAttributeName = @"Chord";
NSString* BBMusicAnalysisBassAttributeName = @"Bass";


NSString* BBMusicAnalysisInternalException = @"BBMusicAnalysisInternalException";

NSString* BBMajMode=@"M";
NSString* BBMinMode=@"m";
NSString* BBDimMode=@"d";

#define OLD_FORMAT_LABEL_POS 16
#define NEW_FORMAT_LABEL_POS 25

#define DISPATCH_BY_FORMAT(fun1,fun2) \
	int label_pos = [sequence labelAttributePosition];                                            \
																								  \
	switch (label_pos) {                                                                          \
		case OLD_FORMAT_LABEL_POS:                                                                \
			return fun1;		                                                                  \
		case NEW_FORMAT_LABEL_POS:                                                                \
			return fun2;                                                                          \
		default:                                                                                  \
			[NSException raise:BBGenericError format:@"Wrong input format detected while processing BBNumberOfChordNotesAssertedInEvent; label at position: %d", label_pos]; \
	} \
    return -1;



unsigned int majorModePitchClasses[] = { 0, 2, 4, 5, 7, 9, 11};
unsigned int minorModePitchClasses[] = { 0, 2, 3, 5, 7, 8, 10};

unsigned int* BBScalePitchClassesForChord(NSString* chord) {
	NSString* mode = BBChordNameToMode(chord);
	if(mode==BBMajMode) return majorModePitchClasses;
	if(mode==BBMinMode) return minorModePitchClasses;
	return NULL;
}



int BBNoteNameToPitchClass(NSString* noteName) {
	static int firstCharToPitch[7] ={9,11,0,2,4,5,7}; /* from A to G */
	int rootPitchNumber = firstCharToPitch[[noteName characterAtIndex:0]-'A'];
	
	if( [noteName length]<2 ) {
		return rootPitchNumber;
	}
	
	switch([noteName characterAtIndex:1]){
		case '_':
		 	break;
		case '#':
			++rootPitchNumber; 
			break;
		case 'b':
			--rootPitchNumber; 
			break;
		default: @throw 
			[NSException exceptionWithName:BBGenericError 
									reason: [NSString stringWithFormat:
											 @"Error in the format of label %@. Expected #,b, or _ but ``%c'' found",
											 noteName, [noteName characterAtIndex:1]]
								  userInfo: nil];
	}
	
	return rootPitchNumber;
}

int BBAddedNoteToPitchClass(unsigned int root_pitch, NSString* addedNote) {		
	switch ([addedNote intValue]) {
		case 7:
			return (root_pitch+10)%12;
		case 6:
			return (root_pitch+9)%12;
		case 4:
			return (root_pitch+5)%12;
	}
	
	@throw [NSException exceptionWithName:BBGenericError
								   reason:[NSString stringWithFormat:@"Added note expected, but got %@", addedNote]
								 userInfo:nil];
}


int BBChordNameToPitchClass(NSString* chordName) {
	return BBNoteNameToPitchClass(chordName);
}

NSString* BBChordNameToAddedNote(NSString* chordName) {
	static NSString* seven=@"7";
	static NSString* six=@"6";
	static NSString* four=@"4";
	
	if([chordName length]<4)
		return @"";
	
	switch( [chordName characterAtIndex:3] ) {
		case '7': return seven;
		case '6': return six;
		case '4': return four;
		default: @throw [NSException exceptionWithName:BBMusicAnalysisInternalException
												reason:[NSString stringWithFormat:@"Added note different note in chord %@ is not supported", chordName]
											  userInfo:nil];
	}
}

int BBChordNameToAddedNotePitchClass(NSString* chordName, int root_pitch) {	
	if([chordName length]<4)
		return -1;
	
	switch( [chordName characterAtIndex:3] ) {
		case '7': return (root_pitch+10)%12;
		case '6': return (root_pitch+9)%12;
		case '4': return (root_pitch+4)%12;
		default: @throw [NSException exceptionWithName:BBMusicAnalysisInternalException
												reason:[NSString stringWithFormat:@"Added note different note in chord %@ is not supported", chordName]
											  userInfo:nil];
	}
}


NSString* BBChordNameToMode(NSString* chordName) {
	if( [chordName length]<3 ) {
		@throw [NSException exceptionWithName:BBGenericError
									   reason:[NSString stringWithFormat:
											   @"chord ``%@'' is too short (3 characters at least were expected)",
											   chordName]
									 userInfo: nil];
	}
	
	
	switch([chordName characterAtIndex:2]) {
		case 'M': return BBMajMode;
		case 'm': return BBMinMode;
		case 'd': return BBDimMode;
		case 'h': return BBDimMode;
		default: @throw 
			[NSException exceptionWithName:BBGenericError 
									reason: [NSString stringWithFormat:
											 @"Error in the format of label %@. Expected M,m, or d but ``%c'' found",
											 chordName, [chordName characterAtIndex:2]]
								  userInfo: nil];
	}
}

BOOL BBAreChordsParallelTones(NSString* chord1, NSString* chord2) {
	NSString* mode1=BBChordNameToMode(chord1);
	NSString* mode2=BBChordNameToMode(chord2);
	
	if( mode1 == BBDimMode || mode2 == BBDimMode || mode1 == mode2 ) {
		return NO;
	}
	
	int maj_pitch = (mode1 == BBMajMode ? BBChordNameToPitchClass(chord1) : BBChordNameToPitchClass(chord2) );
	int min_pitch = (mode1 == BBMinMode ? BBChordNameToPitchClass(chord1) : BBChordNameToPitchClass(chord2) );
	
	return maj_pitch == (min_pitch+3)%12;	
}

NSString* BBMusicAnalysisValueForAttributeAtTime(BBSequence* sequence, unsigned int t, NSString* attributeName) {
	return [sequence valueOfAttributeAtTime:t named:attributeName];	
}


unsigned int BBNumberOfChordNotesAssertedInEvent(NSString* target_label, BBSequence* sequence, unsigned int t) {
	DISPATCH_BY_FORMAT(BBNumberOfChordNotesAssertedInEventWP(target_label, sequence, t), 
					   BBNumberOfChordNotesAssertedInEventAV(target_label, sequence, t));
	
}


BOOL BBMusicAnalysisPitchIsPresent(BBSequence* sequence, unsigned int t, unsigned int pitch) {
	DISPATCH_BY_FORMAT(BBMusicAnalysisPitchIsPresentWP( sequence, t, pitch ),
					   BBMusicAnalysisPitchIsPresentAV(sequence, t, pitch));
}


int BBMusicAnalysisBassPitchAtTime(BBSequence* sequence, unsigned int t) {
	DISPATCH_BY_FORMAT(BBMusicAnalysisBassPitchAtTimeWP(sequence, t),
					   BBMusicAnalysisBassPitchAtTimeAV(sequence, t));
}


unsigned int BBMusicAnalysisPitchClassDistance(unsigned int x, unsigned int y) {
    int diff = x > y ? x - y  : y - x;
	return min( 12 - diff, diff );
}


ChordPitchClasses BBMusicAnalysisChordNameToChordPitchClasses(NSString* chord) {
	int root_pitch = BBChordNameToPitchClass(chord);

	ChordPitchClasses result;
	result.pitch_classes[0] = root_pitch;
	result.pitch_classes[1] = (root_pitch+4)%12;
	result.pitch_classes[2] = (root_pitch+7)%12;
	result.pitch_classes[3] = BBChordNameToAddedNotePitchClass(chord, root_pitch);
	result.chord_size = (result.pitch_classes[3] == -1 ? 4 : 3);
	
	return result;
}

