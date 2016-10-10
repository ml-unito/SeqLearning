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
//  TFBSPredictionFeaturesManager.m
//  SeqLearning
//
//  Created by Roberto Esposito on 22/12/08.
//  Copyright 2008 University of Turin. All rights reserved.
//

#import <SeqLearning/BBTFBSPredictionFeaturesManager.h>
#import <SeqLearning/BBFeature.h>
#import <SeqLearning/BBTFBSPredictionAAPosFeature.h>
#import <SeqLearning/BBTFBSPredictionNuclChainFeature.h>
#import <SeqLearning/BBTFBSPredictionNuclFeature.h>
#import <SeqLearning/BBTFBSPredictionNuclPosFeature.h>
#import <SeqLearning/BBExceptions.h>

@implementation BBTFBSPredictionFeaturesManager

-(NSMutableArray*) arrayWithFeaturesUsingDataSet:(BBSeqSet*) dataset; {	
	BBFeature* feature;
	NSMutableArray* featureSet;
	
	featureSet = [NSMutableArray arrayWithCapacity:4000];
	unsigned int lastCategory = 0;
	
	char* aa[22] = {"A", "C", "D", "E", "F", "G", "H", "I", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "V", "Y", "W", "-", "?"};
	BBAttributeDescription* links_des = [[dataset attributeDescriptions] objectForKey:@"attr-aa_1_pos"];
	if(links_des==nil)
		@throw [NSException exceptionWithName:BBGenericError 
									   reason:@"Cannot access attribute description for attribute named:attr-aa_1_pos" 
									 userInfo:nil];
	
	NSSet* link_names = (NSSet*) [links_des info];
	unsigned int links_count = [link_names count];
	char** links = (char**) malloc( sizeof(char*) * links_count );
	
	NSEnumerator* link_enumerator = [link_names objectEnumerator];
	NSString* link_name;
	int pos = 0;
	while( (link_name = [link_enumerator nextObject]) ) {
		links[pos] = (char*) malloc(sizeof(char[5]));
		[link_name getCString: links[pos]
					maxLength: 5
					 encoding: NSASCIIStringEncoding];
		pos++;
	}
	
	//char* links[12] = {"-1", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11"};
	
	char* nucleotides[6] = {"A", "C", "G", "T", "M", "-"};
	int aa_i, link_i, nucleotide_i;
	
	for( nucleotide_i=0; nucleotide_i<6; ++nucleotide_i ) {
		feature = [[[BBTFBSPredictionNuclFeature alloc] init] autorelease];
		[feature setParameters:[NSDictionary dictionaryWithObject: [NSString stringWithFormat:@"%s", nucleotides[nucleotide_i]]
														   forKey: BBTFBSPredictionNuclFeatureNuclKey]];
		[featureSet addObject:feature];
		[_featuresToMutexCategoryMapper setObject: [NSNumber numberWithInt:lastCategory]
										   forKey: feature];
	}
	
	lastCategory++;
	
	
	/* --- Vertical features ---
	 * There are 22 * 12 * 6 AAPos features. In facts there are:
	 * 20 AA + '?' + '-'
	 * 11 Link positions + '-1'
	 * 4 Nucleotides + 'M' pseudo nucleotide + '-'
	 */

	// finds out the number of aa attributes
	unsigned int num_aa_attributes = 0;
	NSDictionary* attr_descriptions = [dataset attributeDescriptions];
	for( NSString* attr_name in attr_descriptions ) {
		if( [attr_name hasPrefix:@"attr-aa"] )
			++num_aa_attributes;
	}
	num_aa_attributes /= 2;
	
	int n_pos;
	for( n_pos = 0; n_pos < 10; ++n_pos ) {
		for( aa_i=0; aa_i<22; ++aa_i ) {
			for( link_i=0; link_i<links_count; ++link_i ) {
				for( nucleotide_i=0; nucleotide_i<6; ++nucleotide_i ) {
					// features do not need to consider unknown aminoacids 
					if( !strcmp(aa[aa_i], "?") )
						continue;
					
					feature = [[[BBTFBSPredictionAAPosFeature alloc] initWithNumAAAttributes:num_aa_attributes] autorelease];
					[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
											[NSString stringWithFormat:@"%s",aa[aa_i]], BBTFBSPredictionAAPosFeatureAAKey,
											[NSString stringWithFormat:@"%s",links[link_i]], BBTFBSPredictionAAPosFeatureAPosKey,
											[NSString stringWithFormat:@"%s", nucleotides[nucleotide_i]], BBTFBSPredictionAAPosFeatureNuclKey,
											[NSNumber numberWithInt:n_pos], BBTFBSPredictionAAPosFeatureNPosKey,
											nil]];
					[featureSet addObject:feature];
					[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory++]
													   forKey:feature];
				}
			}
		}		
	}
	
	for( n_pos = 0; n_pos < 10; ++n_pos ) {
		for( nucleotide_i=0; nucleotide_i<6; ++nucleotide_i ) {
			feature = [[[BBTFBSPredictionNuclPosFeature alloc] init] autorelease];
			[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%s", nucleotides[nucleotide_i]], BBTFBSPredictionNuclPosFeatureNuclKey,
									[NSNumber numberWithInt:n_pos], BBTFBSPredictionNuclPosFeaturePosKey,
									nil]];
			[featureSet addObject:feature];
			[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory++]
											   forKey:feature];
		}
	}
	
	
	/* --- Horizontal features --- 
	 All possible pairs (nucl,nucl) are codified.
	 */
	
	int nucl1_i;
	int nucl2_i;
	for(nucl1_i=0; nucl1_i<6; ++nucl1_i) {
		for(nucl2_i=0; nucl2_i<6; ++nucl2_i) {
			feature = [[[BBTFBSPredictionNuclChainFeature alloc] init] autorelease];
			[feature setParameters:[NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%s", nucleotides[nucl1_i]], BBTFBSPredictionNuclChainPrevNuclKey,
									[NSString stringWithFormat:@"%s", nucleotides[nucl2_i]], BBTFBSPredictionNuclChainCurrentNuclKey,
									nil]];
			[featureSet addObject:feature];
			[_featuresToMutexCategoryMapper setObject:[NSNumber numberWithInt:lastCategory]
											   forKey:feature];			
									
		}
	}
	
	
	
	return featureSet;
}


@end
