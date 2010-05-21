#import "BBMusicAnalysis.h"


unsigned int BBNumberOfChordNotesAssertedInEventWP(NSString* target_label, BBSequence* sequence, unsigned int t);

BOOL BBMusicAnalysisPitchIsPresentWP(BBSequence* sequence, unsigned int t, unsigned int pitch);
NSString* BBMusicAnalysisValueForAttributeAtTimeWP(BBSequence* sequence, unsigned int t, NSString* attributeName);
int BBMusicAnalysisBassPitchAtTimeWP(BBSequence* sequence, unsigned int t);