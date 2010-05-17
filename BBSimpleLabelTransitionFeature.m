//
//  BBSimpleLabelTransitionFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 7/12/08.
//  Copyright 2008 University of Turin. All rights reserved.
//

#import "BBSimpleLabelTransitionFeature.h"

NSString* BBSimpleLabelTransitionCurrLabelKey = @"current label";
NSString* BBSimpleLabelTransitionPreviousLabelKey = @"previous label";

@implementation BBSimpleLabelTransitionFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t{
	if( t==0 )
		return FALSE;
	
	NSString* curr_label = [sequence labelAtTime:t];
	NSString* prev_label = [sequence labelAtTime:t-1];
	NSString* target_current  = [_parameters objectForKey:BBSimpleLabelTransitionCurrLabelKey];
	NSString* target_previous = [_parameters objectForKey:BBSimpleLabelTransitionPreviousLabelKey];
	
	return	[curr_label isEqualToString:target_current] &&
	[prev_label isEqualToString:target_previous];
}

-(unsigned int) orderOfMarkovianAssumption {
	return 1;
}

@end
