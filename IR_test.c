/*
 * IR_test.c
 *
 *  Created on: 2018年6月10日
 *      Author: Amuro
 */

#include <stdio.h>
#include "xparameters.h"
#include "xil_io.h"
#include "sleep.h"
#include "xil_types.h"

int main()
{
	int cnt=0;
	int a = 0;
	int b = 2;
	int c = 0;
	while(1){
		if(cnt==0){
			a = 2454717450U;
			c = 134479872;
			cnt = 1;
		}
		else {
			a = 2463106058U;
			c = 134479880;
			cnt = 0;
		}
	Xil_Out32(XPAR_IR_V1_0_0_BASEADDR,a);
	Xil_Out32(XPAR_IR_V1_0_0_BASEADDR+4,b);
	Xil_Out32(XPAR_IR_V1_0_0_BASEADDR+8,c);
	usleep(1000000);
	}

}


