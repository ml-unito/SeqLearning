//
//  BBPitchClassDurationFeature.h
//  SeqLearning
//
//  Created by nadia senatore on 09/06/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBFeature.h>

extern NSString* BBPitchClassDurationFeaturePitchClass;
extern NSString* BBPitchClassDurationFeatureNumRepetitions;


@interface BBPitchClassDurationFeature : BBFeature {

}

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t;
@end
