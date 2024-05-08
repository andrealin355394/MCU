Thermopile 紅外線測溫

**系統運作流程示例**


![image](https://github.com/andrealin355394/MCU/assets/58961531/692b1afc-8c96-4e3c-b518-ea4ca5fbc518)







1.
  實體端測試誤差，修改ADC_GAIN值，R_Gain、V_Gain及ADC零點。
2
  利用ColdJunction，舉例如下圖來說 Thermocouple在環溫25℃量測未知溫度得到兩端電壓為1.023V、計算如下
ADC=T_Thermocouple-T_Thermistor= V_Thermocouple-V_Thermistor
25 ℃反推Cold Junction得到1.000V(V_Thermistor)
因此1.023= V_Thermocouple -1.000
得到V_Thermocouple = 1.023+1.000=2.023V
查表後得知，待測溫度為50 ℃。

![image](https://github.com/andrealin355394/MCU/assets/58961531/d31c1f21-cf52-4390-b619-f8250d5ccf37)



3.
  外接放大器，解決匹配阻抗問題。
4
  建立表傳感器表格(V-T表、R-T表)，將量測數值經過處理用於查表，曲線顯示溫度，將量測誤差縮小。



**定義V-T表格R-T表格、MCU IP設置、ADC讀值的處理。**
