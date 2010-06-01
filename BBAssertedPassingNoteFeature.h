//
//  BBAssertedPassingNoteFeature.h
//  SeqLearning
//
//  Created by nadia senatore on 27/05/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBFeature.h>


@interface BBAssertedPassingNoteFeature : BBFeature {

}
-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t;

@end
