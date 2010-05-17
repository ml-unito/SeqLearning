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
//  BBSequenceClassifying.h
//  SeqLearningNew
//
//  Created by Roberto Esposito on 19/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBSequence.h>
#import <SeqLearning/BBFeaturesManager.h>

@protocol BBSequenceClassifying

-(NSArray*) labelsForSequence:(BBSequence*) sequence;

/**
 * Returns the currently set features manager or nil if no one was set.
 */
-(BBFeaturesManager*) featuresManager;

/**
 * Sets the features manager to be used (it may do nothing in case a features manager
 * is not required for the classifier to work properly).
 */
-(void) setFeaturesManager:(BBFeaturesManager*) featuresManager;

/**
 * Return YES if the classifier cannot be used for classifying yet.
 * For instance a classifier may return YES if its weight vector has not
 * yet been filled.
 */
-(BOOL) invalid;

@end
