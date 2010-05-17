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
//  BBFasterViterbiTracer.h
//  SeqLearning
//
//  Created by Roberto Esposito on 29/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBCarpeDiemClassifier.h>

#pragma mark TRACING INFO

@interface BBFasterViterbiTraceInfo : NSObject {
	unsigned int _t;
	unsigned int _nlabels;
	NSMutableArray* _nodesStatusForTime;
}

-(id) initForTime:(unsigned int) t andNumLabels:(unsigned int) nlabels;
+(id) tracerForTime:(unsigned int) t andNumLabels:(unsigned int) nlabels;

/* the method should be called at the beginning of iteration [self time] 
   nodesInfo needs to be the state of the system at that time */
-(void) traceBeginningOfIteration:(NSDictionary*) infos;

/* the method should be called at the end of iteration [self time] 
   nodesInfo needs to be the state of the system at that time */
-(void) traceEndOfIteration:(NSDictionary*) infos;


/* 
	returns the time associated with this trace
 */
-(unsigned int) time;


/* returns the number of nodes per layer */
-(unsigned int) nodesPerLayer;

/*	Returns the tracing info for node number n at time (i.e. layer) t (where t<=[self time]) 
	the returned dictionary has keys for the following info:
		label: NSString* reporting the label associated to the node
		alreadyOpen: NSNumber* (bool). True if the node was open before starting iteration [self time]
		newlyOpened: NSNumber* (bool). True if the node has been open during iteration [self time]
        score: NSNumber* (float). The overall score for that node at the time of finishing the iteration.
        verticalWeight: NSNumber* (float). The vertical weight of the node.
	note that if alreadyOpen is False and newlyOpened is false then the node is still closed.
	*/
-(NSDictionary*) infoForNode:(unsigned int) n atTime: (unsigned int) t;

-(NSString*) dumpToString;
@end


#pragma mark TRACER

@interface BBFasterViterbiTracer : NSObject {
	BBCarpeDiemClassifier* _classifier;
	NSMutableArray* _executionTrace; // array of BBTraceInfo objects
}

-(id) initWithClassifier:(BBCarpeDiemClassifier*) classifier;
-(void) dealloc;


/* Start tracing execution of classifier [self classifier] */
-(void) startTracing;

/* Start tracing execution of classifier [self classifier] */
-(void) stopTracing;

/* Returns the tracing information for timestep t */
-(BBFasterViterbiTraceInfo*) traceForTime:(unsigned int) t;

/* Returns the number of nodes per layer (it will fail if no trace has been already added */
-(unsigned int) nodesPerLayer;

@end
