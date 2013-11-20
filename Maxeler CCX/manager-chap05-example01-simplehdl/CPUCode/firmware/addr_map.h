/*
 * addr_map.h
 *
 *  Created on: Nov 18, 2013
 *      Author: ntarano
 */

#ifndef ADDR_MAP_H_
#define ADDR_MAP_H_

#include "types.h"
#include "pcx_cpx.h"

enum addr_type translate_addr(struct pcx_pkt *pcx_pkt, taddr_t t1_addr,
		maddr_t *mb_addr_ptr);

#endif /* ADDR_MAP_H_ */
