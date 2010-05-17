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
//  BBHMPerceptron.h
//  SeqLearning
//
//  Created by Roberto Esposito on 21/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBSequenceLearner.h>
#import <SeqLearning/BBSequenceClassifying.h>
#import <SeqLearning/BBErrorEvaluator.h>
#import <SeqLearning/BBFeaturesManager.h>

// the following notification is posted each time the algorithm terminates
// an iteration. UserInfos passed along with the notification contain the
// an NSNumber with the current iteration. The key for getting such information
// is @"number". The number is the sequential number of the sequence in the BBSeqSet
// starting the numeration from 1.
extern NSString* BBHMPerceptronFinishedIterationNotification;



// the following notification is posted each time the algorithm starts
// to analyse a sequence. UserInfos passed along with the notification contain the
// an NSNumber with the current sequence number. The key for getting such information
// is @"number". The number is the sequential number of the sequence in the BBSeqSet
// starting the numeration from 1.

extern NSString* BBHMPerceptronStartedSequenceNotification;


// the following notification is posted each time the algorithm terminates
// to analyse a sequence. UserInfos passed along with the notification contain the
// an NSNumber with the current sequence number. The key for getting such information
// is @"number". The number is the sequential number of the sequence in the BBSeqSet
// starting the numeration from 1.
extern NSString* BBHMPerceptronFinishedSequenceNotification;



extern NSString* BBHMPerceptronNumberOfIterationsOption;
extern NSString* BBHMPerceptronUseAveragingParametersOption;
extern NSString* BBHMPerceptronViterbiClassifierClassOption;
extern NSString* BBHMPerceptronErrorEvaluatorClassOption;


@interface BBHMPerceptron : BBSequenceLearner {
	NSMutableArray* _weights;
	NSMutableArray* _correct_labels;
	BBErrorEvaluator* _errorEvaluator;
	BBFeaturesManager* _featuresManager;
}


-(NSObject<BBSequenceClassifying>*) learn:(BBSeqSet*) ss;


@end
