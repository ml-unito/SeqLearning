/*
 *  BBMatrix.h
 *  SeqLearning
 *
 *  Created by Roberto Esposito on 21/1/10.
 *  Copyright 2010 University of Turin. All rights reserved.
 *
 */

#define BBMatrixCell(matrix,x,y) ((matrix)->data[(y)*(matrix)->ncols+(x)])

typedef struct BBMatrix {
	float* data;
	size_t nrows;
	size_t ncols;
} BBMatrix;

BBMatrix* BBMatrix_create(size_t, size_t);
void BBMatrix_dispose(BBMatrix*);

float* BBMatrix_rawdata(BBMatrix*);
size_t BBMatrix_nrows(BBMatrix*);
size_t BBMatrix_ncols(BBMatrix*);

void BBMatrix_inplace_elementwise_multiply(BBMatrix* lm, BBMatrix* rm);
BBMatrix* BBMatrix_multiply(BBMatrix*, BBMatrix*);
void BBMatrix_inplace_transpose(BBMatrix*);


void BBMatrix_debug_print(BBMatrix* matrix);
