//
//  BBTFBSPredictionNuclChainFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 22/12/08.
//  Copyright 2008 University of Turin. All rights reserved.
//

#import <SeqLearning/BBTFBSPredictionNuclChainFeature.h>

NSString* BBTFBSPredictionNuclChainCurrentNuclKey = @"CurrNucl";
NSString* BBTFBSPredictionNuclChainPrevNuclKey = @"PrevNucl";



@implementation BBTFBSPredictionNuclChainFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t{
	if( t==0 )
		return FALSE;
	
	NSString* curr_label = [sequence labelAtTime:t];
	NSString* prev_label = [sequence labelAtTime:t-1];
	NSString* target_current  = [_parameters objectForKey:BBTFBSPredictionNuclChainCurrentNuclKey];
	NSString* target_previous = [_parameters objectForKey:BBTFBSPredictionNuclChainPrevNuclKey];
	
	return	[curr_label isEqualToString:target_current] && [prev_label isEqualToString:target_previous];
}

-(unsigned int) orderOfMarkovianAssumption {
	return 1;
}



@end
