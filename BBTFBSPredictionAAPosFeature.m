//
//  BBTFBSPredictionAAPosFeature.m
//  SeqLearning
//
//  Created by Roberto Esposito on 22/12/08.
//  Copyright 2008 University of Turin. All rights reserved.
//

#import <SeqLearning/BBTFBSPredictionAAPosFeature.h>

NSString* BBTFBSPredictionAAPosFeatureAAKey = @"AA";
NSString* BBTFBSPredictionAAPosFeatureAPosKey = @"APos";
NSString* BBTFBSPredictionAAPosFeatureNuclKey = @"Nucl";
NSString* BBTFBSPredictionAAPosFeatureNPosKey = @"NPos";

#define POS_FIRST_AA_ATTRIBUTE 2

@implementation BBTFBSPredictionAAPosFeature

-(id) initWithNumAAAttributes:(unsigned int) num {
	if( (self = [super init]) ) {
		num_aa_attributes = num;
	}
	
	return self;
}


-(BOOL) evalOnSequence:(BBSequence*) sequence forTime:(unsigned int) t {
	
	NSString* my_aa = [_parameters objectForKey:BBTFBSPredictionAAPosFeatureAAKey];
	NSString* my_apos = [_parameters objectForKey:BBTFBSPredictionAAPosFeatureAPosKey];
	NSString* my_nucl = [_parameters objectForKey:BBTFBSPredictionAAPosFeatureNuclKey];
	NSNumber* my_npos = [_parameters objectForKey:BBTFBSPredictionAAPosFeatureNPosKey];

	NSString* curr_nucl = [sequence labelAtTime:t];
	NSNumber* curr_npos = [sequence valueOfAttributeAtTime:t named:@"position"];
	
	if( ![curr_nucl isEqualToString:my_nucl] || ![curr_npos isEqualToNumber:my_npos])
		return FALSE;
	
	int i;
	int last_aa_attribute_index = POS_FIRST_AA_ATTRIBUTE + (num_aa_attributes-1)*2;
	for( i = POS_FIRST_AA_ATTRIBUTE; i <= last_aa_attribute_index; i+=2 ) {
		NSString* curr_aa  = [sequence valueOfAttributeAtTime: t andPosition:i];
		NSString* curr_apos = [sequence valueOfAttributeAtTime: t andPosition:i+1];
//		
//		NSLog(@"c_aa:%@ c_pos:%@ m_aa:%@ m_pos:%@", curr_aa, curr_pos, my_aa, my_pos);
		
		if( [curr_aa isEqualToString:my_aa] && [curr_apos isEqualToString:my_apos]) {
			return TRUE;
		}	
	}
	
	return FALSE;
}

-(unsigned int) orderOfMarkovianAssumption {
	return 0;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[super encodeWithCoder:encoder];
	[encoder encodeInt:num_aa_attributes forKey:@"num_aa_attr"];
}

- (id)initWithCoder:(NSCoder *)coder {
	
    if((self = [super initWithCoder:coder])) {
		num_aa_attributes = [coder decodeIntForKey:@"num_aa_attr"];
	}
	
    return self;
}




@end
