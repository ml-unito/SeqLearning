//
//  BBHMM.m
//  SeqLearning
//
//  Created by Roberto Esposito on 20/1/10.
//  Copyright 2010 University of Turin. All rights reserved.
//

#import "BBHMM.h"


@implementation BBHMM


// Learning algorithm for HMMs. It is a specialization of the EM
// algorithm that takes into account the particular form of the
// HMM model.
// A great tutorial can be found at: http://www.isi.edu/natural-language/teaching/cs562/2009/readings/B06.pdf
// In brief:
// EM: finds the set Theta of parameters that maximizes the likelyhood
//     of the dataset X taking into account a set Z of hidden variables.
//     The algorithm iterates until convergence two steps.
//     E-step: Find the best possible assignment to Z given the current Theta
//     M-step: Find Theta that maximizes the likelyhood assuming the assignment
//             to Z is the one found in the E-step
// More formally:
//     E-step: set Q(\theta|\theta^{old}) = E_{Z|X\theta^{old}}[\log(P(XZ|\theta)]
//     M-step: \theta^old = argmax_\theta Q(\theta|\theta^old)
//
// In an HMM the algorithm is called Baum-Welch or forward-backward algorithm.
// In this particular case the algorithm is instantiated as follows (crf. C. Bishop,
// "Pattern Recognition and Machine Learning", Springer 2006, Chapter 13).
//
// Q(\theta|\theta^{old}) = \sum_{k=1}^K \gamma(z_{1k}) \log(\pi_k) +
//                        \sum_{n=2}^N \sum_{j=1}^K \sum_{k=1}^K \xi(z_{n-1,j},z_{nk})\log(A_{jk}) +
//                        \sum_{n=1}^N \sum_{k=1}^K \gamma(z_{nk})\log(p(x_n|\phi_k))
// where: j,k,l range over hidden states values indices (K is the number of different values)
//        n ranges over time points (N is the length of the sequence)
//        z_{nk} is a boolean variable that is 1 when the n-th hidden state is equalt to k and 0 otherwise
//        \pi_k is the  parameter that governs the probability of being on state k at time 1
//        \xi(z_{n-1,j},z_{nk}) is the parameter that governs the transition probability from state j
//            at time n-1 to state k at time n
//        p(x_n | phi_k) is the output probability of x_n in state k
//        \gamma(z_{nk}) is the probability that the n-th hidden variable takes value k given the
//            data and the current parameter settings
// it can be shown that the updates for the parameters that maximize the likelyhood are:
//  \pi_k = \gamma(z_{1k}) / \sum_{j=1}^K \gamma(\z_{1j})
//  A_{jk}= \sum_{n=2}^N \xi(z_{n-1,j},z_{nk}) / \sum_{l=1}^K \xi(z_{n-1,j},z_{nl})
// 
// As it is apparent from the above description, it is crucial to evaluate efficiently \gamma(z_{nk}).
// It can be shown that \gamma(\z_n) = \alpha(\z_{n})\beta(\z_n) / P(X)
// where for any n: P(X) = \sum_k \alpha(z_{nk})\beta(z_{nk})
// implying that:
//                  P(X) = \sum_k \alpha(z_{Nk})
// Here \alpha(z_n) and \beta(\z_n) are called respectively the forward and the backward algorithms and
// can be computed by means of dynamic programming in O(nK^2) time.

  
-(NSObject<BBSequenceClassifying>*) learn:(BBSeqSet*) ss {
	[self initWeightsUsingDataset:ss];
	
	while(![self converged]) {
		
	}
}

-(BBVector*) alphaForTime:(size_t) t {
	BBMatrix* cachedResult = [alphaCache cachedObjectForTime:t];
	
	if( cachedResult != NULL )
		return cachedResult;
	
	if(t==0) {
		return ;
	}
	
	// recursive call
	BBMatrix* alphaPrec = [self alphaForTime:t-1];
	
	// main computation
	BBMatrix* result = BBMatrix_multiply(alphaPrec, transitionMatrix);
	BBMatrix_inplace_elementwise_multiply(result, emission_probability_vector);
	
	[alphaCache cacheObject:result forTime:t];
	return result;
}




@end
