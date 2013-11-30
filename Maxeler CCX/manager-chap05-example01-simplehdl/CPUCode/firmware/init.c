/*
* ========== Copyright Header Begin ==========================================
* 
* OpenSPARC T1 Processor File: maxfw_init.c
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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//#include "mbfw_types.h"
#include "firmware/config.h"
//#include "mbfw_reverse_dir.h"
#include "firmware/pcx_cpx.h"
//#include "mbfw_rtl.h"
#include "firmware/gunzip.h"
#include "addr_map.h"

//#include "mbfw_xintc.h"


static uint32_t*
init_ram(int ramSize)
{
	uint32_t* ram = (uint32_t*)malloc(ramSize);
	memset(ram, 0, ramSize);
	return ram;
}


void
generate_poweron_interrupt(struct max_cpx_pkt* max_cpx_pkt)
{
    int  cpu_id;
    struct cpx_pkt  cpx_pkt;
    int core_id;

    core_id = T1_MASTER_CORE_ID;
    cpu_id = T1_MASTER_CPU_ID;

    cpx_pkt_init(&cpx_pkt);

    CPX_PKT_SET_RTNTYP(&cpx_pkt, CPX_PKT_RTNTYP_INT_FLUSH);
    cpx_pkt.data0 = 0x00010001 | (cpu_id << INT_FLUSH_CPU_ID_SHIFT);
    cpx_pkt.data2 = cpx_pkt.data0;
    add_cpx_ctl(&cpx_pkt, max_cpx_pkt);
    return;
}


int
maxfw_init(int t1DRAMSize, char* t1PROMFilename, char* t1RAMDiskFilename, struct max_mem_config* config)
{
	// Initialize T1 DRAM
	uint32_t* t1DRAM = init_ram(t1DRAMSize);
	config->t1_dram_start = t1DRAM;
	config->t1_dram_size = t1DRAMSize;

	// Load PROM
	FILE *PROM_fp = fopen(t1PROMFilename, "rb");
	if(PROM_fp == NULL){
		printf("PROM file not found!\n");
		exit(1);
	}
	fseek(PROM_fp, 0, SEEK_END);
	uint64_t t1PROMSize = ftell(PROM_fp);
	rewind(PROM_fp);
	uint32_t* t1PROM = malloc(t1PROMSize);
	int result = fread(t1PROM, sizeof(char), t1PROMSize, PROM_fp);
	if(result != t1PROMSize){
		printf("PROM file read error:read %d, expected %d\n", result, t1PROMSize);
		exit(1);
	}
	fclose(PROM_fp);
	config->t1_prom_start = t1PROM;
	config->t1_prom_size = t1PROMSize;

	// Load RAM Disk
	/*FILE *RAMDisk_fp = fopen(t1RAMDiskFilename, "rb");
	if(RAMDisk_fp == 0){
		printf("RAMDisk file not found!\n");
		exit(1);
	}
	fseek(RAMDisk_fp, 0, SEEK_END);
	uint64_t t1RAMDiskSize = ftell(RAMDisk_fp);
	printf("RAMDisk found, size= %d\n", t1RAMDiskSize);
	rewind(RAMDisk_fp);
	uint32_t t1RAMDisk = init_ram(t1RAMDiskSize);
	result = fread((char*)t1RAMDisk, sizeof(char), t1RAMDiskSize, RAMDisk_fp);
	if(result != t1RAMDiskSize){
		printf("RAM Disk file read error:read %d, expected %d\n", result, t1RAMDiskSize);
		exit(1);
	}
	config->t1_ram_disk_start = t1RAMDisk;
	config->t1_ram_disk_size = t1RAMDiskSize;
    printf("MaxFW_INFO: Uncompressing ram_disk .....\r\n");
    maxfw_gunzip(t1RamDisk, t1RamDiskSize, *t1DRAM, t1DRAMSize);
    printf("MaxFW_INFO: Uncompressed ram_disk \r\n");*/

    //init_l1_reverse_dir();
	init_addr_map(*config);
	load_mem_config(*config);
    printf("MaxFW_INFO: T1 memory initialization completed.\r\n\r\n");
	
    return 0;
}
