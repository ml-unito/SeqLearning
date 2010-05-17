//
//  BBVectorCacher.h
//  SeqLearning
//
//  Created by Roberto Esposito on 22/1/10.
//  Copyright 2010 University of Turin. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BBObjectCacher : NSObject {
	size_t _size;
	void** _caches;
}

-(id) initWithSize:(size_t) size;

-(void*) cachedObjectForTime:(size_t) t;
-(void) cacheObject:(void*) vec forTime: (size_t) t;

-(void) cleanCache;


@end
