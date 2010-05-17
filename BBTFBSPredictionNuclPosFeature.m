//
//  BBTFBSPredictionNuclPosFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 14/7/09.
//  Copyright 2009 University of Turin. All rights reserved.
//

#import "BBTFBSPredictionNuclPosFeature.h"

NSString* BBTFBSPredictionNuclPosFeatureNuclKey = @"Nucl";
NSString* BBTFBSPredictionNuclPosFeaturePosKey = @"Pos";


@implementation BBTFBSPredictionNuclPosFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t{	
	NSString* curr_label = [sequence labelAtTime:t];
	NSNumber* curr_pos =   [sequence valueOfAttributeAtTime:t named:@"position"];
	
	NSString* my_nucl = [_parameters objectForKey:BBTFBSPredictionNuclPosFeatureNuclKey];
	NSNumber* my_pos  = [_parameters objectForKey:BBTFBSPredictionNuclPosFeaturePosKey];
	
	return	[curr_label isEqualToString: my_nucl] && [curr_pos isEqualToNumber:my_pos];
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}


@end
