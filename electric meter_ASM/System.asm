SYSTEM_Init:
  ;設置外部4MHz 震盪器為主要時脈源，
  CLRF TRISC2,ACCE ; 設置PT2.0, PT2.1 供外部震盪器輸入訊號使用
  CLRF PT2PU,ACCE
  MVL 10100011B ;設置外部4MHz 震盪器起振
  MVF MCKCN1,F,ACCE ;設置CPU_CK 源為HS_DCK 且切換至外部震盪器
                    ;HS_DCK 時脈源為 OSC_CX
                    ;LS_CK 時脈源為 OSC_LPO
                    ;指令週期INTR_CK=4M/2/4=0.5MHz
  CALL DELAY ;DELAY LOOP 為時間延遲副程式
             ;必須保留約30msec 延遲時間做為震盪器起振使用
  MVL 10100010B ;關閉內部OSC_HAO 頻率源達省電功能
  MVF MCKCN1,F,ACCE ;
  NOP
;-----------------------POWER SET-----------------------------
  ;Voltage Reference Generator(VRG)
  ;Charge Pump Regulator
  MVL 11111100B ;DMMBIAS=1, SAGND=11:0.5xVDDA, ENVS=1
                ;ENREFO=1, ENLDO=1, LDOC=00:3.6V
  MVF PWRCN,F,ACCE
  MVL 11000111B ;MCUBIAS=1, ENCPVGG=1, ENCMP=0, ENCNTI=0
                ;ENCTR=0, RSTCOMB=1, RSTLPF=1, RSTRMS=1
  MVF PWRCN2,F,ACCE
  ;LCD Control
  MVL 01100000B ; LCDMX1=1, LCDMX0=1
  MVF LCDCN2,F,ACCE ;1/4 duty, LCD 字節顯示
  MVL 11011100B ; ENLCD=1, LCDPR=1, VLCDX0=1, LCDBF=1, LCDBI1=1
  MVF LCDCN1,F,ACCE ;1/3 bias, LCD 啟用, 啟動LCD 倍壓電源VLCD=3V
  CALL DELAY ;LCD 倍壓電源穩定時間 (at VLCD CAP-4.7uF)
             ;VDD=2.2V, VLCD=3V, Stable time ~ 85msec
             ;VDD=3.6V, VLCD=3V, Stable time ~ 15msec
;-------------------TIMER-----------------------------------
  ;TIMER A
 ; BCF INTF1,TMAIF,ACCE ;清除TMAIF旗標
  ;BSF INTE1,TMAIE,ACCE ;設置Timer A中斷服務
  ;MVL 11100000B ;啟用Timer A並設置工作頻率為PERA_CK
 ; MVF TMACN,F,ACCE ;設置TMAS[1:0] =10b,使得TMAR計數器發生溢位的頻率為每
                   ;PERA_CK/64 Hz;即每次產生中斷事件時間為1/(PERA_CK/64)秒
                   
BCF	INTF1,TMAIF,ACCE
BSF	INTE1,TMAIE,ACCE 
BSF	TMACN,ENTMA


;-----------------------KEY-----------------------------
  ;KEY PORT
;  BSF  TRISC1,TC1.6,ACCE ;為輸出狀態
;  BSF  TRISC1,TC1.5,ACCE ;為輸出狀態
;  BSF  TRISC1,TC1.2,ACCE ;為輸出狀態

;  BSF  PT1,PT1.6,ACCE ;為輸出1
;  BSF  PT1,PT1.5,ACCE ;為輸出1
;  BSF  PT1,PT1.2,ACCE ;為輸出1
  BSF  PT1PU,PU1.1,ACCE 
  BSF  PT1PU,PU1.0,ACCE 
  
BSF	PT1,PT1.0,ACCE
BSF	PT1PU,PU1.0,ACCE
BSF	TRISC1,TC1.2,ACCE

;-----------------指撥開關-------------------------------  
  BSF  PT2PU,PU2.7,ACCE
  BSF  PT2PU,PU2.6,ACCE 
  BSF  PT2PU,PU2.5,ACCE 
  BSF  PT2PU,PU2.4,ACCE
  
	BCF INTF3,E24IF,ACCE 
  	BSF INTE3,E24IE,ACCE
 	BCF INTF3,E25IF,ACCE 
  	BSF INTE3,E25IE,ACCE
  	BCF INTF3,E26IF,ACCE 
  	BSF INTE3,E26IE,ACCE
  	BCF INTF3,E27IF,ACCE 
  	BSF INTE3,E27IE,ACCE

  RET
DELAY:
  CLRF DELAY_COUNT,ACCE
  MVL  0
L1:
  DCSZ WREG,F,ACCE
  RJ   L1
  DCSZ DELAY_COUNT,F,ACCE
  RJ   L1
  RET
  
DELAY50ms:
	mvl	010h
  	mvf	DELAY_COUNT,f,ACCE
  	MVL  0ffH
L11:
  	DCSZ WREG,F,ACCE
  	jmp	L11
  	DCSZ DELAY_COUNT,F,ACCE
  	jmp   L11
  	RET	


;Clear Memory 0x080~0x17F
Clear_Memory:
  MVL  080H ;設定索引間接位址
  MVF  FSR0L,F,ACCE
  MVL  000H
  MVF  FSR0H,F,ACCE
  MVL  000H ;設定清除長度(256Bytes)
ClriniMen0:
  CLRF POINC0,ACCE
  DCSZ WREG,F,ACCE
  JMP  ClriniMen0
  RET