/**********************************************************************
This source file belongs to the seqlearning library: a sequence learning objective-c library.
Copyright (C) 2008  Roberto Esposito

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
***********************************************************************/
//
//  BBNaturalLanguageAnalysisFeatureManager.m
//  SeqLearning
//
//  Created by Roberto Esposito on 2/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBNaturalLanguageAnalysisFeatureManager.h"
#import "BBMcCallumFeature.h"
#import "BBNaturalLanguageHorizontalFeature.h"

@implementation BBNaturalLanguageAnalysisFeatureManager

-(NSMutableArray*) arrayWithFeaturesUsingLabelSet:(NSSet*) labelSet {	
	unsigned int lastCategory=0;
	BBFeature* feature;
	NSMutableArray* featureSet = [NSMutableArray arrayWithCapacity:100];

	NSString* classes[4] = {@"p",@"q",@"a",@"j"};
	
	int i;
	int c_curr;	
	
	for(c_curr=0; c_curr<4; ++c_curr) {
		for(i=1;i<25;++i) {
			feature = [[[BBMcCallumFeature alloc] init] autorelease];
			[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:i],BBMcCallumFeatureKeyNumber,
				classes[c_curr], BBMcCallumFeatureKeyCurrLabel,NULL]];
			[featureSet addObject:feature];
			[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory++]
											   forKey:[featureSet lastObject]]; 			
		}
	}


	int c_prev;

	for(c_prev=0; c_prev<4; ++c_prev) {
		for(c_curr=0; c_curr<4; ++c_curr) {
			feature = [[[BBNaturalLanguageHorizontalFeature alloc] init] autorelease];
			[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
				classes[c_prev], BBNaturalLanguageHorizontalFeatureKeyPrevLabel,
				classes[c_curr], BBNaturalLanguageHorizontalFeatureKeyCurrLabel, NULL]];
			[featureSet addObject:feature];
			[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
											   forKey:[featureSet lastObject]];
		}
	}
	
	return featureSet;
}

@end
