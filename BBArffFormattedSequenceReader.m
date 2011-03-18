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
//  BBArffFormattedSequenceReader.m
//  SeqLearning
//
//  Created by Roberto Esposito on 25/7/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SeqLearning/BBArffFormattedSequenceReader.h>
#import <SeqLearning/BBExceptions.h>

@implementation BBArffFormattedSequenceReader


-(id)init {
	if( (self = [super init]) ) {
		BBFieldsDelimiterString=@",";
		BBCommentMarkerString=@"%";
		_knownDescriptions = nil;
		_scanner = nil;
		_preferredFeaturesManagerClassName = nil;
	}
	
	return self;
}

-(void) setPreferredFeaturesManagerClassName:(NSString*) managerName {
	if(_preferredFeaturesManagerClassName!=nil)
		[_preferredFeaturesManagerClassName autorelease];
	
	_preferredFeaturesManagerClassName = [managerName retain];
}

-(void) dealloc {
	if( _knownDescriptions!=nil ) {
		[_knownDescriptions release];
	}
	
	if( _scanner!=nil ) {
		[_scanner release];
	}
	
	[super dealloc];
}

-(void) initAttributeDescriptions {
	if(_knownDescriptions!=nil) {
		[_knownDescriptions release];
	}
	
	_knownDescriptions = [[NSMutableDictionary alloc] init];
}

-(void) setScanner:(NSScanner*) scanner {
	[_scanner autorelease];
	_scanner = [scanner retain];
}

-(void) skipHeader {
	NSAssert(_scanner!=nil, @"skipHeader message received, but _scanner is not initialized");
	[_scanner scanString:@"@RELATION" intoString:nil];
}

-(BOOL) parseAttributeDefinitionNumber:(unsigned int) n fromString:(NSString*) def {
	NSScanner* scanner = [NSScanner scannerWithString:def];
	
	if([scanner scanString:@"@MANAGER" intoString:nil]==YES) {
		NSString* managerName;
		if([scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet]
							   intoString:&managerName]) {
			[self setPreferredFeaturesManagerClassName:managerName];
			return FALSE;
		}
	}
		
	
	
	if([scanner scanString:@"@ATTRIBUTE" intoString:nil]==NO) {
		NSString* errMsg = [NSString stringWithFormat:
			@"Parsing error reading attribute number %d from string ``%@''. @Attribute expected, but not found",
			n, def];
		
		NSLog(@"%@", errMsg);
		return FALSE;
	}
	
	NSString* attributeName;
	[scanner scanUpToString:@" " intoString:&attributeName];
	
	if( [scanner scanString:@"NUMERIC" intoString:nil]==YES ) {
		[_knownDescriptions setObject:
			[BBAttributeDescription descriptionWithType:BBAttributeTypeNumber
											   position:n
												andInfo:nil]
							   forKey:attributeName];
	} else if( [scanner scanString:@"STRING" intoString:nil]==YES ) {
		[_knownDescriptions setObject:
			[BBAttributeDescription descriptionWithType:BBAttributeTypeString
											   position:n
												andInfo:nil]
							   forKey:attributeName];
	} else if( [scanner scanString:@"{" intoString:nil]==YES ) {
		NSString* nameList;
		if([scanner scanUpToString:@"}" intoString:&nameList]==NO) {
			NSString* errMsg = [NSString stringWithFormat:
				@"Parens do not match in reading nominal attribute in string ``%@''.",
				def];
			@throw [NSException exceptionWithName:BBAttributeReadingException
										   reason:errMsg
										 userInfo:nil];
		}
		
		NSArray* names = [nameList componentsSeparatedByString:@","];
		NSMutableArray* trimmedNames = [NSMutableArray arrayWithCapacity:[names count]];
		int i;
		for(i=0; i<[names count]; ++i) {
			[trimmedNames addObject:[[names objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
		}
				
		NSSet* namesSet = [NSSet setWithArray:trimmedNames];
				
		[_knownDescriptions setObject:
			[BBAttributeDescription descriptionWithType:BBAttributeTypeNominal
											   position:n
												andInfo:namesSet]
							   forKey:attributeName];
	} else {
		NSString* errMsg = [NSString stringWithFormat:
			@"Parsing error reading string ``%@''. The type definition "
			@" for attribute named ``%@'' does not match any known type."
			@" One of ``STRING,NUMERIC,{..}'' expected, but not found.",
			attributeName,	def];
		@throw [NSException exceptionWithName:BBAttributeReadingException
									   reason:errMsg
									 userInfo:nil];
	}
	
	return TRUE;
}



-(NSString*) stringWithMainData  {
	[_scanner scanString:@"@DATA" intoString:nil];
	unsigned int curr_location = [_scanner scanLocation];
	NSString* string = [_scanner string];
	return [string substringFromIndex:curr_location];
}


-(void) setFileName:(NSString*) fileName {
	[self initAttributeDescriptions];
	NSStringEncoding enc=NSASCIIStringEncoding;
	NSError* error=nil;
	[self setScanner:[NSScanner scannerWithString:[NSString stringWithContentsOfFile: fileName encoding:enc error: &error]]];
	if( error!=nil ) {
		@throw [NSException exceptionWithName:BBSequenceReadingException
									   reason: [NSString stringWithFormat:
										   @"Error opening dataset file, reason:``%@''", [error localizedFailureReason]]
									 userInfo:nil];
	}
}


-(void) readAttributesDescriptions {
	NSAssert( _scanner!=nil, @"readAttributesDescriptions message received, but _scanner is not initialized" );
	[_scanner setCaseSensitive:FALSE];
	[self skipHeader];
	
	NSString* attributeDefinitionsString;
	[_scanner scanUpToString:BBLinesDelimiterString intoString:nil];
	[_scanner scanUpToString:@"@DATA" intoString: &attributeDefinitionsString];
	NSArray* attributesDefinitions = 
		[attributeDefinitionsString  componentsSeparatedByString:BBLinesDelimiterString];
	
	NSEnumerator* attributesEnumerator = [attributesDefinitions objectEnumerator];
	NSString* attributeDefinition;
	int n=0;
	while( (attributeDefinition = [attributesEnumerator nextObject]) ) {
		if(![attributeDefinition isEqualToString:@""]) {
			if([self parseAttributeDefinitionNumber:n fromString:attributeDefinition])
				++n;			
		}
	}
	
	[self setAttributeDescriptions:_knownDescriptions];
}


-(BBSeqSet*) readSeqSet {
	[self setAttributeDescriptions:_knownDescriptions];
	NSString* mainData = [self stringWithMainData];
	BBSeqSet* seqSet = [super readSeqSetFromString:mainData];	
	if( _preferredFeaturesManagerClassName != nil )
		[seqSet setPreferredFeaturesManagerClassName:_preferredFeaturesManagerClassName];
	
	return seqSet;
}


-(NSMutableDictionary*) attributeDescriptions {
	return _knownDescriptions;
}

@end
