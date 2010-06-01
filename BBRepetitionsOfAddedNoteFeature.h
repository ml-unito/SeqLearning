//
//  BBRepetitionsOfAddedNoteFeature.h
//  SeqLearning
//
//  Created by nadia senatore on 25/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBFeature.h>

extern NSString* BBRepetitionsOfAddedNoteFeatureKeyNum;


@interface BBRepetitionsOfAddedNoteFeature : BBFeature {

}

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t;

@end
