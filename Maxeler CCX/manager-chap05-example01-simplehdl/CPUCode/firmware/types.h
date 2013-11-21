/*
 * types.h
 *
 *  Created on: Nov 17, 2013
 *      Author: ntarano
 */

#ifndef TYPES_H_
#define TYPES_H_

/*
 * MB_MEM_ADDR: microblaze memory address
 * UART_ADDR: uart address
 * ETH_ADDR: ethernet address
 * IOB_ADDR: T1 iob address
 */

enum addr_type {
	MB_MEM_ADDR, UART_ADDR, ETH_ADDR, IOB_ADDR
};

typedef unsigned char uchar_t;
typedef unsigned short ushort_t;
typedef unsigned int uint_t;

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long long uint64_t;

typedef uint64_t taddr_t; /* T1 physical address */
typedef uint32_t maddr_t; /* Microblaze address */

/*
 * T1 DRAM physical address space starts from 0 and is normally less than 4GB.
 * T1 DRAM physical address can be represented in a 32-bit integer and it
 * increases the performance of the system by speeding up L2/memory accesses.
 * In REGRESSION_MODE, the DRAM physical address space is not contiguous and
 * the DRAM address may not fit in a 32-bit integer.
 */

#ifdef REGRESSION_MODE
typedef taddr_t taddr_opt_t;
#else
typedef uint32_t taddr_opt_t;
#endif

#define MB_INVALID_ADDR -1U /* invalid microblaze DRAM address */

#ifndef REGRESSION_MODE
#define mbfw_exit(status) exit(status)
#endif

#endif /* TYPES_H_ */
