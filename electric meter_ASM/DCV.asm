;-----------------------------------------------------------------------------
;Filename : HY12P65_DCV.asm
;-----------------------------------------------------------------------------
INCLUDE  HY12P.INC
INCLUDE  MAIN.INC
INCLUDE  LCD.INC

;-----------------------------------------------------------------------------
; Reset And Interrupt Vector Table
;-----------------------------------------------------------------------------
  ORG  0 ;Reset Vector
  JMP  START

  ORG  4 ;Interrupt Vector
  
ADCInterrut:
	BTSS		INTF2,AD1F,ACCE
	jmp		ADCInterruptEnd
	BCF		INTF2,AD1F,ACCE
	mvff		AD1DATAL,ADCL
	mvff		AD1DATAH,ADCM
	mvff		AD1DATAU,ADCH	
ADCInterruptEnd:	
TMAInterrupt:
	BTSS		INTF1,TMAIF,ACCE
	JMP		TMAInterruptEND
	BCF		INTF1,TMAIF,ACCE
	INF		TMASec,F,ACCE
TMAInterruptEND:
INT24:
	BTSS	INTF3,E24IF
	JMP	INT24END
	BCF	INTF3,E24IF,ACCE
	CLRF	MODE_COUNT
	BSF	MODE_COUNT,V_F,ACCE	 	
INT24END:
INT25:
	BTSS	INTF3,E25IF
	JMP	INT25END
	BCF	INTF3,E25IF,ACCE
	CLRF	MODE_COUNT
	BSF	MODE_COUNT,R_F,ACCE	
	 	
INT25END:
INT26:
	BTSS	INTF3,E26IF
	JMP	INT26END
	BCF	INTF3,E26IF,ACCE	
	CLRF	MODE_COUNT
	BSF	MODE_COUNT,A_F,ACCE		 	
INT26END:
INT27:
	BTSS	INTF3,E27IF
	JMP	INT27END
	BCF	INTF3,E27IF,ACCE
	CLRF	MODE_COUNT
	BSF	MODE_COUNT,CAPA_F,ACCE		 	
INT27END:




KEY_SCAN:
KEYFUNCTION:
KEYFUNCTIONEND:

interruptend:
	reti

START:
	CALL	DISPLAY_CLEAR
 	CALL 	SYSTEM_Init
 	CALL 	Clear_Memory 	
 
;------------------------
	MVL	019H
	MVF	R_GAIN,F,ACCE
	MVL	028H
	MVF	R_GAIN2,F,ACCE

;-----------------------	-

MAINLOOP:
	BSF 	INTE1,GIE,ACCE
	BTSZ	MODE_COUNT,V_F
	CALL	V_1
	BTSZ	MODE_COUNT,R_F
	CALL	R_AUTONET
	BTSZ	MODE_COUNT,A_F
	CALL	A_3
	BTSZ	MODE_COUNT,CAPA_F
	CALL	CAPA_4	
ADCDISPLAY:
	MVFF	AL,DISPLAYL
	MVFF	AH,DISPLAYH
	MVFF	EAL,DISPLAYEAL
	CALL	DISPLAY
		JMP	MAINLOOP



;------------------------------------------------
MODESETCHECK:
	BTSZ	MODE_COUNT,V_F
	CALL	V_1
	BTSZ	MODE_COUNT,R_F
	CALL	R_2
	BTSZ	MODE_COUNT,A_F
	CALL	A_3
	BTSZ	MODE_COUNT,CAPA_F
	CALL	CAPA_4
	RET

V_1:
	MVL	01H
	MVF	DISPLAYL,F,ACCE
	CALL	ADC_Init_V	
	RET
R_2:
	MVL	02H
	MVF	DISPLAYL,F,ACCE
	CALL	R_AUTONET
	RET
A_3:
	MVL	03H
	MVF	DISPLAYL,F,ACCE
	CALL	ADC_Init_C
	RET	
CAPA_4:
   	BCF	INTF2,TMAIF,ACCE
  	BSF	INTE1,TMAIE,ACCE 
  	BSF	TMACN,ENTMA
	MVL	04H
	MVF	DISPLAYL,F,ACCE
	mvl		02H
	CPSG		TMASec,ACCE
	JMP		CAPA_4
	MVFF		ADCL,AL
	MVFF		ADCM,AL
	MVFF		ADCH,AH	
	CLRF		TMASEC
DISCHARGE_LOOP:	
	call	discharge500uf50mf
	call		delay50ms
	MVL		01H
	CPSG		TMASec,ACCE
	JMP		DISCHARGE_LOOP
	call		htob
	mvff		AL,displayl
	mvff		AH,displayh
	MVFF		EAL,DISPLAYEAL
	call		delay50ms
	CALL		DISPLAY		
	CLRF		TMASEC
;	CALL	ADC_Init_Capacitance1
	CALL	ADC_Init_Capacitance2
	RET
	


;----------------OVERFLOW--------------------------------
DISPLAY_OF:
	MVL	011H
	MVF	AL,F,ACCE
	MVF	AH,F,ACCE
	MVF	EAL,F,ACCE
	MVFF	AL,DISPLAYL
	MVFF	AH,DISPLAYH
	MVFF	EAL,DISPLAYEAL
	CALL	DISPLAY
	RET
	
