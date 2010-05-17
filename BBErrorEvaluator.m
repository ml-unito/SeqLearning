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
//  BBErrorEvaluator.m
//  SeqLearningExperimenter
//
//  Created by Roberto Esposito on 16/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "BBErrorEvaluator.h"


@implementation BBErrorEvaluator

+(BBErrorEvaluator*) evaluator {
	return [[[BBErrorEvaluator alloc] init] autorelease];
}

-(BOOL) prediction:(NSString*) predicted differsFrom:(NSString*) correct {
	return ![predicted isEqualToString:correct];
}

-(double) evaluateErrorUsingLabelledSeqSet:(BBSeqSet*) ss {
	int error=0;
	int n, predictions_count=0;
	NSEnumerator* seq_enumerator = [ss sequenceEnumerator];
	BBSequence* sequence;
	
	while( sequence = [seq_enumerator nextObject] ) {
		int seq_len = [sequence length];
		predictions_count+=seq_len;
		
		for(n=0; n<seq_len; ++n) {
			NSString* correct = [sequence correctLabelAtTime:n];
			NSString* predicted = [sequence labelAtTime:n];
			if( ![correct isEqualToString:predicted] )
				++error;
		}
	}
	
	NSLog(@"%f",((float)error)/((float)predictions_count));
	return ((double)error)/((double)predictions_count);	
}

// NSCoding
- (id)initWithCoder:(NSCoder *)coder {
	self=[super init];
	return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
	return;
}


@end
