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
	OpenSPARCT1(8,4, (uint64_t*)powerOn, (uint32_t*)powerOnResponse);
	print_pcx_pkt(powerOnResponse);

	struct cpx_pkt* cpx_pkt = malloc(sizeof(struct cpx_pkt));
	struct max_cpx_pkt* max_cpx_pkt = malloc(sizeof(struct max_cpx_pkt));
	struct pcx_pkt* pcx_pkt = powerOnResponse;
	printf("Boot response received, entering emulation loop\n");
	for(int i = 0; i < 10; i++){
		process(pcx_pkt, cpx_pkt);
		add_cpx_ctl(cpx_pkt, max_cpx_pkt);
		printf("Packet #%d processed\n", i);
		OpenSPARCT1(8, 4, (uint64_t*)max_cpx_pkt, (uint32_t*)pcx_pkt);
		printf("Packet #%d received:\n", i + 1);
		print_pcx_pkt(pcx_pkt);
	}
}
