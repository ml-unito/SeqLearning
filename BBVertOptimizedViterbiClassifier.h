//
//  BBVertOptimizedViterbiClassifier.h
//  SeqLearning
//
//  Created by Roberto Esposito on 16/12/08.
//  Copyright 2008 University of Turin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBViterbiClassifier.h>

@interface BBVertOptimizedViterbiClassifier : BBViterbiClassifier {
	NSArray* _verticalFeatures;
	NSArray* _horizontalFeatures;
	NSArray* _verticalWeights;
	NSArray* _horizontalWeights;
	
	double _currentVerticalWeight;
	
	NSString* _currentLabel;
	int _currentT;
}


-(double) unoptimizedScoreForTransitionAtTime:(unsigned int) t onSequence:(BBSequence*) sequence;

@end
