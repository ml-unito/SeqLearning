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
//  BBPriorityQueueWithUpdatableKeys.m
//  SeqLearning
//
//  Created by radicion on 4/29/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BBPriorityQueueWithUpdatableKeys.h"


@implementation BBPriorityQueueWithUpdatableKeys


-(id) initWithOrder:(BBPriorityQueueOrder) order {
	
	if((self = [super init])) {
		if(!(_queue = [[NSMutableArray alloc] init]))
			return nil;
		
		_order = order;
	}
	
	return self;
}


-(void) dealloc {
	
	[_queue release];
	[super dealloc];
}


-(id) addObject: (NSObject*) object {
	[[NSNotificationCenter defaultCenter] postNotificationName:BBPriorityQueueObjectAddedNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:object 
																						   forKey:@"object"]];
	
	[_queue addObject:object];
	return self;	
}

-(BOOL) compareObject:(NSObject*) object1 andObject:(NSObject*) object2 {
	if(_order == BBPriorityQueueLargeFirst)
		return [object1 isGreaterThan:object2];
	else
		return [object1 isLessThan:object2];
}

-(NSObject*) removeFirst {
	
	if([self isEmpty])
		return nil;



	int i;
	int targetIndex = 0;
	NSObject* targetObject = [_queue objectAtIndex:0];
	
	int queueLength = [_queue count];
	
	for(i=1; i<queueLength; ++i) {
		NSObject* currentObject = [_queue objectAtIndex:i];

		if([self compareObject:currentObject andObject:targetObject]) {
			targetObject = currentObject;
			targetIndex = i;
		}
	}
	
	[targetObject retain];
	[_queue removeObjectAtIndex:targetIndex];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:BBPriorityQueueRemovedFirstNotification
														object:self
													  userInfo:[NSDictionary dictionaryWithObject:targetObject
																						   forKey:@"object"]];
	
	
	return [targetObject autorelease];
}


-(BOOL) isEmpty {
	
	return [_queue lastObject] == nil;
}

-(unsigned int) count {
	return [_queue count];
}

@end
