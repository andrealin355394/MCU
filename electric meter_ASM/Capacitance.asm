ADC_Init_Capacitance1:
	MVL		08H
	MVF		CapacitanceGAIN,F,ACCE
	;---------------------------ADCNET--------------------------------
	CALL		NET5UF50UF
	;---------------------------ADCNETSET----------------------------
;	CALL		500UFTO50MFADCSET	
	;----------------------------------------------------------------------
	CALL		ADC_F
  	BCF	INTF2,CTF,ACCE
  	BSF	INTE2,CTIE,ACCE
  	
	Capacitance_LOAD:	
		BTSS		INTF2,CTF,ACCE
		JMP		Capacitance_LOAD1	
		MVFF		CTCL,AL
		MVFF		CTCH,AH
		MVFF		CTCU,EAL
		MVFF		CTBL,CL
		MVFF		CTBH,CH
		MVFF		CTBU,ECL
		CALL		32BITDIV16BITU
		CLRF		CL
		CLRF		CH
		CLRF		ECL
		MVFF		CapacitanceGAIN,CL
		CALL		32BITDIV16BITU					
	Capacitance_END:
  		RET	
	Capacitance_LOAD1:
		NOP
		JMP	Capacitance_LOAD
				
NET5UF50UF:
	MVL		00001000B
	MVF		PA10,F,ACCE	
	MVL		0H
	MVF		PA54,F,ACCE
	MVF		PA32,F,ACCE
	MVF		PAX6,F,ACCE
;--------------------------------------------------------
  	MVL 00001110B;SMOD
  	MVF ADCN2,F,ACCE
  	MVL 01000010B ;
  	MVF ADCN3,F,ACCE
   	MVL 01100000B
  	MVF ADCN4,F,ACCE 	
;--------------------------------------------------------	
	BCF	PWRCN2,ENCTR,ACCE	
	MVL	0C0H
	MVF	CTAU,F,ACCE
	MVL	0
	MVF	CTAH,F,ACCE
	MVF	CTAL,F,ACCE
	BSF	PWRCN2,ENCTR,ACCE	
	BSF	SAGND1,ACCE
	BSF	SAGND0,ACCE
;	BSF	PWRCN2,ENCMP,ACCE
	
	MVL	11111100B
	MVF	PWRCN,F,ACCE
	MVL	11101111B
	MVF	PWRCN2,F,ACCE
;	MVL	11011100B
;	MVF	LCDCN1,F,ACCE	

	BCF 	INTF2,CTF,ACCE
	BSF 	INTE2,CTIE,ACCE
	RET		
;NET5UF50UF:
;	MVL		10000000B
;	MVF		PA10,F,ACCE	
;	MVL		0H
;	MVF		PA54,F,ACCE
;	MVF		PA32,F,ACCE
;	MVF		PAX6,F,ACCE
;	RET		
NET500UF:
	MVL		10000000B
	MVF		PA32,F,ACCE	
	MVL		0H
	MVF		PA54,F,ACCE
	MVF		PA10,F,ACCE
	MVF		PAX6,F,ACCE
	RET		
500UFTO50MFADCSET:
	MVL 00110000B ;SFT1=00:10：前置Pre-filter 通道0Ω。
  	MVF ADCN1,F,ACCE
  	MVL 00001110B;SMOD
  	MVF ADCN2,F,ACCE
  	MVL 01000010B ;
  	MVF ADCN3,F,ACCE
  	MVL 01100101B
  	MVF ADCN4,F,ACCE
  	MVL 10000101B ;
  	MVF ADCN5,F,ACCE
  	MVL 10110100B   	
  	MVF ADCN6,F,ACCE
 	MVL 10110000B 
 	MVF ADCN7,F,ACCE
  	ret
  	
500UFADCSET:
	MVL 00110001B ;SFT1=00:10：前置Pre-filter 通道0Ω。
  	MVF ADCN1,F,ACCE
  	MVL 00000110B;SMOD
  	MVF ADCN2,F,ACCE
  	MVL 01000010B ;
  	MVF ADCN3,F,ACCE
  	MVL 01100101B
  	MVF ADCN4,F,ACCE
  	MVL 10000101B ;
  	MVF ADCN5,F,ACCE
  	MVL 10110100B   	
  	MVF ADCN6,F,ACCE
 	MVL 10110000B 
 	MVF ADCN7,F,ACCE
  	ret
