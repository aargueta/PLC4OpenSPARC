/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: maxfw_init.h
* Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
* DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
* 
* The above named program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License version 2 as published by the Free Software Foundation.
* 
* The above named program is distributed in the hope that it will be 
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
* 
* You should have received a copy of the GNU General Public
* License along with this work; if not, write to the Free Software
* Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
* 
* ========== Copyright Header End ============================================
*/
#ifndef MAXFW_INIT_H_
#define MAXFW_INIT_H_



#ifdef  __cplusplus
extern "C" {
#endif


#include "firmware/pcx_cpx.h"

void generate_poweron_interrupt(struct max_cpx_pkt* max_cpx_pkt);

int maxfw_init(int t1DRAMSize, char* t1PROMFilename, char* t1RAMDiskFilename, struct max_mem_config* config);

#ifdef  __cplusplus
}
#endif


#endif /* #ifndef MAXFW_INIT_H_ */
