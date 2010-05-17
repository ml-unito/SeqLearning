//
//  BBBassIsAddedNoteFeature.h
//  SeqLearning
//
//  Created by Roberto Esposito on 3/3/09.
//  Copyright 2009 University of Turin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBFeature.h>


@interface BBBassIsAddedNoteFeature : BBFeature {
	
}

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t;


@end
