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
//  BBTestFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 20/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBTestFeature.h"


@implementation BBTestFeature

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	NSString* key1 = [_parameters objectForKey:@"key1"];
	NSString* key2 = [_parameters objectForKey:@"key2"];

	NSNumber* num1 = [sequence valueOfAttributeAtTime:t named:key1];
	NSNumber* num2 = [sequence valueOfAttributeAtTime:t named:key2];
	NSNumber* num3 = [NSNumber numberWithInt:[num1 intValue]+[num2 intValue]];


	return [[num3 stringValue] isEqual:[sequence labelAtTime:t]];	
}


@end
