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
//  BBFeaturesManager.h
//  SeqLearning
//
//  Created by Roberto Esposito on 12/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBErrorEvaluator.h>


@interface BBFeaturesManager : NSObject <NSCoding> {
	NSMutableArray* _features;
	NSMutableDictionary* _featuresToMutexCategoryMapper;
	NSMutableDictionary* _options;
}

-(id) initWithDataSet:(BBSeqSet*) dataSet;

+(BBFeaturesManager*) defaultManager;
+(void) setDefaultManager:(BBFeaturesManager*) manager;


-(void) setAsDefaultManager;

-(NSMutableDictionary*) options;
-(void) setOptions:(NSMutableDictionary*) dictionary;

-(NSDictionary*) featuresToMutexCategoryMapper;
-(void) setFeaturesToMutexCategoryMapper:(NSMutableDictionary*) mapper;

-(NSMutableArray*) features;
-(void) setFeatures:(NSMutableArray*) features;

/// this is the ONE method people really needs to implement
-(NSMutableArray*) arrayWithFeaturesUsingLabelSet:(NSSet*) labelSet;

/** this method simply calls initFeaturesUsingLabelSet using the appropriate
 * label set. It may be overridden in case more information (w.r.t. labels)
 * is needed in building the features.
 */
-(NSMutableArray*) arrayWithFeaturesUsingDataSet:(BBSeqSet*) dataset;


#pragma mark CODYING PROTOCOL
- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)coder;


@end
