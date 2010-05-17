//
//  BBSimpleAttributeFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 7/12/08.
//  Copyright 2008 University of Turin. All rights reserved.
//

#import "BBSimpleAttributeFeature.h"


NSString* BBSimpleAttributeFeatureIdKey = @"id";
NSString* BBSimpleAttributeFeatureValueKey = @"value";
NSString* BBSimpleAttributeFeatureLabelKey = @"label";


@implementation BBSimpleAttributeFeature


-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t{
	NSString* cur_label = [sequence labelAtTime:t];
	NSString* attributeName = [_parameters objectForKey:BBSimpleAttributeFeatureIdKey];
	NSNumber* targetValue = [_parameters objectForKey:BBSimpleAttributeFeatureValueKey];
	
	return [targetValue isEqualTo:[sequence valueOfAttributeAtTime:t named:attributeName]]
	&& [cur_label isEqualToString:[_parameters objectForKey:BBSimpleAttributeFeatureLabelKey]];
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}


@end
