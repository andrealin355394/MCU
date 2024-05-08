/*----------------------------------------------------------------------------*/
/* Includes                                                                   */
/*----------------------------------------------------------------------------*/
#include "DrvCLOCK.h"
#include "Display.h"
#include "my define.h"
#include "DrvREG32.h"
#include "SpecialMacro.h"
#include "stdint.h"
#include "HY16F3981.h"
#include "DrvLCD.h"
#include "Display.h"
#include "System.h"
#include "DrvADC.h"
#include "DrvPMU.h"
#include "DrvGPIO.h"
#include "DrvIA.h"
#include "DrvFlash.h"
/*----------------------------------------------------------------------------*/
/* STRUCTURES                                                                 */
/*----------------------------------------------------------------------------*/
volatile typedef union _MCUSTATUS
{
  char  _byte;
  struct
  {
    unsigned b_ADCdone:1;
    unsigned b_TMAdone:1;
    unsigned b_TMBdone:1;
    unsigned b_TMC0done:1;
    unsigned b_TMC1done:1;
    unsigned b_RTCdone:1;
    unsigned b_UART_TxDone:1;
    unsigned b_UART_RxDone:1;
  };
} MCUSTATUS;
volatile typedef union _PTINTSTATUS
{
  char  _byte;
  struct
  {
    unsigned b_PTINT0done:1;
    unsigned b_PTINT1done:1;
    unsigned b_PTINT2done:1;
    unsigned b_PTINT3done:1;
    unsigned b_PTINT4done:1;
    unsigned b_PTINT5done:1;
    unsigned b_PTINT6Done:1;
    unsigned b_PTINT7Done:1;
  };
} PTINTSTATUS;
/*----------------------------------------------------------------------------*/
/* DEFINITIONS                                                                */
/*----------------------------------------------------------------------------*/
#define KEY_PORT E_PT3
#define KEYIN0 BIT0
#define KEYIN1 BIT5

int TH[20]={16,17,18,19,20,
			21,22,23,24,25,
			26,27,28,29,30,
			31,32,33,34,35};
int TH_ohm[20]={150089,143314,136882,130774,124973,
				119461,114222,109241,104505,100000,
				95713,91633,87749,84050,80527,
				77170,73971,70922,68014,65241};
int IR[51]={0,1,2,3,4,
			5,6,7,8,9,
			10,11,12,13,14,
			15,16,17,18,19,
			20,21,22,23,24,
			25,26,27,28,29,
			30,31,32,33,34,
			35,36,37,38,39,
			40,41,42,43,44,
			45,46,47,48,49,
			50};
int IRV[51]={0,0,0,0,0,
			0,0,0,0,0,
			-877,-822,-768,-713,-657,
			-601,-545,-487,-429,-370,
			-311,-251,-189,-127,-64,
			0,65,131,198,266,
			336,406,477,550,623,
			698,774,850,928,1007,
			1086,1167,1248,1331,1414,
			1498,1582,1667,1753,1838,
			1925};
