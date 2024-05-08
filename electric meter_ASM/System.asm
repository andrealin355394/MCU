SYSTEM_Init:
  ;�]�m�~��4MHz �_�������D�n�ɯ߷��A
  CLRF TRISC2,ACCE ; �]�mPT2.0, PT2.1 �ѥ~���_������J�T���ϥ�
  CLRF PT2PU,ACCE
  MVL 10100011B ;�]�m�~��4MHz �_�����_��
  MVF MCKCN1,F,ACCE ;�]�mCPU_CK ����HS_DCK �B�����ܥ~���_����
                    ;HS_DCK �ɯ߷��� OSC_CX
                    ;LS_CK �ɯ߷��� OSC_LPO
                    ;���O�g��INTR_CK=4M/2/4=0.5MHz
  CALL DELAY ;DELAY LOOP ���ɶ�����Ƶ{��
             ;�����O�d��30msec ����ɶ������_�����_���ϥ�
  MVL 10100010B ;��������OSC_HAO �W�v���F�ٹq�\��
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
  MVF LCDCN2,F,ACCE ;1/4 duty, LCD �r�`���
  MVL 11011100B ; ENLCD=1, LCDPR=1, VLCDX0=1, LCDBF=1, LCDBI1=1
  MVF LCDCN1,F,ACCE ;1/3 bias, LCD �ҥ�, �Ұ�LCD �����q��VLCD=3V
  CALL DELAY ;LCD �����q��í�w�ɶ� (at VLCD CAP-4.7uF)
             ;VDD=2.2V, VLCD=3V, Stable time ~ 85msec
             ;VDD=3.6V, VLCD=3V, Stable time ~ 15msec
;-------------------TIMER-----------------------------------
  ;TIMER A
 ; BCF INTF1,TMAIF,ACCE ;�M��TMAIF�X��
  ;BSF INTE1,TMAIE,ACCE ;�]�mTimer A���_�A��
  ;MVL 11100000B ;�ҥ�Timer A�ó]�m�u�@�W�v��PERA_CK
 ; MVF TMACN,F,ACCE ;�]�mTMAS[1:0] =10b,�ϱoTMAR�p�ƾ��o�ͷ��쪺�W�v���C
                   ;PERA_CK/64 Hz;�Y�C�����ͤ��_�ƥ�ɶ���1/(PERA_CK/64)��
                   
BCF	INTF1,TMAIF,ACCE
BSF	INTE1,TMAIE,ACCE 
BSF	TMACN,ENTMA


;-----------------------KEY-----------------------------
  ;KEY PORT
;  BSF  TRISC1,TC1.6,ACCE ;����X���A
;  BSF  TRISC1,TC1.5,ACCE ;����X���A
;  BSF  TRISC1,TC1.2,ACCE ;����X���A

;  BSF  PT1,PT1.6,ACCE ;����X1
;  BSF  PT1,PT1.5,ACCE ;����X1
;  BSF  PT1,PT1.2,ACCE ;����X1
  BSF  PT1PU,PU1.1,ACCE 
  BSF  PT1PU,PU1.0,ACCE 
  
BSF	PT1,PT1.0,ACCE
BSF	PT1PU,PU1.0,ACCE
BSF	TRISC1,TC1.2,ACCE

;-----------------�����}��-------------------------------  
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
  MVL  080H ;�]�w���޶�����}
  MVF  FSR0L,F,ACCE
  MVL  000H
  MVF  FSR0H,F,ACCE
  MVL  000H ;�]�w�M������(256Bytes)
ClriniMen0:
  CLRF POINC0,ACCE
  DCSZ WREG,F,ACCE
  JMP  ClriniMen0
  RET