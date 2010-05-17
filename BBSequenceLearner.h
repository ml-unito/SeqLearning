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
//  BBSequenceLearner.h
//  SeqLearning
//
//  Created by Roberto Esposito on 21/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBSequenceClassifying.h>
#import <SeqLearning/BBSeqSet.h>
#import <SeqLearning/BBFeaturesManager.h>



@interface BBSequenceLearner : NSObject {
	NSArray* _features;
	NSMutableDictionary* _options;
}

-(id)init;
-(void)dealloc;

-(void) setFeatures:(NSArray*) features;
-(NSArray*) features;

-(void) setOptions:(NSMutableDictionary*) options;
-(NSMutableDictionary*) options;

-(NSObject<BBSequenceClassifying>*) learn:(BBSeqSet*) ss;

-(BBFeaturesManager*) featuresManager;
-(void) setFeaturesManager:(BBFeaturesManager*) featuresManager;

@end
