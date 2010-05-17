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
//  BBMcCallumFeature.h
//  SeqLearning
//
//  Created by Roberto Esposito on 2/11/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBFeature.h>

extern NSString* BBMcCallumFeatureKeyNumber;
extern NSString* BBMcCallumFeatureKeyCurrLabel;

/* This class implements the features reported by McCallum in 
 * "Maximum Entropy Markov Models for Information Extraction and
 *  Segmentation". This is actually a "fake" feature: it does not
 *  really compute anything, it reports the value of the feature
 *  read from the input file (McCallum provides a dataset where 
 *  the features are precomputed; this BBFeature is built upon
 *  the assumption that such a dataset is used).
 * 
 *  This is a vertical feature. The feature returns 1 if the k-th 
 *  McCallum feature is 1 *and* the currently predicted label is equal
 *  the one set in the options.
 */

@interface BBMcCallumFeature : BBFeature {

}

-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t;

@end
