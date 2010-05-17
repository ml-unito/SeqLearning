//
//  BBSimpleFeaturesManager.h
//  SeqLearning
//
//  Created by Roberto Esposito on 7/12/08.
//  Copyright 2008 University of Turin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SeqLearning/BBFeaturesManager.h>

@interface BBSimpleFeaturesManager : BBFeaturesManager {

}


-(NSMutableArray*) featuresUsingLabelSet:(NSSet*) labelSet;
@end
