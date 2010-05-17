//
//  BBSimpleFeaturesManager.m
//  SeqLearning
//
//  Created by Roberto Esposito on 7/12/08.
//  Copyright 2008 University of Turin. All rights reserved.
//

#import "BBSimpleFeaturesManager.h"
#import <BBSimpleAttributeFeature.h>
#import <BBSimpleLabelTransitionFeature.h>
#import <BBExceptions.h>


@implementation BBSimpleFeaturesManager

-(NSMutableArray*) featuresUsingLabelSet:(NSSet*) labelSet {
	@throw [NSException exceptionWithName:BBGenericError reason:@"This method should not be called!" userInfo:nil];
}

-(NSMutableArray*) featuresUsingDataSet:(BBSeqSet*) ss {	
	BBFeature* feature;
	NSMutableArray* featureSet;
	
	featureSet = [NSMutableArray arrayWithCapacity:100];
		
	unsigned int lastCategory=0;
	
	NSDictionary* attributes = [ss attributeDescriptions];
	NSSet* labels = [ss labels];
	
	for( NSString* attr_name in attributes ) {
		if( ![attr_name hasPrefix:@"attr-"] )
			continue;
		
		BBAttributeDescription* attribute = [attributes objectForKey:attr_name];
		if( [attribute type]!=BBAttributeTypeNominal ) {
			@throw [NSException exceptionWithName:BBGenericError 
										   reason:@"Cannot handle non-nominal attributes" 
										 userInfo:nil];
			
		}
		NSSet* attr_values = (NSSet*) [attribute info];
		
		for( NSString* value in attr_values ) {
			for( NSString* label in labels ) {
				feature = [[[BBSimpleAttributeFeature alloc] init] autorelease];
				[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
										attr_name, BBSimpleAttributeFeatureIdKey,
										value, BBSimpleAttributeFeatureValueKey,
										label, BBSimpleAttributeFeatureLabelKey,
										nil]];
				
				[featureSet addObject:feature];
				[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
												   forKey:feature];				
				lastCategory++;
			}
		}
	}
	
	/* --- Horizontal features --- 
	 All possible pairs (label,label) are codified.
	 */
	for( NSString* label1 in labels) {
		for( NSString* label2 in labels ) {
			feature = [[[BBSimpleLabelTransitionFeature alloc] init] autorelease];
			[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
									label1, BBSimpleLabelTransitionPreviousLabelKey,
									label2, BBSimpleLabelTransitionCurrLabelKey,
									nil]];
			[featureSet addObject:feature];
			[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
											   forKey:feature];			
		}
	}
	
	
	return featureSet;
}


@end
