//
//  BBTFBSPredictionAAPosFeature.h
//  SeqLearning
//
//  Created by Roberto Esposito on 22/12/08.
//  Copyright 2008 University of Turin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBFeature.h>

extern NSString* BBTFBSPredictionAAPosFeatureAAKey;
extern NSString* BBTFBSPredictionAAPosFeatureAPosKey;
extern NSString* BBTFBSPredictionAAPosFeatureNuclKey;
extern NSString* BBTFBSPredictionAAPosFeatureNPosKey;

@interface BBTFBSPredictionAAPosFeature : BBFeature {
	unsigned int num_aa_attributes;
}

-(id) initWithNumAAAttributes:(unsigned int) num;

@end
