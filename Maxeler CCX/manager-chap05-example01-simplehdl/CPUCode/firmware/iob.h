/*
 * iob.h
 *
 *  Created on: Nov 18, 2013
 *      Author: ntarano
 */

#ifndef IOB_H_
#define IOB_H_

#include "types.h"
#include "pcx_cpx.h"

void process_iob_load(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt,
		taddr_t t1_addr);

void process_iob_store(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt,
		taddr_t t1_addr);

#endif /* IOB_H_ */
