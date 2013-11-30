/*
 * uart.h
 *
 *  Created on: Nov 18, 2013
 *      Author: ntarano
 */

#ifndef UART_H_
#define UART_H_

#include "types.h"
#include "pcx_cpx.h"

void process_uart_load(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt,
		taddr_t t1_addr);

void process_uart_store(struct pcx_pkt *pcx_pkt, struct cpx_pkt *cpx_pkt,
		taddr_t t1_addr);

#endif /* UART_H_ */
