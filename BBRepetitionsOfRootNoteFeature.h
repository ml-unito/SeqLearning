//
//  BBRepetitionsOfRootNoteFeature.h
//  SeqLearning
//
//  Created by Roberto Esposito on 21/5/10.
//  Copyright 2010 University of Turin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBFeature.h>

extern NSString* BBRepetitionsOfRootNoteFeatureKeyNum;

@interface BBRepetitionsOfRootNoteFeature : BBFeature {

}

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t;


@end