;=======================================================================
;=======================================================================
;=======================================================================
ADC_Init_Capacitance2:
;=======================================================================
;=======================================================================

;	call		Capacitance_powerset	
	;---------------------------ADCNET--------------------------------
;	CALL		500UFSET	
	CALL		5MFTO50MFSET
	;----------------------------------------------------------------------	
;	CLRF		TMASec

	CALL		ADC_F
  	BCF	INTF2,CTF,ACCE
  	BSF	INTE2,CTIE,ACCE
   	BCF	INTF2,TMAIF,ACCE
  	BSF	INTE1,TMAIE,ACCE 
  	BSF	TMACN,ENTMA
  ;  	BSF 	INTE1,GIE,ACCE
  ;	BSF	InterruptFlag,ADCCALFLAG
	ret  
	
		
discharge500uf50mf:	
	mvl		00001000b
	mvf		pa10,f,acce
	mvl		0
	mvf		pax6,f,acce
	mvf		pa32,f,acce
	mvf		pa54,f,acce

	mvl		00001110b
	mvf		adcn2,f,acce
	mvl		11011110b
	mvf		adcn3,f,acce
	mvl		01100000b
	mvf		adcn4,f,acce
	bsf		pwrcn2,encmp
	bsf		CTSTA,5
	ret
Capacitance_powerset:
	mvl		11111100b
	mvf		pwrcn,f,acce
;	mvl		11111000b
;	mvf		lcdcn1,f,acce
	ret	

			
500UFSET:
	bcf		pwrcn2,encmp
	bcf		CTSTA,5
	MVL		10000000B
;	mvl		00001000b
	MVF		PA32,F,ACCE	
	MVL		0H
	MVF		PA54,F,ACCE
	MVF		PA10,F,ACCE
	MVF		PAX6,F,ACCE
	
;-------------------------------
	mvl		10000000b
	mvf		pa10,f,acce
	mvl		0
	mvf		pax6,f,acce
	mvf		pa32,f,acce
	mvf		pa54,f,acce
;-------------------------------
			
	MVL 		00110001B ;SFT1=00:10：前置Pre-filter 通道0Ω。
  	MVF 		ADCN1,F,ACCE
  	MVL 		0000110B;SMOD
  	MVF 	ADCN2,F,ACCE
  	MVL 	01000010B ;
  	MVF 	ADCN3,F,ACCE
  	MVL 	01100101B
  	MVF 	ADCN4,F,ACCE
  	MVL 	10000101B ;
  	MVF 	ADCN5,F,ACCE
  	MVL 	10110100B   	
  	MVF 	ADCN6,F,ACCE
 	MVL 	10110000B 
 	MVF 	ADCN7,F,ACCE
  	ret
  	
5MFTO50MFSET:
	bcf		pwrcn2,encmp
	bcf		CTSTA,5
	MVL		10000000B
;	mvl		00001000b
	MVF		PA32,F,ACCE	
	MVL		0H
	MVF		PA54,F,ACCE
	MVF		PA10,F,ACCE
	MVF		PAX6,F,ACCE
	
;-------------------------------
	mvl		10000000b
	mvf		pa10,f,acce
	mvl		0
	mvf		pax6,f,acce
	mvf		pa32,f,acce
	mvf		pa54,f,acce
;-------------------------------
			
	MVL 		00110010B ;SFT1=00:10：前置Pre-filter 通道0Ω。
  	MVF 		ADCN1,F,ACCE
  	MVL 		0000110B;SMOD
  	MVF 	ADCN2,F,ACCE
  	MVL 	01000010B ;
  	MVF 	ADCN3,F,ACCE
  	MVL 	01100101B
  	MVF 	ADCN4,F,ACCE
  	MVL 	10000101B ;
  	MVF 	ADCN5,F,ACCE
  	MVL 	10110100B   	
  	MVF 	ADCN6,F,ACCE
 	MVL 	10110000B 
 	MVF 	ADCN7,F,ACCE
  	ret
	RET
