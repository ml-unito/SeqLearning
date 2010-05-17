//
//  BBHMM.h
//  SeqLearning
//
//  Created by Roberto Esposito on 20/1/10.
//  Copyright 2010 University of Turin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <BBSequenceLearner.h>
#import "BBObjectCacher.h"

@interface BBHMM : BBSequenceLearner {
	BBObjectCacher* alphaCache;
	BBObjectCacher* betaCache;
}

-(NSObject<BBSequenceClassifying>*) learn:(BBSeqSet*) ss;

@end