;-----------------------------------------------------------------------------
;Interrupt Service Routine
;-----------------------------------------------------------------------------
ISR_CHECK:
  BTSZ INTF1,TMAIF,ACCE
  JMP TMA_ISR
  BTSZ INTF2,LPFF,ACCE
  JMP LPF_ISR
  BTSZ INTF2,AD1F,ACCE
  JMP ADC_ISR
  BTSZ INTF2,RMSF,ACCE




  JMP RMS_ISR
  RETI ;中斷服務返回

TMA_ISR: ;Timer A 中斷事件服務程式
  ;FOR ADC
  ;MVL  AD1_FLAG
  ;CPSE ADCINTF,ACCE
  ;JMP  EXIT_TMA_ISR
  ;MVFF AD1DABUFU,DISPLAY_BUFFER
  ;MVFF AD1DABUFH,DISPLAY_BUFFER+1
  ;MVFF AD1DABUFL,DISPLAY_BUFFER+2

  ;FOR LPF
  MVL  LPF_FLAG
  CPSE ADCINTF,ACCE
  JMP  EXIT_TMA_ISR

  MVL  ~MINUS_FLAG
  ANDF MATH_STATUS,F,ACCE
  MVFF LPFDABUFU,WREG
  ANDL 080H
  JZ  HEX2BCD_NBAR

  MVFF LPFDABUFU,WREG
  COMF WREG,F,ACCE
  MVFF WREG,LPFDABUFU

  MVFF LPFDABUFH,WREG
  COMF WREG,F,ACCE
  MVFF WREG,LPFDABUFH

  MVL  MINUS_FLAG
  IORF MATH_STATUS,F,ACCE
HEX2BCD_NBAR:
  MVL  LOW LPFDABUFH ;設定十六進制資料的間接位址
  MVF  FSR1L,F,ACCE
  MVL  HIGH LPFDABUFH
  MVF  FSR1H,F,ACCE

  MVL  LOW MATH_BUFFER ;設定十進制資料的間接位址
  MVF  FSR0L,F,ACCE
  MVL  HIGH MATH_BUFFER

  MVF  FSR0H,F,ACCE
  MVL  2 ;2BYTE




  MVF  r_Len,F,ACCE
  CALL htob ;TEST

  MVFF MATH_BUFFER,DISPLAY_BUFFER
  MVFF MATH_BUFFER+1,DISPLAY_BUFFER+1
  MVFF MATH_BUFFER+2,DISPLAY_BUFFER+2
  CLRF ADCINTF,ACCE
EXIT_TMA_ISR:
  MVL  TIMER_OUT_FLAG
  IORF TIMER_FLAG,F,ACCE
  BCF  INTF1,TMAIF,ACCE ;清除TMA中斷事件旗標而TMAR=TMAR+64。
                        ;注意，每當TMAR發生溢位時無論是否開啟中斷事件服務TMAR=TMAR+64
  RETI ;中斷服務返回

ADC_ISR:
  ;ADC Data Save to Buffer
  MVFF AD1DATAL,AD1DABUFL
  MVFF AD1DATAH,AD1DABUFH
  MVFF AD1DATAU,AD1DABUFU
  MVL  AD1_FLAG
  MVF  ADCINTF,F,ACCE
  BCF  INTF2,AD1F,ACCE  ;清除ADC 中斷事件旗標
  RETI ;中斷服務返回

LPF_ISR:
  ;Low Pass Filter Data Save to Buffer
  MVFF LPFDATAL,LPFDABUFL
  MVFF LPFDATAH,LPFDABUFH
  MVFF LPFDATAU,LPFDABUFU

  ;Peak Hold Data Save to Buffer
  MVFF PKHMAXL,PKHMAXBUFL
  MVFF PKHMAXH,PKHMAXBUFH
  MVFF PKHMAXU,PKHMAXBUFU

  MVFF PKHMINL,PKHMINBUFL
  MVFF PKHMINH,PKHMINBUFH
  MVFF PKHMINU,PKHMINBUFU
  MVL  LPF_FLAG
  MVF  ADCINTF,F,ACCE
  BCF  INTF2,LPFF,ACCE  ;清除Low Pass Filter 中斷事件旗標
  RETI ;中斷服務返回

RMS_ISR:
  ;True RMS Data Save to Buffer
  MVFF RMSDATA0,RMSDABUF0 ;LSB
  MVFF RMSDATA1,RMSDABUF1
  MVFF RMSDATA2,RMSDABUF2
  MVFF RMSDATA3,RMSDABUF3
  MVFF RMSDATA4,RMSDABUF4 ;MSB
  MVL  RMS_FLAG
  MVF  ADCINTF,F,ACCE
  BCF  INTF2,RMSF,ACCE  ;清除True RMS 中斷事件旗標
  RETI ;中斷服務返回
  

  INCLUDE Math.asm
  INCLUDE ADC.ASM
  include Display.asm
  include SYSTEM.asm
  include Resistor.asm
  include Capacitance.asm
  include Current.asm
  include Voltage.asm
  include autonet.asm
;-----------------------------------------------------------------------------
; End Of File
;-----------------------------------------------------------------------------
  END
