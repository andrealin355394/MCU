ADC_F:
  	BCF INTF2,AD1F,ACCE ;�M��AD1F�X��
  	BSF INTE2,AD1IE,ACCE ;AD1IE:ADC ���_�ƥ�ҥα��
  	BCF INTF2,LPFF,ACCE ;�M��Low Pass Filter ���_�ƥ�X��
  	BSF INTE2,LPFIE,ACCE ;LPFIE:Low Pass Filter ���_�ƥ�ҥα��
    	BSF RMSCN,ENRMS,ACCE ;ENRMS:Enable RMS Converter
  	BCF INTF2,RMSF,ACCE ;�M��RMSF�X��
  	BSF INTE2,RMSIE,ACCE ;True RMS ���_�ƥ�ҥα��
  	BSF RMSCN,ENRMS,ACCE ;ENRMS:Enable RMS Converter
 	 ;Peak Hold
  	BSF  RMSCN,ENPKH,ACCE ;ENPKH:Enable Peak Hold
  	RET

	