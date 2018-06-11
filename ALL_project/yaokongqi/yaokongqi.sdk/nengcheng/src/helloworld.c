
/*#include <stdio.h>
#include <time.h>
#include "platform.h"
#include "xil_printf.h"
#include "xgpiops.h"
#include "sleep.h"
#include "xil_io.h"
#include "xparameters.h"
#include "xil_types.h"
#include "oled.h"
#include "sensor.h"
#include "bee.h"
#include "fan.h"
#include <string.h>
#include "blueTooth.h"

#include <stdio.h>
#include "xparameters.h"
#include "xil_io.h"
#include "sleep.h"
#include "xil_types.h"
#include "xgpiops.h"

void tran(u16 num, char str[]) {
	char tmp;
	u16 tmp0 ;
	u16 posi = 0 ;
	// 分解
	if( num!=0 ) {
		while(num) {
			tmp0 = num%10 ;
			str[posi] = '0' + tmp0 ;
			num /= 10 ;
			posi++ ;
		}
	} else
		str[posi++] = '0' ;
	str[posi]='\0' ;
	// 倒置
    u16 posiI = 0;
    while( posiI < posi/2 ){
    	tmp = str[posiI] ;
		str[posiI] = str[ (posi-1) - posiI] ;
        str[ (posi-1) - posiI] = tmp ;
	    posiI ++ ;
	}
	return ;
}

void deal(char str[],char str_init[],u16 num){
	char str_num[50] ;
	char danWei[] = "ug/m3";
	strcpy(str, str_init);
	tran(num, str_num);
	strcat(str, str_num);
	strcat(str, danWei);
	return ;
}

int main() {

	OLED_Init();
	OLED_Clear();
	Xil_Out32(XPAR_PWM_CAR_V1_0_0_BASEADDR,20000);
	Xil_Out32(XPAR_PWM_CAR_V1_0_0_BASEADDR+4,3000);

	u16 pm10[1] = { 0 };
	u16 pm25[1] = { 0 };
	u16 pm1[1] = { 0 };
	u16 jq[1] = { 0 };
	u16 theSwitchNum[1] = {0} ; 
	u8  theData[9] ; 
	
	u8 getdata_Ly[80] = {0} ;  // 新添加
	u8 zhiLing[1]  ;    // 新添加
	zhiLing[0] = 5 ;    // 新添加

	init_platform();
	uart_initialize_lanYa() ;
	uart_initialize_yanWu() ;
	uart_initialize_jiaQuan() ;
	fan_initialize(); 
	beep_initialize();

	beep_clr();

	OLED_Clear();
	OLED_ShowString(36, 0, "WELCOME!");

	sleep( 30 ) ;

	set_moShi_yanWu();
	set_moShi_jiaQuan();

	char pm10_str[50] = "";
	char pm25_str[50] = "";
	char pm1_str[50] = "";
	char jq_str[50] = "";

	char pm10_str_init[50] = "PM10 =";
	char pm25_str_init[50] = "PM2.5=";
	char pm1_str_init[50] = "PM1.0=";
	char jq_str_init[50] = "HCHO =";


	int t = 0;
	while (1) {

	    sleep(2) ; // 新添加 
	
		if (t == 0) {

			wenXun_yanWu();     
			//sleep(2);    // 新删除
			getdata_yanWu(pm10,pm25,pm1,theData) ;

			send_to_lanYa( theData ) ;
			get_from_lanYa( getdata_Ly , zhiLing ) ;    // 新添加   
			
			deal(pm10_str,pm10_str_init,pm10[0]) ;
			deal(pm25_str,pm25_str_init,pm25[0]) ;
			deal(pm1_str,pm1_str_init,pm1[0]) ;

			OLED_Clear();
			OLED_ShowString(0, 0, "PM=");
			OLED_ShowString(0, 2, pm10_str);
			OLED_ShowString(0, 4, pm25_str);
			OLED_ShowString(0, 6, pm1_str);

		} else {

			wenXun_jiaQuan() ;
			//sleep(2);  // 新删除
			getdata_jiaQuan(jq,theData);
			
            send_to_lanYa( theData ) ;
			get_from_lanYa( getdata_Ly , zhiLing ) ;    // 新添加 
			
			deal(jq_str,jq_str_init, jq[0]);
            
			OLED_Clear();
			OLED_ShowString(0, 0, "HCHO=");
			OLED_ShowString(0, 2, jq_str);

			if( zhiLing[0] == 5 ){
			  if( jq[0] >=100 ){
                beep_set();
                Xil_Out32(XPAR_PWM_CAR_V1_0_0_BASEADDR+16,2 );
			  }else{
				beep_clr();
				Xil_Out32(XPAR_PWM_CAR_V1_0_0_BASEADDR+16,0 );
			  }
			}

			else if( zhiLing[0] == 1 ){
			  Xil_Out32(XPAR_PWM_CAR_V1_0_0_BASEADDR+16,2 );
			}
			else if( zhiLing[0] == 2 ){
			  Xil_Out32(XPAR_PWM_CAR_V1_0_0_BASEADDR+16,0 );
			}
			else if( zhiLing[0] == 3 ){
			  beep_set();
			}
			else if( zhiLing[0] == 4 ){
			  beep_clr();
			}


		}
		t = 1 - t;
	}

	cleanup_platform();
	return 0;
}*/



