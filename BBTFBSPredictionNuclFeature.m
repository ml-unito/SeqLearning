//
//  BBTFBSPredictionNuclFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 22/12/08.
//  Copyright 2008 University of Turin. All rights reserved.
//

#import "BBTFBSPredictionNuclFeature.h"

NSString* BBTFBSPredictionNuclFeatureNuclKey = @"Nucl";

@implementation BBTFBSPredictionNuclFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t{	
	NSString* curr_label = [sequence labelAtTime:t];
	
	return	[curr_label isEqualToString:[_parameters objectForKey:BBTFBSPredictionNuclFeatureNuclKey]];
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}



@end