/*----------------------------------------------------------------------------*/
/* Global CONSTANTS                                                           */
/*----------------------------------------------------------------------------*/
MCUSTATUS  MCUSTATUSbits;
PTINTSTATUS  PT3INTSTATUSbits;
int ADCData;
int	K_ohm;
float	ADC1,ADC2,ADC_Th,ADC_IR,ADGain;
char i;
/*----------------------------------------------------------------------------*/
/* Function PROTOTYPES                                                        */
/*----------------------------------------------------------------------------*/
void Delay(unsigned int num);
void InitalADCTH(void);
void InitalADCIR(void);
void ADCThmistor(void);
void ADCIR(void);
void temptableTH(void);
void temptableIR(void);
void ColdJunction(void);
int	Temp,coldvolt;
float	Thmopile_V;
int	Thmopile;
/*----------------------------------------------------------------------------*/
/* Main Function                                                              */
/*----------------------------------------------------------------------------*/
int main(void)
{
	K_ohm=100000;

  DrvCLOCK_EnableHighOSC(E_INTERNAL,50);     // Select HAO 2MHz
  DrvCLOCK_SelectIHOSC(0);
  DrvCLOCK_CalibrateHAO(0);
  DrvGPIO_ClkGenerator(E_HS_CK,1);                      //Set IO sampling clock input source is HS_CK
  DrvGPIO_Open(KEY_PORT,KEYIN1|KEYIN0,E_IO_INPUT);      //set PT3.0/PT3.5 INPUT
  DrvGPIO_Open(KEY_PORT,KEYIN1|KEYIN0,E_IO_PullHigh);   //enable PT3.0/PT3.5 pull high R
  DrvGPIO_Open(KEY_PORT,KEYIN1|KEYIN0,E_IO_IntEnable);  //PT3.0/PT3.5 interrupt enable
  DrvGPIO_IntTrigger(KEY_PORT,KEYIN1|KEYIN0,E_N_Edge);  //PT3.0/PT3.5 interrupt trigger method is negative edge
  DrvGPIO_ClearIntFlag(KEY_PORT,KEYIN1|KEYIN0);         //clear PT3 interrupt flag
  DisplayInit();
  ClearLCDframe();
  SYS_EnableGIE(4,0x1FF);  //Enable GIE(Global Interrupt)
  MCUSTATUSbits._byte = 0;
  PT3INTSTATUSbits._byte = 0;

  if(DrvGPIO_GetBit(E_PT3,0)==0)
  {
	  PT3INTSTATUSbits.b_PTINT0done=0;
	  while(1)
	  {
		  InitalADCIR();
		  DrvIA_SetIAInputChannel(IA_Input_AIO1,IA_Input_AIO0);
		  DrvADC_CombFilter(DISABLE);   //DISABLE comb filter
		  DrvADC_CombFilter(ENABLE);   //Enable comb filter
		  MCUSTATUSbits.b_ADCdone=0;
		  while(MCUSTATUSbits.b_ADCdone==0);
		  ADC1=ADCData;

		  DrvIA_SetIAInputChannel(IA_Input_AIO0,IA_Input_AIO1);
		  DrvADC_CombFilter(DISABLE);   //DISABLE comb filter
		  DrvADC_CombFilter(ENABLE);   //Enable comb filter
		  MCUSTATUSbits.b_ADCdone=0;
		  while(MCUSTATUSbits.b_ADCdone==0);
		  ADC2=ADCData;

		  ADC_IR=(ADC1-ADC2)/2;
		  LCD_DATA_DISPLAY(ADC_IR);
		  if(PT3INTSTATUSbits.b_PTINT0done==1)
			  break;
	  }
	  ADGain=8500000/ADC_IR;
	  SYS_DisableGIE();
	  DrvFlash_Burn_Word(0xF000,0x2000,ADGain);
	  SYS_EnableGIE(4,0x1FF);
  }

  ADGain=ReadWord(0xF000);
  while(1)
  {
	  ADCThmistor();			//ADC_Th
	  temptableTH();			//Temp
	  ColdJunction();			//coldvolt
	  ADCIR();					//ADC_IR
	  Thmopile_V=ADC_IR+coldvolt;
	  temptableIR();			//Thmopile
	  LCD_DATA_DISPLAY(Thmopile);
  }
  return 0;
}

/*----------------------------------------------------------------------------*/
/* Function Name: HW0_ISR()                                                   */
/* Description  : I2C/UART/SPI interrupt Service Routine (HW0).               */
/* Arguments    : None.                                                       */
/* Return Value : None.                                                       */
/* Remark       :                                                             */
/*----------------------------------------------------------------------------*/
void HW0_ISR(void)
{

}

/*----------------------------------------------------------------------------*/
/* Function Name: HW1_ISR()                                                   */
/* Description  : WDT & RTC & Timer A/B/C interrupt Service Routine (HW1).    */
/* Arguments    : None.                                                       */
/* Return Value : None.                                                       */
/* Remark       :                                                             */
/*----------------------------------------------------------------------------*/
void HW1_ISR(void)
{

}

