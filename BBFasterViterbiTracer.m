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
//  BBFasterViterbiTracer.m
//  SeqLearning
//
//  Created by Roberto Esposito on 29/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBFasterViterbiTracer.h"
#import <SeqLearning/BBCPointerWrapper.h>
#import <SeqLearning/BBExceptions.h>

#pragma mark -
#pragma mark TRACING INFO
#pragma mark -

@implementation BBFasterViterbiTraceInfo 

# pragma mark CONSTRUCTORS AND DESTRUCTORS

-(id) initForTime:(unsigned int) t andNumLabels:(unsigned int) nlabels {
	if( self=[super init] ) {
		_t = t;
		_nlabels = nlabels; 
		_nodesStatusForTime = [[NSMutableArray alloc] initWithCapacity:t];
	}
	
	return self;		
}


-(void) dealloc {
	[_nodesStatusForTime release];		
	[super dealloc];
}

+(id) tracerForTime:(unsigned int) t andNumLabels:(unsigned int) nlabels {
	return [[[BBFasterViterbiTraceInfo alloc] initForTime:t andNumLabels: nlabels] autorelease];
}

#pragma mark TRACE METHODS

-(void) traceBeginningOfIteration:(NSDictionary*) infos {
	NodesInfo* nodesInfo = (NodesInfo*) [[infos objectForKey:@"nodesInfo"] pointer];
	
	NSAssert( [_nodesStatusForTime count]==0,
			  @"traceBeginningOfIteration called more than once! (At least _nodesStatusForTime is not empty)" );
	int t;
	for(t=0; t<=[self time]; ++t) {
		int n;
		NSMutableArray* statusesAtTime = [NSMutableArray arrayWithCapacity:_nlabels];
		for( n=0; n<_nlabels; ++n) {
			NSMutableDictionary* nodeStats;
			if( nodesInfo->open[t][n] ) {
				nodeStats = 
					[NSMutableDictionary dictionaryWithObjectsAndKeys:
						[nodesInfo->labelSet objectAtIndex:n], @"label",
						[NSNumber numberWithBool:TRUE], @"alreadyOpen",
						nil];
			} else {
				nodeStats =
				[NSMutableDictionary dictionaryWithObjectsAndKeys:
					[nodesInfo->labelSet objectAtIndex:n], @"label",
					[NSNumber numberWithBool:FALSE], @"alreadyOpen",
					nil];				
			}
			
			[statusesAtTime addObject:nodeStats];
		}
		
		[_nodesStatusForTime addObject:statusesAtTime];
	}
}

-(void) traceEndOfIteration:(NSDictionary*) infos {
	NodesInfo* nodesInfo = (NodesInfo*) [[infos objectForKey:@"nodesInfo"] pointer];	

	int t;
	for(t=0; t<=[self time]; ++t) {
		NSAssert( [_nodesStatusForTime count]==([self time]+1),
				  @"Internal error: erroneous number of objects in _nodesStatusForTime" );
		NSAssert( [[_nodesStatusForTime objectAtIndex:t] count]==_nlabels,
				  ([NSString stringWithFormat:@"Internal error: erroneous number of objects in _nodesStatusForTime at time step:%d",t]) );		
		int n;		
		for( n=0; n<_nlabels; ++n) {
			NSMutableDictionary* nodeStatus = [[_nodesStatusForTime objectAtIndex:t] objectAtIndex:n]; 
			if( nodesInfo->open[t][n] && ![[nodeStatus objectForKey:@"alreadyOpen"] boolValue]) {
				[nodeStatus setObject:[NSNumber numberWithBool:TRUE] forKey:@"newlyOpened"];
			} else {
				[nodeStatus setObject:[NSNumber numberWithBool:FALSE] forKey:@"newlyOpened"];
			}								
			[nodeStatus setObject:[NSNumber numberWithFloat:nodesInfo->scores[t][n]] forKey:@"score"];
			[nodeStatus setObject:[infos objectForKey:@"bound"] forKey:@"bound"];
		}
	}	
}

