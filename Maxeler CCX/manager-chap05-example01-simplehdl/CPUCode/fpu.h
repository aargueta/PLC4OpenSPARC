/*
 * fpu.h
 *
 *  Created on: Nov 18, 2013
 *      Author: ntarano
 */

#ifndef FPU_H_
#define FPU_H_

#include "pcx_cpx.h"

void process_fp_1(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt);
void process_fp_2(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt);

#endif /* FPU_H_ */
