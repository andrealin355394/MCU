;============================================================================
;					V AUTOSWITCH NET
;============================================================================
V_AUTONET:

VAUTONETEND:
	RET
;============================================================================
;					R AUTOSWITCH NET
;============================================================================
R_AUTONET:
	BTSS	NET_FLAG,R50M,ACCE
	JMP	R_NET2
	JMP	R_NET1
RAUTONETEND:
	RET
R_NET1:	
	BCF	INTE1,GIE,ACCE
	BSF 	INTE1,GIE,ACCE	
	CALL 	500to50KOHMADCSET
	call	delay50ms
	call	delay50ms	
	MVFF	ADCL,AL
	MVFF	ADCM,AH	
	MVFF	ADCH,EAL
	MVL	00H
	MVF	CH,F,ACCE
	MVL	0FAH
	MVF	CL,F,ACCE
	CLRF	ECL
	CALL	32BITDIV16BITU
	CALL	HTOB
	MVL	026H
	CPSG	ADCH,ACCE
	JMP	RAUTONETEND
	BSF	NET_FLAG,R50M,ACCE
	JMP	RAUTONETEND	
R_NET2:
	BCF	NET_FLAG,R50M,ACCE
	CALL 	500Kto50MOHMADCSET	
	call	delay50ms
	call	delay50ms
	MVFF	ADCL,AL
	MVFF	ADCM,AH	
	MVFF	ADCH,EAL
	MVFF	R_GAIN2,CL
	CLRF	CH
	CLRF	ECL
	CALL	32BITDIV16BITU
	CALL	HTOB		
	MVL	026
	CPSG	ADCH,ACCE
	JMP	RAUTONETEND
	CALL	DISPLAY_OF
	JMP	RAUTONETEND		
;============================================================================
;					A AUTOSWITCH NET
;============================================================================
;============================================================================
;					CAPA AUTOSWITCH NET
;============================================================================