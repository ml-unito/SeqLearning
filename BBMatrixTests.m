//
//  BBMatrixTests.m
//  SeqLearning
//
//  Created by Roberto Esposito on 22/1/10.
//  Copyright 2010 University of Turin. All rights reserved.
//

#import "BBMatrixTests.h"
#import "BBMatrix.h"

@implementation BBMatrixTests

-(void) testMatrixCreation {
	BBMatrix* matrix = BBMatrix_create(100, 101);
	assert(matrix!=NULL);
	STAssertEquals(BBMatrix_nrows(matrix), (size_t) 100, @"Matrix nrows unproperly set; %d expected, but %d obtained", 100, BBMatrix_nrows(matrix));
	STAssertEquals(BBMatrix_ncols(matrix), (size_t) 101, @"Matrix ncols unproperly set; %d expected but %d obtained", 101, BBMatrix_ncols(matrix));
	BBMatrix_dispose(matrix);
}

-(void) testVectorCreation {
	BBMatrix* vector = BBMatrix_create(100,1);
	assert(vector!=NULL);
	STAssertEquals(BBMatrix_nrows(vector), (size_t) 100, @"Vector size unproperly set; 100 expected, but %d obtained", BBMatrix_nrows(vector));
	BBMatrix_dispose(vector);
}

-(void) testMatrixLeftMultiply {
	BBMatrix* matrix = BBMatrix_create(2,2);
	BBMatrix* vector = BBMatrix_create(1,2);
	
	BBMatrixCell(matrix,0,0)   = 10;
	BBMatrixCell(matrix,0,1)   = 5;
	BBMatrixCell(matrix,1,0)   = 8;
	BBMatrixCell(matrix,1,1)   = 1;
	BBMatrixCell(vector,0,0)   = 7;
	BBMatrixCell(vector,0,1)   = 4;
		
	BBMatrix* result = BBMatrix_multiply(vector, matrix);
	size_t vec_size = BBMatrix_ncols(result);
	STAssertEquals( (size_t) 2, vec_size, @"Multiplication of a 1x2 vector by a 2x2 matrix should return a 1x2 vector, instead a %dx%d matrix obtained", BBMatrix_nrows(result), BBMatrix_ncols(result) );
	STAssertEquals( (float) 102, BBMatrixCell(result,0,0), @"left multiplication error: result[0] expected to be 102, but obtained %f",  BBMatrixCell(result,0,0) );
	STAssertEquals( (float)  39, BBMatrixCell(result,0,1), @"left multiplication error: result[1] expected to be 39, but obtained %f",  BBMatrixCell(result,0,11) );
	
	BBMatrix_dispose(result);
	BBMatrix_dispose(matrix);
	BBMatrix_dispose(vector);
}

-(void) testMatrixRightMultiply {
	BBMatrix* matrix = BBMatrix_create(2,2);
	BBMatrix* vector = BBMatrix_create(2,1);
	
	BBMatrixCell(matrix,0,0) = 10;
	BBMatrixCell(matrix,0,1) = 5;
	BBMatrixCell(matrix,1,0) = 8;
	BBMatrixCell(matrix,1,1) = 1;
	BBMatrixCell(vector,0,0)   = 7;
	BBMatrixCell(vector,1,0)   = 4;
	
	BBMatrix* result = BBMatrix_multiply(matrix,vector);
	size_t vec_size = BBMatrix_nrows(result);
	
	STAssertEquals( (size_t) 2, vec_size, @"Multiplication of a 2x2 matrix by a 2x1 vector should return a 2x1 vector, instead a %dx%d matrix obtained", BBMatrix_nrows(result), BBMatrix_ncols(result) );
	
	BBMatrix_debug_print(result);
	
	STAssertEquals( (float)  90, BBMatrixCell(result,0,0), @"right multiplication error: result[0] expected to be 90, but obtained %f",  BBMatrixCell(result,1,0) );
	STAssertEquals( (float)  60, BBMatrixCell(result,1,0), @"right multiplication error: result[1] expected to be 60, but obtained %f",  BBMatrixCell(result,1,1) );
	
	BBMatrix_dispose(result);
	BBMatrix_dispose(matrix);
	BBMatrix_dispose(vector);
}

-(void) testMatrixTranspose {
	BBMatrix* matrix = BBMatrix_create(2,1);
	BBMatrix_inplace_transpose(matrix);
	STAssertEquals( (size_t) 2, BBMatrix_ncols(matrix), @"Error in transposing matrix" );
	STAssertEquals( (size_t) 1, BBMatrix_nrows(matrix), @"Error in transposing matrix" );
	BBMatrix_inplace_transpose(matrix);
	STAssertEquals( (size_t) 1, BBMatrix_ncols(matrix), @"Error in transposing matrix" );
	STAssertEquals( (size_t) 2, BBMatrix_nrows(matrix), @"Error in transposing matrix" );	
}

-(void) testMatrixElementWiseMultiply {
	BBMatrix* lm = BBMatrix_create(2,2);
	BBMatrix* rm = BBMatrix_create(2,2);
	
	BBMatrixCell(lm,0,0) = 10;
	BBMatrixCell(lm,0,1) = 5;
	BBMatrixCell(lm,1,0) = 8;
	BBMatrixCell(lm,1,1) = 1;

	BBMatrixCell(rm,0,0) = 4;
	BBMatrixCell(rm,0,1) = 3;
	BBMatrixCell(rm,1,0) = 1;
	BBMatrixCell(rm,1,1) = 2;
	
	BBMatrix_inplace_elementwise_multiply(lm, rm);
	
	STAssertEquals( (float) 40, BBMatrixCell(lm,0,0), @"Error in inplace matrix multiplication" );
	STAssertEquals( (float) 15, BBMatrixCell(lm,0,1), @"Error in inplace matrix multiplication" );
	STAssertEquals( (float)  8, BBMatrixCell(lm,1,0), @"Error in inplace matrix multiplication" );
	STAssertEquals( (float)  2, BBMatrixCell(lm,1,1), @"Error in inplace matrix multiplication" );		
}


@end
