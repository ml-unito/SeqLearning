//
//  BBVectorCacher.m
//  SeqLearning
//
//  Created by Roberto Esposito on 22/1/10.
//  Copyright 2010 University of Turin. All rights reserved.
//

#import "BBObjectCacher.h"


@implementation BBObjectCacher

-(id) initWithSize:(size_t) size {
	if(self=[super init]) {
		_caches = (void**) malloc( size * sizeof(void*) );
		_size = size;
		NSAssert( _caches != NULL, @"Cannot alloc memory for vector caches" );
		
		size_t i;
		for(i=0;i<size;++i) _caches[i]=NULL;
	}
	
	return self;
}

-(void*) cachedObjectForTime:(size_t) t {
	return _caches[t];
}

-(void) cacheObject:(void*) vec forTime:(size_t) t {
//	if(cache[t]!=NULL)
//		[deallocingDelegate releaseMemoryFor:cache[t]];
	
	_caches[t] = vec;
}


-(void) cleanCache {
	size_t i;
	for(i=0;i<_size;++i) _caches[i]=NULL;
}


@end