-(unsigned int) time {
	return _t;
}

-(NSDictionary*) infoForNode:(unsigned int) n atTime: (unsigned int) t {
	return [[_nodesStatusForTime objectAtIndex:t] objectAtIndex:n];
}


-(NSString*) dumpToString {
	NSMutableString* result = [NSMutableString string];
	NSArray* nodes;
	int t,n;
	for( n=0; n<_nlabels; ++n ) {
		for(t=0; t<[_nodesStatusForTime count]; ++t) {
			nodes = [_nodesStatusForTime objectAtIndex:t];
			NSDictionary* info = [nodes objectAtIndex:n];
			char openStatus;
			if( [[info objectForKey:@"alreadyOpen"] boolValue] )
				openStatus = 'O';
			else if( [[info objectForKey:@"newlyOpened"] boolValue] )
				openStatus = 'N';
			else 
				openStatus = 'C';
			
			[result appendFormat:@"%c(%4s) ", openStatus, [[info objectForKey:@"label"] cString]];
		}
		
		[result appendFormat:@"\n"];
	}
	
	return result;
}


-(unsigned int) nodesPerLayer {
	return _nlabels;
}

@end

#pragma mark -
#pragma mark TRACER
#pragma mark -

@implementation BBFasterViterbiTracer

-(id) initWithClassifier:(BBCarpeDiemClassifier*) classifier {
	if(self=[super init]) {
		_classifier = [classifier retain];
		_executionTrace = [[NSMutableArray alloc] initWithCapacity:200];				
	}
	
	return self;
}

-(void) dealloc {
	[_executionTrace release];
	[super dealloc];
}

-(void) iterationWillBegin:(NSNotification*) notification  {
	NSNumber* time = [[notification userInfo] objectForKey:@"time"];
	NodesInfo* nodesInfo = (NodesInfo*) [[[notification userInfo] objectForKey:@"nodesInfo"] pointer];
	NSAssert( time!=nil, @"time key must exist" );
	BBFasterViterbiTraceInfo* traceInfo = [BBFasterViterbiTraceInfo tracerForTime:[time intValue]
																	 andNumLabels:nodesInfo->numLabels];
	[traceInfo traceBeginningOfIteration:[notification userInfo]];
	[_executionTrace addObject:traceInfo];
}


-(void) iterationDidEnd:(NSNotification*) notification {
	NSNumber* time = [[notification userInfo] objectForKey:@"time"];
	NSAssert( time!=nil, @"time key must exist" );
	BBFasterViterbiTraceInfo* traceInfo = [_executionTrace objectAtIndex:[time intValue]];
	[traceInfo traceEndOfIteration:[notification userInfo]];	
}


-(void) startTracing {
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(iterationWillBegin:) 
												 name:BBViterbiClassifierWillAnalyzeEventAtTimeNotification 
											   object:_classifier];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(iterationDidEnd:) 
												 name:BBViterbiClassifierAnalyzedEventAtTimeNotification 
											   object:_classifier];
}

-(void) stopTracing {
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:BBViterbiClassifierWillAnalyzeEventAtTimeNotification 
												  object:_classifier];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:BBViterbiClassifierAnalyzedEventAtTimeNotification
												  object:_classifier];
	[_classifier release];
	_classifier = nil;
}


-(BBFasterViterbiTraceInfo*) traceForTime:(unsigned int) t {
	return [_executionTrace objectAtIndex:t];
}

-(unsigned int) tracesCount {
	return [_executionTrace count];
}

-(unsigned int) nodesPerLayer {
	if( [self tracesCount] == 0 )
		@throw [NSException exceptionWithName:BBGenericError
									   reason:@"@SEL(nodesPerLayer) called with no traces" 
									 userInfo:nil];
	return [[self traceForTime:0] nodesPerLayer];
}

@end
