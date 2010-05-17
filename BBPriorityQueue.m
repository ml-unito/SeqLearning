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
//  BBPriorityQueue.m
//  SeqLearning
//
//  Created by Roberto Esposito on 3/6/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BBPriorityQueue.h"

CFComparisonResult smallFirst(const void* ptr1, const void* ptr2, void* info) {
	NSObject* o1 = (NSObject*) ptr1;
	NSObject* o2 = (NSObject*) ptr2;

	
	if( [o1 isLessThan:o2] ) {
		return kCFCompareLessThan;
	} else if( [o1 isGreaterThan:o2] ) {
		return kCFCompareGreaterThan;
	} else
		return kCFCompareEqualTo;
}

CFComparisonResult largeFirst(const void* ptr1, const void* ptr2, void* info) {
	NSObject* o1 = (NSObject*) ptr1;
	NSObject* o2 = (NSObject*) ptr2;
	
	
	if( [o1 isLessThan:o2] ) {
		return kCFCompareGreaterThan;
	} else if( [o1 isGreaterThan:o2] ) {
		return kCFCompareLessThan;
	} else
		return kCFCompareEqualTo;
}

const void *retainFun(  CFAllocatorRef allocator,
					  const void *ptr ) {
	return [(NSObject*)ptr retain];
}

void releaseFun (CFAllocatorRef allocator,
				 const void *ptr) {
	[(NSObject*)ptr release];
}


@implementation BBPriorityQueue

-(id) initWithOrder:(BBPriorityQueueOrder) order {
	if( (self=[super init])!=nil ) {
		CFBinaryHeapCallBacks callBacks;
		callBacks.version = 0;
		callBacks.retain = &retainFun;
		callBacks.release = &releaseFun;
		callBacks.copyDescription = NULL;
		
		if( order == BBPriorityQueueLargeFirst ) 
			callBacks.compare = &largeFirst;
		else
			callBacks.compare = & smallFirst;
		
		_queue = CFBinaryHeapCreate (NULL, 0, &callBacks,	NULL);
	}
	   
   return self;
}

-(void) dealloc {
	CFBinaryHeapRemoveAllValues(_queue);
	CFRelease(_queue);
	[super dealloc];
}

-(id) addObject: (NSObject*) object {
	[[NSNotificationCenter defaultCenter] postNotificationName:BBPriorityQueueObjectAddedNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:object 
																						   forKey:@"object"]];	
	CFBinaryHeapAddValue(_queue, object);
	return self;
}

-(const NSObject*) removeFirst {
	const NSObject* result = CFBinaryHeapGetMinimum(_queue);
	[[result retain] autorelease];
	CFBinaryHeapRemoveMinimumValue(_queue);
	[[NSNotificationCenter defaultCenter] postNotificationName:BBPriorityQueueRemovedFirstNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:result
																						   forKey:@"object"]];
	
	return result;
}

-(BOOL) isEmpty {
	return CFBinaryHeapGetCount(_queue) == 0;
}

@end