/*----------------------------------------------------------------------------*/
/* Function Name: HW2_ISR()                                                   */
/* Description  : ADC interrupt Service Routine (HW2).                        */
/* Arguments    : None.                                                       */
/* Return Value : None.                                                       */
/* Remark       :                                                             */
/*----------------------------------------------------------------------------*/
void HW2_ISR(void)
{
	ADCData=DrvADC_GetConversionData()>>16;
	MCUSTATUSbits.b_ADCdone=1;
}

/*----------------------------------------------------------------------------*/
/* Function Name: HW3_ISR()                                                   */
/* Description  : OPA interrupt Service Routine (HW3).                        */
/* Arguments    : None.                                                       */
/* Return Value : None.                                                       */
/* Remark       :                                                             */
/*----------------------------------------------------------------------------*/
void HW3_ISR(void)
{

}

/*----------------------------------------------------------------------------*/
/* Function Name: HW4_ISR()                                                   */
/* Description  : PT3 interrupt Service Routine (HW4).                        */
/* Arguments    : None.                                                       */
/* Return Value : None.                                                       */
/* Remark       :                                                             */
/*----------------------------------------------------------------------------*/
void HW4_ISR(void)
{
	uint32_t PORT_IntFlag;

	PORT_IntFlag=DrvGPIO_GetIntFlag(KEY_PORT);
	if((PORT_IntFlag&KEYIN0)==KEYIN0)
	{
	   PT3INTSTATUSbits.b_PTINT0done=1;
	}
	if((PORT_IntFlag&KEYIN1)==KEYIN1)
	{
	   PT3INTSTATUSbits.b_PTINT5done=1;
	}
	DrvGPIO_ClearIntFlag(KEY_PORT,KEYIN1|KEYIN0);       //clear PT3.0/PT3.5 interrupt flag
}

/*----------------------------------------------------------------------------*/
/* Function Name: HW5_ISR()                                                   */
/* Description  : PT2 interrupt Service Routine (HW5).                        */
/* Arguments    : None.                                                       */
/* Return Value : None.                                                       */
/* Remark       :                                                             */
/*----------------------------------------------------------------------------*/
void HW5_ISR(void)
{

}

/*----------------------------------------------------------------------------*/
/* Function Name: tlb_exception_handler()                                     */
/* Description  : Exception Service Routines.                                 */
/* Arguments    : None.                                                       */
/* Return Value : None.                                                       */
/* Remark       :                                                             */
/*----------------------------------------------------------------------------*/
void tlb_exception_handler()
{
  asm("nop"); //procedure define by customer.
  asm("nop");
}

/*----------------------------------------------------------------------------*/
/* Software Delay Subroutines                                                 */
/*----------------------------------------------------------------------------*/
void Delay(unsigned int num)
{
  for(;num>0;num--)
  asm("NOP");
}

