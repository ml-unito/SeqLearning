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
//  BBCPointerWrapper.m
//  SeqLearning
//
//  Created by Roberto Esposito on 30/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "BBCPointerWrapper.h"


@implementation BBCPointerWrapper

-(id) init {
	if((self=[super init])) {
		_pointer = NULL;
	}
	
	return self;
}

-(void) dealloc {
	_pointer = NULL;
	[super dealloc];
}

+(id) wrapperWithPointer:(void*) ptr {
	BBCPointerWrapper* wrapper = [[[BBCPointerWrapper alloc] init] autorelease];
	[wrapper setPointer:ptr];
	
	return wrapper;
}

-(void) setPointer:(void*) ptr {
	_pointer = ptr;
}

-(void*) pointer {
	return _pointer;
}

@end
