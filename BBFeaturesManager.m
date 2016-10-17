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
//  BBFeaturesManager.m
//  SeqLearning
//
//  Created by Roberto Esposito on 12/10/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBFeaturesManager.h"
#import <SeqLearning/BBExceptions.h>

static BBFeaturesManager* _defaultManager = nil;

@implementation BBFeaturesManager


// defaultManager -- this was a bad bad bad idea
+(BBFeaturesManager*) defaultManager {
	@throw [NSException exceptionWithName:BBGenericError reason:@"Method deprecated!" userInfo:nil];
//	return _defaultManager;
}
+(void) setDefaultManager:(BBFeaturesManager*) manager {
	[_defaultManager autorelease];
	_defaultManager = [manager retain];
}


-(id) init {
	@throw [NSException exceptionWithName:BBGenericError reason:@"BBFeaturesManager init should not be called directly!" userInfo:nil];
}


-(id) initWithDataSet:(BBSeqSet*) dataset {
	if( (self=[super init]) ) {
		[self setFeaturesToMutexCategoryMapper:[NSMutableDictionary dictionaryWithCapacity:100]];
		[self setFeatures:[self arrayWithFeaturesUsingDataSet:dataset]];
		[self setOptions: [NSMutableDictionary dictionary]];
	}
	
	return self;
}

-(void) dealloc {
	[_features release];
	[_featuresToMutexCategoryMapper release];
	[super dealloc];
}

-(NSMutableDictionary*) options {
	return _options;
}

-(void) setOptions:(NSMutableDictionary*) dictionary {
	[_options autorelease];
	_options = [dictionary retain];
}

-(NSMutableArray*) features {
	return _features;
}

-(NSDictionary*) featuresToMutexCategoryMapper {
	return _featuresToMutexCategoryMapper;
}

-(void) setFeatures:(NSMutableArray*) features {
	[_features autorelease];
	_features = [features retain];
}

-(void) setFeaturesToMutexCategoryMapper:(NSMutableDictionary*) mapper {
	[_featuresToMutexCategoryMapper autorelease];
	_featuresToMutexCategoryMapper = [mapper retain];
}

-(void) setAsDefaultManager {
	[BBFeaturesManager setDefaultManager:self];
}


- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:_features forKey:@"features"];
	[encoder encodeObject:_featuresToMutexCategoryMapper forKey:@"featuresToMutexCategoryMapper"];
	[encoder encodeObject:_options forKey:@"featuresManagerOptions"];
}

- (id)initWithCoder:(NSCoder *)coder {
	
    if((self = [super init])) {
		NSMutableArray* features = [coder decodeObjectForKey:@"features"];
		NSMutableDictionary* mapper = [coder decodeObjectForKey:@"featuresToMutexCategoryMapper"];
		NSMutableDictionary* options = [coder decodeObjectForKey:@"options"];
		
		[self setFeatures:features];
		[self setFeaturesToMutexCategoryMapper:mapper];
		if(options!=nil)
			[self setOptions:options];
		else
			[self setOptions:[NSMutableDictionary dictionary]];
	}
	
    return self;
}

-(NSMutableArray*) arrayWithFeaturesUsingLabelSet:(NSSet*) labelSet {
	NSAssert(FALSE, @"This method should be implemented in subclasses...");
	return nil;
}


-(NSMutableArray*) arrayWithFeaturesUsingDataSet:(BBSeqSet*) dataset {
	return [self arrayWithFeaturesUsingLabelSet:[dataset labels]];
}

@end
