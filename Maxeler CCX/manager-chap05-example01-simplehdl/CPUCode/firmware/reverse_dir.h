/*
 * reverse_dir.h
 *
 *  Created on: Nov 18, 2013
 *      Author: ntarano
 */

#ifndef REVERSE_DIR_H_
#define REVERSE_DIR_H_

#include "types.h"

#define T1_ICACHE_LINE_SIZE 32
#define T1_DCACHE_LINE_SIZE 16
#define T1_L2_CACHE_LINE_SIZE 64

void init_l1_reverse_dir(void);

void add_icache_line(int core_id, taddr_opt_t t1_addr, int way);
void add_dcache_line(int core_id, taddr_opt_t t1_addr, int way);

int search_icache(int core_id, taddr_opt_t t1_addr);
int search_dcache(int core_id, taddr_opt_t t1_addr);

int invalidate_icache(int core_id, taddr_opt_t t1_addr);
int invalidate_dcache(int core_id, taddr_opt_t t1_addr);

void icache_invalidate_all_ways(int core_id, taddr_opt_t t1_addr);
void dcache_invalidate_all_ways(int core_id, taddr_opt_t t1_addr);

#endif /* REVERSE_DIR_H_ */
