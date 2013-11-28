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
#include <inttypes.h>

#include <MaxSLiCInterface.h>
#include "Maxfiles.h"

#define COUNTING_UP   0
#define COUNTING_DOWN 1
#define HOLD_COUNT 2

int main()
{
	const int size = 8;
	const int holdCount = 2;

	int sizeBytes = size * sizeof(uint32_t);
	uint64_t dataIn[]   = {0x00017000, 0x00000000, 0x00000000, 0x00000000, 0x00010001, 0xBAD, 0xBAD, 0xBAD};//malloc(size * sizeof(uint64_t));
	uint32_t dataInCtl[] = {0x18, 0x10, 0x10, 0x10, 0x10, 0x0, 0x0, 0x0};//malloc(sizeBytes);
	uint32_t *dataOut  = malloc(sizeBytes);
	uint32_t *expected = malloc(sizeBytes);

	for (int i = 0; i < size; i++) {
		//dataIn[i] = rand() >> 24;
		//dataInCtl[i] = i % 5;
		dataIn[i] = dataIn[i] | ((uint64_t)(dataInCtl[i]))<<32;
		dataOut[i] = 0xBEEF;
	}

	printf("Running DFE.\n");
	OpenSPARCT1(8,4, dataIn, dataOut);
	for(int i = 0; i < size; i+= 5){
		printf("%" PRIx64 " %" PRIx64 " %" PRIx64 " %" PRIx64 " %" PRIx64 "/ %x %x %x %x %x = %x %x %x %x %x \n",dataIn[i], dataIn[i+1], dataIn[i+2], dataIn[i+3], dataIn[i+4], dataInCtl[i], dataInCtl[i+1], dataInCtl[i+2], dataInCtl[i+3], dataInCtl[i+4], dataOut[i], dataOut[i+1], dataOut[i+2], dataOut[i+3], dataOut[i+4]);
	}


}
