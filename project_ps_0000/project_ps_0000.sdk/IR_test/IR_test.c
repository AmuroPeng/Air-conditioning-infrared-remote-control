/*
 * IR_test.c
 *
 *  Created on: 2018年6月11日
 *      Author: Amuro
 */


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
	int test = 123321;
	while(1){
		if(cnt==0){
			a = 149824;
			b = 8274;
			c = 134479872;
			cnt = 1;
		}
		else {
			a = 150336;
			b = 8274;
			c = 134479880;
			cnt = 0;
		}
	Xil_Out32(XPAR_IR_V1_0_0_BASEADDR,133184);
	Xil_Out32(XPAR_IR_V1_0_0_BASEADDR+4,8274);
	Xil_Out32(XPAR_IR_V1_0_0_BASEADDR+8,134479878);
	usleep(1000000);
	test = Xil_In32(XPAR_IR_V1_0_0_BASEADDR+12);
	usleep(1000000);
	}

}


