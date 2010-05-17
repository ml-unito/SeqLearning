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
//  BBTestPriorityQueue.m
//  SeqLearning
//
//  Created by radicion on 5/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BBTestPriorityQueue.h"


@implementation BBTestPriorityQueue


-(void) testPriorityQueue {
	NSString* objects[6] = {@"ada",@"carla",@"dado",@"mario",@"paolo",@"tishi"};
	
	BBPriorityQueue* queue = 
		[[BBPriorityQueue alloc] initWithOrder:BBPriorityQueueLargeFirst];
	
	STAssertNotNil(queue, @"could not allocate queue");
	
	[queue addObject:objects[3]];
	[queue addObject:objects[1]];
	[queue addObject:objects[5]];
	[queue addObject:objects[4]];
	[queue addObject:objects[2]];
	[queue addObject:objects[0]];
	
	int i=5;
	while( ![queue isEmpty] ) {
		NSString* current;
		STAssertEquals(current=(NSString*)[queue removeFirst], objects[i],
									 [NSString stringWithFormat:@"%@ got, but %@ expected",
											current, objects[i]]);
		--i;
	}
	
	
	STAssertEquals( i, -1, @"Wrong number of iterations!");
}

@end
