ADC_Init_C:
	;---------------------------ADCNET--------------------------------
	CALL		DC50MANET
	;---------------------------ADCNETSET----------------------------
	CALL		DC50MAADCSET	
	;----------------------------------------------------------------------
	CALL		ADC_F
  	RET
DC50MANET:	
	MVL		0H
	MVF		PA54,F,ACCE
	MVF		PA32,F,ACCE
	MVF		PA10,F,ACCE
	MVF		PAX6,F,ACCE
	RET		
DC50MAADCSET:
	MVL 00100000B
  	MVF ADCN1,F,ACCE
  	MVL 00000000b;SMOD
  	MVF ADCN2,F,ACCE
  	MVL 00000000B ;
  	MVF ADCN3,F,ACCE
  	MVL 00011111B;AD1OSR=010:32 OSR
  	MVF ADCN4,F,ACCE
  	MVL 10000101B ;PB1 pb3
  	MVF ADCN5,F,ACCE
  	MVL 00100100B ;
  	MVF ADCN6,F,ACCE
;  	MVL 10000000B  	
	MVL 11110000B 
  	MVF ADCN7,F,ACCE
  	ret		
