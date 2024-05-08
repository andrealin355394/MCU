;=========  CLRF SRAM======================;;
CLRLOOP:    
    	LDPR    	080H,FSR0L
    	MVL		0FFH
CLRLOOP1:
    	CLRF   	POINC0,ACCE
    	DCSZ    	WREG,F,ACCE
    	JMP     	CLRLOOP1
    	CLRF    	POINC0,ACCE
    	RET	
;======================================================
; 清零
;WREG = 長度
;FSR0 = Address
;======================================================
CLEAR:
        clrf    POINC0,ACCE
        dcsz    WREG,F,ACCE
        jmp     CLEAR
        ret          
DISPLAY_CLEAR:
  CLRF LCD0,ACCE
  CLRF LCD1,ACCE
  CLRF LCD2,ACCE
  CLRF LCD3,ACCE
  CLRF LCD4,ACCE
  CLRF LCD5,ACCE
  CLRF LCD6,ACCE
  CLRF LCD7,ACCE
  RET
;================================================================
HTOB:
    MVF AL,W,ACCE
    MVF TMP1,F,ACCE
    MVF AH,W,ACCE
    MVF TMP2,F,ACCE
    MVF EAL,W,ACCE
    MVF TMP3,F,ACCE
    CLRF AL,ACCE
    CLRF AH,ACCE
    CLRF EAL,ACCE
    CLRF STATUS,ACCE
    MVL  18H
    MVF  BUFFER,F,ACCE
    
LOOPC:
    RLFC TMP1,F,ACCE
    RLFC TMP2,F,ACCE
    RLFC TMP3,F,ACCE
    RLFC  AL,F,ACCE
    RLFC  AH,F,ACCE
    RLFC  EAL,F,ACCE
    ;RLFC  EAH,F,ACCE
    DCSZ BUFFER,F,ACCE
    JMP  ADJDEC
    RET
ADJDEC:
    MVL  00H
    MVF  FSR0H,F,ACCE
    MVL  AL
    MVF  FSR0L,F,ACCE
    CALL ADJBCD
    MVL  AH
    MVF  FSR0L,F,ACCE
    CALL ADJBCD
    ;MVL  AH
    ;MVF FSR0L,F,ACCE
    ;CALL    ADJBCD
    MVL EAL
    MVF FSR0L,F,ACCE
    JMP  LOOPC
ADJBCD:
    MVL  03H
    ADDF INDF0,W
    MVF  TMP0,F,ACCE
    BTSZ  TMP0,3
    MVF   INDF0,F,ACCE

    MVL    030H       
    ADDF  INDF0,W
    MVF   TMP0,F,ACCE
    BTSZ TMP0,7
    MVF   INDF0,F,ACCE
    RET
;================================================================
; 十進制轉十六進制  (需要再同一個Bank區)
; FSR1L    十進制的間接位址
; FSR0L    十六進制的間接位址
; WREG      長度
; MD1 , MD2 , r_Len, MDL1, MDL2 寄存器
;Cycle (2 byte ) = 983
;================================================================
btoh:
        mvf     r_Len,F,ACCE
        dcf     r_Len,w,ACCE
        addf    FSR1L,F,ACCE
        addf    FSR0L,F,ACCE
        mvff    FSR1L,MD2
        mvff    FSR0L,MD1
        mvf     r_Len,W,ACCE
     BtoH_dec:   
        clrf    PODEC0,ACCE
        dcsz    WREG,F,ACCE
        jmp     BtoH_dec
        mvff    MD1,FSR0L
        mvf     r_Len,W,ACCE
        mull    8
        mvff    PRODL,MDL1        
btoh_LP:
        BCF     STATUS,C,ACCE
        mvf     r_Len,W,ACCE
 btoh_LP_fsr1:
        rrfc    PODEC1,F,ACCE
        dcsz    WREG,F,ACCE
        jmp     btoh_LP_fsr1
        mvf     r_Len,W,ACCE
 btoh_Lp_fsr0:
        rrfc    PODEC0,F,ACCE
        dcsz    WREG,F,ACCE
        jmp     btoh_Lp_fsr0
        mvff    md1,FSR0L
        mvff    md2,FSR1L
        dcsz    MDL1,F,ACCE
        jmp     btoh_adj
        ret

btoh_adj:
        mvff    r_Len,MDL2
        mvff    md2,FSR1L
 btoh_adj_lop:
        call    AdjHex
        dcf     FSR1L,F,ACCE
        dcsz    MDL2,F,ACCE
        jmp     btoh_adj_lop
        mvff    md2,FSR1L
        jmp     btoh_LP
;---------
AdjHex:
        mvl     3
        btsz    INDF1,3
        subf    INDF1,F
        mvl     030H
        btsz    INDF1,7
        subf    INDF1,F
        ret
;================================
;32/16bit  Fixed Point Divide   
;Equation:<<32/16= 16>>
;			 EAX/CX= AX...DX 
;paramaters : 
;		1.Divided Number  : EAX(EAH,EAL,ah,al) 
;		2.Divisor Number  : CX(CH,CL)
;register:1.EAX,2.AX,3.CX,4.DX,5.DIVTX,6.buffer

;===========================================

32BITDIV16BITU:
     MVl  020H
     mvf buffer,f,acce
     clrf  divh
     clrf  divl
divloop32_16u:
      clrf  status
      rlfc  AL,F
      RLFC  AH,F
      RLFC  EAL,F
      RLFC  EAH,F
      RLFC  DIVL,F
      RLFC  DIVH,F
      MVF   DIVL,W,ACCE
      MVF   DL,F,ACCE
      MVF   DIVH,W,ACCE
      MVF   DH,F,ACCE
      CALL  DX_CX
      BTSS  STATUS,C
      JMP   DIVLS32_16U
      MVF   DL,W,ACCE
      MVF   DIVL,F,ACCE
      
      MVF   DH,,ACCE
      MVF   DIVH,F,ACCE
      INF   AL,F
DIVLS32_16U:
      DCSZ  BUFFER,1
      JMP   divloop32_16u
      CLRF  STATUS
      MVF   DIVL,W,ACCE
      MVF   DL,F,ACCE
      MVF   DIVH,W,ACCE
      MVF   DH,F,ACCE
      RET
 ;=======================
;   SUB  FUNCTION
;========================
 DX_CX:
     MVF CL,W,ACCE
     SUBF DL,F,ACCE
     MVF CH,W,ACCE
     SUBC DH,F,ACCE
     RET


EDX_ECX:
     MVF CL,W,ACCE
     SUBF DL,F,ACCE
     MVF CH,W,ACCE
     SUBC DH,F,ACCE
 
     MVF ECL,W,ACCE
     SUBC EDL,F,ACCE
     MVF  ECH,W,ACCE
     SUBC  EDH,F,ACCE
     RET
        