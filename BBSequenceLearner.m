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
//  BBSequenceLearner.m
//  SeqLearning
//
//  Created by Roberto Esposito on 21/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBSequenceLearner.h>
#import <SeqLearning/BBExceptions.h>

@implementation BBSequenceLearner

-(id)init {
	if( self = [super init] ) {
		_options = [[NSMutableDictionary alloc] init];		
	}
	
	return self;
}

-(void)dealloc {
	[_features release];
	[_options release];
	
	[super dealloc];
}

-(void) setFeatures:(NSArray*) features {
	[_features autorelease];
	_features = [features retain];
}

-(NSArray*) features {
	return _features;
}

-(void) setOptions:(NSMutableDictionary*) options {
	[_options autorelease];
	_options = [options retain];
}

-(NSMutableDictionary*) options {
	return _options;
}

-(NSObject<BBSequenceClassifying>*) learn:(BBSeqSet*) ss {
	@throw [NSException exceptionWithName:BBGenericError
								   reason:@"learn method not implemented" 
								 userInfo:nil];
}

-(BBFeaturesManager*) featuresManager {
	@throw [NSException exceptionWithName:BBGenericError 
								   reason:@"Not implemented -- should not be called (this is a bug!)" 
								 userInfo:nil];
}
-(void) setFeaturesManager:(BBFeaturesManager*) featuresManager {
	@throw [NSException exceptionWithName:BBGenericError 
								   reason:@"Not implemented -- should not be called (this is a bug!)" 
								 userInfo:nil];	
}



@end
