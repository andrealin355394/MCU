ADC_F:
  	BCF INTF2,AD1F,ACCE ;清除AD1F旗標
  	BSF INTE2,AD1IE,ACCE ;AD1IE:ADC 中斷事件啟用控制器
  	BCF INTF2,LPFF,ACCE ;清除Low Pass Filter 中斷事件旗標
  	BSF INTE2,LPFIE,ACCE ;LPFIE:Low Pass Filter 中斷事件啟用控制器
    	BSF RMSCN,ENRMS,ACCE ;ENRMS:Enable RMS Converter
  	BCF INTF2,RMSF,ACCE ;清除RMSF旗標
  	BSF INTE2,RMSIE,ACCE ;True RMS 中斷事件啟用控制器
  	BSF RMSCN,ENRMS,ACCE ;ENRMS:Enable RMS Converter
 	 ;Peak Hold
  	BSF  RMSCN,ENPKH,ACCE ;ENPKH:Enable Peak Hold
  	RET

	