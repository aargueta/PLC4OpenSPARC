/**
 * Document: Manager Compiler Tutorial (maxcompiler-manager-tutorial.pdf)
 * Chapter: 5      Example: 1      Name: Simple HDL
 * MaxFile name: SimpleHDL
 * Summary:
 *     Streams data in and out of a design using a custom HDL node which
 *     implements a counter and checks for correctness.
 */
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#include <MaxSLiCInterface.h>
#include "Maxfiles.h"

#include "firmware/init.h"
#include "firmware/pcx_cpx.h"
#include "firmware/types.h"

#define CPX_PKT_WORDS 5
#define PCX_PKT_WORDS 4
int main()
{
	char* prom = "/rsghome/aargueta/manager-chap05-example01-simplehdl/manager-chap05-example01-simplehdl/CPUCode/1c1t_prom.bin";
	char* ramDisk = "/rsghome/aargueta/manager-chap05-example01-simplehdl/manager-chap05-example01-simplehdl/CPUCode/mmult.qed.mem.image.gz";
	struct max_mem_config* mem_config = malloc(sizeof(struct max_mem_config));
	maxfw_init(0x10000000, prom, ramDisk, mem_config);

	struct max_cpx_pkt* powerOn = malloc(sizeof(struct cpx_pkt));
	struct pcx_pkt* powerOnResponse = malloc(sizeof(struct pcx_pkt));
	generate_poweron_interrupt(powerOn);

	printf("MaxFW_INFO: Powering on OpenSPARC T1 \r\n");

	OpenSPARCT1(8,4,1, (uint64_t*)powerOn, (uint32_t*)powerOnResponse);
	print_pcx_pkt(powerOnResponse);

	struct cpx_pkt* cpx_pkt = malloc(2*sizeof(struct cpx_pkt));
	struct max_cpx_pkt* max_cpx_pkt = malloc(2*sizeof(struct max_cpx_pkt));
	struct pcx_pkt* pcx_pkt = powerOnResponse;

	printf("Boot response received, entering emulation loop\n");
	int num_packets = 0;
	for(int i = 0; i < 100000; i++){
		num_packets = process(pcx_pkt, cpx_pkt);
		add_cpx_ctl(cpx_pkt, max_cpx_pkt);
		if(i > 31240)
			print_max_cpx_pkt(max_cpx_pkt);
		if(num_packets != 1){
			printf("Packet #%d requires double packet response!!! \n", i);
			add_cpx_ctl(&(cpx_pkt[1]),&(max_cpx_pkt[1]));
			print_max_cpx_pkt(&(max_cpx_pkt[1]));
		}

		//printf("Packet #%d processed\n", i);

		OpenSPARCT1(num_packets * 8, 4, 0, (uint64_t*)max_cpx_pkt, (uint32_t*)pcx_pkt);
		//print_pcx_pkt(pcx_pkt);
		if( i > 31240){
			printf("Pkt#%d:\t", i + 1);
			printf(" 0x%x ", pcx_pkt->addr_lo);
			printf("T%d\n", PCX_PKT_GET_RQTYP(pcx_pkt));
			print_pcx_pkt(pcx_pkt);
		}
	}
}
