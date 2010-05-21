//
//  BBMusicAnalysisWithAbsFeaturesManager.h
//  SeqLearning
//
//  Created by Roberto Esposito on 21/5/10.
//  Copyright 2010 University of Turin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBFeaturesManager.h>


@interface BBMusicAnalysisWithAbsFeaturesManager : BBFeaturesManager {

}

-(NSMutableArray*) initFeaturesUsingLabelSet:(NSSet*) labelSet;

@end
