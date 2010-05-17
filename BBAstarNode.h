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
//  BBAstarNode.h
//  SeqLearning
//
//  Created by Roberto Esposito on 3/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBSequence.h>
#import <SeqLearning/BBWeightsEvaluator.h>

@interface BBAstarNode : NSObject {
	NSMutableArray* _path;
	double _accumulatedWeight;	
	
	int t;
	BBWeightsEvaluator* eval;
	NSObject* label;
}

@property int t;
@property(retain) BBWeightsEvaluator* eval;
@property(retain) NSObject* label;	


+(BBAstarNode*) nodeForLabel: (NSObject*) label	
				   evaluator: (BBWeightsEvaluator*) evaluator
					 forTime: (int) t;

// Sets the path information for this node. The given path is
// assumed to be the path from the root to the parent of this node.
-(void) setPath:(NSMutableArray*) path;

// Returns the path from the root to this node (included)
-(NSMutableArray*) path;

// Returns the path from the root to the parent of this node 
// (i.e., this node is excluded from the path)
-(NSMutableArray*) pathToParentNode;
-(NSArray*) successors;

-(BOOL) goal;


-(BOOL) isLessThan:(BBAstarNode*) node;
-(BOOL) isGreaterThan:(BBAstarNode*) node;

-(void) setAccumulatedWeight:(double) weight;

-(double) accumulatedWeight;
-(double) estimatedWeight;

@end
