//
//  BBAssertedéassingNoteLastEvent.h
//  SeqLearning
//
//  Created by nadia senatore on 01/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBFeature.h>


@interface BBAssertedPassingNoteLastEventFeature : BBFeature {

}

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t;

@end