/*----------------------------------------------------------------------------*/
/* End Of File                                                                */
/*----------------------------------------------------------------------------*/
void ADCThmistor(void)
{
	InitalADCTH();
	DrvADC_SetADCInputChannel(REFO_I,ADC_Input_AIO4);
	DrvADC_CombFilter(DISABLE);   //DISABLE comb filter
	DrvADC_CombFilter(ENABLE);   //Enable comb filter
	MCUSTATUSbits.b_ADCdone=0;
	while(MCUSTATUSbits.b_ADCdone==0);
	ADC1=ADCData;
	MCUSTATUSbits.b_ADCdone=0;

	DrvADC_SetADCInputChannel(ADC_Input_AIO4,VDD3V5_VSS);
	DrvADC_CombFilter(DISABLE);   //DISABLE comb filter
	DrvADC_CombFilter(ENABLE);   //Enable comb filter
	MCUSTATUSbits.b_ADCdone=0;
	while(MCUSTATUSbits.b_ADCdone==0);
	ADC2=ADCData;
	MCUSTATUSbits.b_ADCdone=0;
	ADC_Th=ADC2/ADC1*K_ohm;
}
void temptableTH(void)
{
	float count1;
	float tempH,tempL;
	char count2;
	unsigned char a=0;
	unsigned char b=0,max=19,min=0;
	a=(max+min)/2;
	b=a+1;
	while(1)
	{
		tempH=TH_ohm[a+1];
		tempL=TH_ohm[a];
		if(ADC_Th>tempH&&ADC_Th<=tempL)
			break;
		else
		{
			b=b/2;
			if(b==0)
				b=1;
			if(ADC_Th>tempL)
				a=a-b;
			else if(ADC_Th<=tempH)
				a=a+b;
			if(a<min||a>max)
				break;
		}

	}
	count1=(tempL-tempH)/100;
	count2=(ADC_Th-tempL)/count1;
	Temp=TH[a]*100-count2;
}
void ColdJunction(void)
{
	int tempH,tempL;
	float Temp_rem;
	unsigned char a=0;
	unsigned char b=0,max=50,min=0;
	a=(max+min)/2;
	b=a+1;
	while(1)
	{
		tempH=IR[a+1];
		tempL=IR[a];
		if((Temp/100)<tempH&&(Temp/100)>=tempL)
			break;
		else
		{
			b=b/2;
			if(b==0)
				b=1;
			if((Temp/100)<tempL)
				a=a-b;
			else if((Temp/100)>=tempH)
				a=a+b;
			if(a<min||a>max)
				break;
		}
	}
	Temp_rem=(Temp%100)*(IRV[a+1]-IRV[a])/100;
	coldvolt=IRV[a]+Temp_rem;
}
void ADCIR(void)
{
		InitalADCIR();
		DrvIA_SetIAInputChannel(IA_Input_AIO1,IA_Input_AIO0);
	  	DrvADC_CombFilter(DISABLE);   //DISABLE comb filter
	  	DrvADC_CombFilter(ENABLE);   //Enable comb filter
	  	MCUSTATUSbits.b_ADCdone=0;
	  	while(MCUSTATUSbits.b_ADCdone==0);
	  	ADC1=ADCData;

	  	DrvIA_SetIAInputChannel(IA_Input_AIO0,IA_Input_AIO1);
	  	DrvADC_CombFilter(DISABLE);   //DISABLE comb filter
	  	DrvADC_CombFilter(ENABLE);   //Enable comb filter
	  	MCUSTATUSbits.b_ADCdone=0;
	  	while(MCUSTATUSbits.b_ADCdone==0);
	  	ADC2=ADCData;

	  	ADC_IR=(ADC1-ADC2)/2;
	  	ADC_IR=ADC_IR*ADGain/10000;
}
void temptableIR(void)
{
	float count1;
	float tempH,tempL;
	char count2;
	unsigned char a=0;
	unsigned char b=0,max=50,min=0;
	a=(max+min)/2;
	b=a+1;
	while(1)
	{
		tempH=IRV[a+1];
		tempL=IRV[a];
		if(Thmopile_V<tempH&&Thmopile_V>=tempL)
			break;
		else
		{
			b=b/2;
			if(b==0)
				b=1;
			if(Thmopile_V<tempL)
				a=a-b;
			else if(Thmopile_V>=tempH)
				a=a+b;
			if(a<min||a>max)
				break;
		}

	}
	count1=(tempH-tempL)/100;
	count2=(Thmopile_V-tempL)/count1;
	Thmopile=IR[a]*100+count2;
}
void InitalADCTH(void)
{
  //Set ADC Clock
  DrvADC_ClkEnable(2);       //Setting ADC CLOCK ADCK=HS_CK/4
  //Set VDDA voltage
  DrvPMU_VDDA_LDO_Ctrl(E_LDO);
  DrvPMU_VDDA_Voltage(E_VDDA2_4);
  DrvPMU_BandgapEnable();
  DrvPMU_REFO_Enable();
  Delay(5000);
  DrvPMU_AnalogGround(ENABLE);  //ADC analog ground source selection.
	                                //1 : Enable buffer and use internal source(need to work with ADC)
  //Set ADC input pin
  //DrvADC_SetADCInputChannel(ADC_Input_AIO8,ADC_Input_AIO3); //Set the ADC positive/negative input voltage source.
  DrvADC_InputSwitch(OPEN);                //ADC signal input (positive and negative) short(VISHR) control.
  DrvADC_RefInputShort(OPEN);              //Set the ADC reference input (positive and negative) short(VRSHR) control.
  DrvADC_ADGain(0);
  //DrvADC_Gain(ADC_PGA_Disable,ADC_PGA_Disable); //Input signal gain for modulator.
  DrvADC_DCoffset(0);                      //DC offset input voltage selection (VREF=REFP-REFN)
  DrvADC_RefVoltage(3,0);  //Set the ADC reference voltage. VDDA-VSSA
  DrvADC_FullRefRange(0);                  //Set the ADC full reference range select.
                                           //0: Full reference range input
                                           //1: 1/2 reference range input
  DrvADC_OSR(0);               //0 : OSR=32768=10sps

  //Set ADC interrupt
  //DrvADC_ClearIntFlag();
  DrvADC_EnableInt();
  DrvADC_Enable();

  DrvADC_CombFilter(ENABLE);   //Enable comb filter
  DrvADC_CombFilter(DISABLE);   //DISABLE comb filter
  DrvADC_CombFilter(ENABLE);   //Enable comb filter
  Delay(2500);
}
void InitalADCIR(void)
{
  //Set ADC Clock
  DrvADC_ClkEnable(2);       //Setting ADC CLOCK ADCK=HS_CK/4
  //Set VDDA voltage
  DrvPMU_VDDA_LDO_Ctrl(E_LDO);
  DrvPMU_VDDA_Voltage(E_VDDA2_4);
  DrvPMU_BandgapEnable();
  DrvPMU_REFO_Enable();
  Delay(5000);
  DrvPMU_AnalogGround(ENABLE);  //ADC analog ground source selection.
	                                //1 : Enable buffer and use internal source(need to work with ADC)

  //Set ADC input pin
  DrvADC_SetADCInputChannel(OP_OP,OP_ON);
  //DrvADC_SetADCInputChannel(ADC_Input_AIO8,ADC_Input_AIO3); //Set the ADC positive/negative input voltage source.
  DrvADC_InputSwitch(OPEN);                //ADC signal input (positive and negative) short(VISHR) control.
  DrvADC_RefInputShort(OPEN);              //Set the ADC reference input (positive and negative) short(VRSHR) control.
  DrvADC_ADGain(7);
  //DrvADC_Gain(ADC_PGA_Disable,ADC_PGA_Disable); //Input signal gain for modulator.
  DrvADC_DCoffset(0);                      //DC offset input voltage selection (VREF=REFP-REFN)
  DrvADC_RefVoltage(0,0);  //Set the ADC reference voltage. VDDA-VSSA
  DrvADC_FullRefRange(1);                  //Set the ADC full reference range select.
                                           //0: Full reference range input
                                           //1: 1/2 reference range input
  DrvADC_OSR(0);               //0 : OSR=32768=10sps

  //Set ADC interrupt
  //DrvADC_ClearIntFlag();
  DrvADC_EnableInt();
  DrvADC_Enable();

  DrvADC_CombFilter(ENABLE);   //Enable comb filter
  DrvADC_CombFilter(DISABLE);   //DISABLE comb filter
  DrvADC_CombFilter(ENABLE);   //Enable comb filter
  Delay(2500);

  DrvIA_IAGain(IA_IAGain_32);
  DrvIA_IACHM(IA_IACHM_Both);
  DrvIA_ENIA(1);
}