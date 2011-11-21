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
//  BBAstarNode.m
//  SeqLearning
//
//  Created by Roberto Esposito on 3/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BBAstarNode.h"

@implementation BBAstarNode

@synthesize t;
@synthesize eval;
@synthesize label;


#pragma mark COMPARISONS
-(BOOL) isGreaterThan:(BBAstarNode*) node {
	return [self estimatedWeight] > [node estimatedWeight];
}

-(BOOL) isLessThan:(BBAstarNode*) node {
	return [self estimatedWeight] < [node estimatedWeight];	
}

#pragma mark ALLOC/DEALLOC AND ACCESSORS

-(id)init {
	if( (self=[super init]) ) {
		_path = [[NSMutableArray array] retain];
		_accumulatedWeight = 0;
	}
	
	return self;
}


-(void) dealloc {
	if(_path) [_path release];
	if(self.label) [label release];
	if(self.eval) [eval release];
	[super dealloc];
}

+(BBAstarNode*) nodeForLabel: (NSObject*) label	evaluator: (BBWeightsEvaluator*) e forTime: (int) t {	
	BBAstarNode* result = [[BBAstarNode alloc] init];
	result.t = t;
	result.eval = e;
	result.label = label;
	
	return [result autorelease];
}


-(void) setAccumulatedWeight: (double) weight {
	_accumulatedWeight = weight;
}



-(void) setPath:(NSMutableArray*) path {
	[_path autorelease];
	_path = [path retain];
}

-(NSMutableArray*) path {
	NSMutableArray* result = [[_path mutableCopy] autorelease];
	 
	[result addObject:self.label];
	return result;
}

-(NSMutableArray*) pathToParentNode {
	return _path;
}


-(NSString*) description {
	NSMutableString* result = [NSMutableString string];
	BOOL first=TRUE;
	for( NSObject* obj in _path ) {
		
		if(first) {
			first=FALSE;
		} else {
			[result appendString:@"->"];
		}
		
		[result appendString:[obj description]];
	}
	
	[result appendString:@"-|"];
	[result appendString:[label description]];
	[result appendString:[NSString stringWithFormat:@"(a:%f e:%f)", _accumulatedWeight, [self estimatedWeight]]];
	return result;
}


#pragma mark METHODS TO SUPPORT ASTAR

-(NSArray*) successors {
	NSMutableArray* result = [NSMutableArray array];
	int new_t = self.t+1;
	
	for(NSObject* new_label in [self.eval labels]) {
		double vW =  [self.eval vertWeightForLabel:new_label atTime:new_t]; 
		double hW = [self.eval horizWeightFromLabel:self.label toLabel: new_label atTime:new_t];		
		
		BBAstarNode* node = [BBAstarNode nodeForLabel:new_label 
											 evaluator:self.eval 
											  forTime:new_t];				
		
		[node setAccumulatedWeight: (_accumulatedWeight + vW + hW)];
		[node setPath: [self path]];
				
		[result addObject:node];
	}
	
	return result;
}

-(BOOL) goal {	
	return self.t==([self.eval sequenceLength]-1);
}

-(double) accumulatedWeight {
	return _accumulatedWeight;
}

-(double) estimatedWeight {
	NSAssert( t<[self.eval sequenceLength], @"t greater than the sequence length" );
	return _accumulatedWeight + [self.eval maxHorizWeightFromTime:t] + [self.eval maxVertWeightFromTime:t]; 
}



@end
