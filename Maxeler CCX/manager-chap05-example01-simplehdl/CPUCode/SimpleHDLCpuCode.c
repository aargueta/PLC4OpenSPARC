/**
 * Document: Manager Compiler Tutorial (maxcompiler-manager-tutorial.pdf)
 * Chapter: 5      Example: 1      Name: Simple HDL
 * MaxFile name: SimpleHDL
 * Summary:
 *     Streams data in and out of a design using a custom HDL node which
 *     implements a counter and checks for correctness.
 */
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include <MaxSLiCInterface.h>
#include "Maxfiles.h"

#include "pcx_cpx.h"

#define PKT_SIZE	5

int main() {
	int size = 2 * PKT_SIZE; // two packets
	int sizeBytes = size * sizeof(uint32_t);
	uint32_t *dataIn = malloc(sizeBytes);
	uint32_t *dataInCtl = malloc(sizeBytes);
	uint32_t *dataOut = malloc(sizeBytes);

	uint32_t ctl_valid[PKT_SIZE];
	uint32_t ctl_invalid[PKT_SIZE];

	for (int i = 0; i < size; i++) {
		dataIn[i] = 0;
		ctl_valid[i] = !(i % PKT_SIZE) ? 0x8 : 0x0;
		ctl_invalid[i] = 0;
		dataOut[i] = 0;
	}

	// Initialize Maxeler constructs
	max_file_t *t1_max = SimpleHDL_init();
	max_engine_t *t1DFE = max_load(t1_max, "local:*");
	SimpleHDL_actions_t actions;

	// TODO: set initial size appropriately
	int num_pkts = 1;

	// TODO: run initialization code for the T1

	actions.param_N = num_pkts * 5;
	actions.instream_max_cpx = dataIn;
	actions.instream_max_cpx_ctl = dataInCtl;
	actions.outstream_max_pcx = dataOut;

	printf("Running DFE.\n");
	for (;;) {
		SimpleHDL_run(t1DFE, &actions);
		num_pkts = process((struct pcx_pkt *)dataOut, (struct cpx_pkt *)dataIn);
		// TODO: Set new ctrl depending on num_pkts
		for (int i = 0; i + 3 < size; i += 4) {
			printf("%x_%x_%x_%x\n", dataOut[i], dataOut[i + 1], dataOut[i + 2],
					dataOut[i + 3]);
		}
	}

	max_unload(t1DFE);

	return 0;
}
