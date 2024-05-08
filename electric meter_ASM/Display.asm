;LCD Definition      	
1LCDNUM0		EQU		01111101B
1LCDNUM1		EQU		01100000B
1LCDNUM2		EQU		00111110B
1LCDNUM3		EQU		01111010B
1LCDNUM4		EQU		01100011B
1LCDNUM5		EQU		01011011B
1LCDNUM6		EQU		01011111B
1LCDNUM7		EQU		01110001B
1LCDNUM8		EQU		01111111B
1LCDNUM9		EQU		01111011B
1LCDNUMA		EQU		01110111B
1LCDNUMB		EQU		01001111B
1LCDNUMC		EQU		00011101B
1LCDNUMD		EQU		01101110B
1LCDNUME		EQU		00011111B
1LCDNUMF		EQU		00010111B
;==============================================
LDISP: 
     MVLP       LCDTABLE
     ADDF       TBLPTRL,F,ACCE
     BTSZ        STATUS,C,ACCE
     INF          TBLPTRH,F,ACCE
     TBLR       *
     RET     

LCDTABLE:
	DB		LCDNUM0   
	DB		LCDNUM1   
	DB		LCDNUM2
	DB		LCDNUM3
	DB		LCDNUM4
	DB		LCDNUM5
	DB		LCDNUM6
	DB		LCDNUM7
	DB		LCDNUM8
	DB		LCDNUM9
Display:
;================== 
	SWPF  	DisplayEAL,W,ACCE   
	ANDL		00FH
   	CALL  	LDISP
   	MVFF   	TBLDH,LCD0
   	
	MVL 	 	00FH
   	ANDF 		DisplayEAL,W,ACCE
   	CALL 		LDISP
   	MVFF   	TBLDH,LCD1	


	SWPF  	DisplayH,W,ACCE   
	ANDL		00FH
   	CALL  	LDISP
   	MVFF   	TBLDH,LCD2
   	
   	
 	MVL 	 	00FH
   	ANDF 		DisplayH,W,ACCE
   	CALL 		LDISP
   	MVFF   	TBLDH,LCD3	
;================== 
	SWPF  	DisplayL,W,ACCE   
	ANDL		00FH
   	CALL  	LDISP
   	MVFF   	TBLDH,LCD4
   	
   	 MVL 	 	00FH
   	ANDF 		DisplayL,W,ACCE
   	CALL 		LDISP
   	MVFF   	TBLDH,LCD5
;================== 
;================== 
;================== 
;==================   
   	
   	
;	BSF		LCD3,7,ACCE
;	BSF		LCD7,3,ACCE
;	BSF		LCD7,1,ACCE
	RET