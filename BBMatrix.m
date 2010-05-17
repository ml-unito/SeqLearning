/*
 *  BBMatrix.c
 *  SeqLearning
 *
 *  Created by Roberto Esposito on 21/1/10.
 *  Copyright 2010 University of Turin. All rights reserved.
 *
 */




#include "BBMatrix.h"

#define BBMatrix_vectorcheck(m) ( (m)->ncols == 1 || (m)->nrows == 1 )

// --------------------------------------
#pragma mark BBMatrix
// --------------------------------------


BBMatrix* BBMatrix_create(size_t numrows, size_t numcols) {
	BBMatrix* result = (BBMatrix*) malloc(sizeof(BBMatrix));
	result->ncols = numcols;
	result->nrows = numrows;
	result->data = (float*) malloc(sizeof(float)*numrows*numcols);
	
	return result;
}

void BBMatrix_dispose(BBMatrix* matrix) {
	free(matrix->data);
	free(matrix);
}

float* BBMatrix_rawdata(BBMatrix* matrix) {
	return matrix->data;
}

size_t BBMatrix_nrows(BBMatrix* matrix) {
	return matrix->nrows;
}

size_t BBMatrix_ncols(BBMatrix* matrix)  {
	return matrix->ncols;
}

void BBMatrix_inplace_transpose(BBMatrix* matrix) {
	assert( BBMatrix_vectorcheck(matrix) );
	size_t tmp = matrix->ncols;
	matrix->ncols = matrix->nrows;
	matrix->nrows = tmp;
}


BBMatrix* BBMatrix_left_multiply(BBMatrix* vec, BBMatrix* matrix) {
	// Assuming square matrices (dim(matrix)= KxK)
	// and appropriate vector length (dim(vec)=1xK)
	assert(BBMatrix_ncols(matrix) == BBMatrix_nrows(matrix) &&
		   BBMatrix_ncols(vec) == BBMatrix_nrows(matrix) && 
		   BBMatrix_nrows(vec) == 1);
	
	size_t vec_size = BBMatrix_ncols(vec);
	BBMatrix* result = BBMatrix_create(1, vec_size); // result is a row vector (1xK)

	size_t c, r;
	for(c=0; c<vec_size; ++c) {
		float sum = 0;
		for(r=0; r<vec_size; ++r) {
			sum += BBMatrixCell(vec,0,r) * BBMatrixCell(matrix,r,c);
		}
		
		BBMatrixCell(result,0,c) = sum;
	}
	
	return result;
}

BBMatrix* BBMatrix_right_multiply(BBMatrix* matrix, BBMatrix* vec) {
	// Assuming square matrices (dim(matrix)=KxK)
	// and appropriate vector length (dim(vec)=Kx1)
	assert(BBMatrix_ncols(matrix)==BBMatrix_nrows(matrix) &&		   
		   BBMatrix_nrows(vec) == BBMatrix_ncols(matrix) && 
		   BBMatrix_ncols(vec) == 1);
	
	size_t vec_size = BBMatrix_nrows(vec);
	BBMatrix* result = BBMatrix_create(vec_size,1); // result is col vector (Kx1)
	
	size_t r,c;
	for(r=0; r<vec_size; ++r) {
		float sum = 0;
		for(c=0; c<vec_size; ++c) {
			sum += BBMatrixCell(vec,c,0) * BBMatrixCell(matrix,r,c);
		}
		
		BBMatrixCell(result,r,0) = sum;
	}
	
	return result;	
}


BBMatrix* BBMatrix_multiply(BBMatrix* lm, BBMatrix* rm) {
	if(BBMatrix_vectorcheck(lm)) {
		return BBMatrix_left_multiply(lm, rm);
	}
	
	if(BBMatrix_vectorcheck(rm)) {
		return BBMatrix_right_multiply(lm, rm);
	}
	
	assert(FALSE); // We support only multiplication by a vector
	return NULL;
}


void BBMatrix_debug_print(BBMatrix* matrix) {
	size_t r;
	size_t c;
	for(r=0; r<BBMatrix_nrows(matrix); ++r) {
		for(c=0; c<BBMatrix_ncols(matrix); ++c) {
			printf(" %f", BBMatrixCell(matrix,r,c));
		}
		
		printf("\n");
	}
}


void BBMatrix_inplace_elementwise_multiply(BBMatrix* lm, BBMatrix* rm) {
	size_t r, c;
	assert(BBMatrix_ncols(lm)==BBMatrix_ncols(rm) && BBMatrix_nrows(lm)==BBMatrix_nrows(rm));
	size_t n_rows = BBMatrix_nrows(lm);
	size_t n_cols = BBMatrix_ncols(lm);
	
	for(r=0; r<n_rows; ++r) {
		for(c=0; c<n_cols; ++c) {
			BBMatrixCell(lm,r,c) *= BBMatrixCell(rm,r,c);
		}
	}
}


