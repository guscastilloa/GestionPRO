* Para correr este script primero se debió haber ejecutado el _master.do.




*******************************************************************************
* LIMPIANDO MISSING VALUES

import delimited "${intermediatedata}/s_c_ha_hr_pqr_encuesta.csv", clear


* Limpiando NaNs de Cancelados: ******************************
	* Hay 17315 missing data en variable "cancelo" que deben se 0
	label define yesno 1 "Sí" 0 "No"
	label define lcancelo 1 "Canceló" 0 "Activo" 
	recode cancelo .=0
	tab cancelo, miss
	label values cancelo lcancelo
	* Hay missing data en variable "n_cancelaciones" que debe ser 0
	recode n_cancelaciones .=0
	label var n_cancelaciones "Número de cancelaciones"
	tab n_cancelaciones, miss
	
* Limpiando NaNs de 3-Histórico Asesor *********************** SKIP
	* var: n_asesores_hist, varianza_riesgo_categ
	* Debo limpiar 9036 missing values que corresponden a la varianza del 
	* histórico perfil de riesgo. No sé qué valor imputarle a los missings,
	* por lo tanto no creo que esta variable se pueda limpiar.
	
	* Modificación Beatriz:
		* Debo hacer que todos los que tengan eliminar=1 sean missing values
		* para que no sean tomados en cuenta en la regresión cuando se incluya
		* la variable 
	recode eliminar 1=.
	tab n_asesores_hist if eliminar==0, miss 
	
* Limpiando NaNs de Cambio Plazo Meta ************************ WARNING
	* var: n_cambio_plazometa
	* No sé que valor imputarle a los 22,445 missing values de esta variable
	* pues no entiendo lo que esta variable significa.
	
	* Por ahora imputare 0 a los  22,476 missing values (31 más de lo esperado)
	recode n_cambio_plazometa .=0
	label var n_cambio_plazometa "Cambios plazo meta"
	tab n_cambio_plazometa, miss
	
	
* Limpiando NaNs de PQR	
	* var: puso_pqr
	* Hay 22813 missing values que deben ser 0 (No puso PQR)
	 
	* Anomalía: en base final quedaron 22,825 (12 obs más de las calculadas) que deben ser 0
	recode puso_pqr .=0
	label var puso_pqr "Puso PQR"
	label define lpqr 1 "Puso PQR" 0 "No puso PQR"
	label values puso_pqr lpqr
	tab puso_pqr, miss
* Limpiando NaNs de Encuesta 6 meses después
	* var: encuesta
	* Hay 22582 missing values que deben llenarse con 0 (No realizó encuesta)
	recode encuesta .=0
	label var encuesta "Realizó encuesta satisfacción"
	label values encuesta yesno
	tab encuesta, miss

* Limpiando edad
	* vars:	edadafiliado_left edadafiliado_right
	* Crear una nueva variable que no tenga missing values
	gen edad = edadafiliado_left
	replace edad = edadafiliado_right if edad== .

* Limpiar asesor
	* var: nombreasesor
	encode nombreasesor, gen(nombreasesor_r)
	gen tiene_asesor = 0 if (nombreasesor=="AUTOSERVICIO") | (nombreasesor== "CLIENTE AUTOGESTIONADO")
// 	gen tiene_asesor = 0 if (nombreasesor_r == 46) | (nombreasesor_r == 29)
	recode tiene_asesor .=1
	
	label var tiene_asesor "Tiene asesor"
	label define lasesor 0 "Sin asesor" 1 "Con asesor"
	label values tiene_asesor lasesor
	tab tiene_asesor, miss
	
* Limpiar sexo
	* var: sexo
	replace sexo = "Femenino" if sexo == "FEMENINO"
	replace sexo = "Masculino" if sexo == "MASCULINO"
	replace sexo = "Sin clasificar" if sexo == "SIN CLASIFICAR"
	
	encode sexo, gen(sexo_r)

* Limpiar perfil de riesgo
	* var: perfilderiesgo, riesgo_categ
	encode perfilderiesgo, gen(r_perfilderiesgo)

	encode riesgo_categ, gen(r_riesgo_categ)

* Limpiar Regional
	* var: regional
	gen regional_copy = regional
	replace regional_copy = "Bogotá" if regional_copy=="REGIONAL BOGOTA"
	replace regional_copy = "Antioquia" if regional_copy=="REGIONAL ANTIOQUIA"
	replace regional_copy = "Equipo canales Y gest. com." if regional_copy=="EQUIPO CANALES Y GESTION COMERCIAL"
	replace regional_copy = "Caribe" if regional_copy == "REGIONAL CARIBE"
	replace regional_copy = "Centro" if regional_copy == "REGIONAL CENTRO"
	replace regional_copy = "Occidente Y Cafetera" if regional_copy=="REGIONAL OCCIDENTE Y CAFETERA"
	
	encode regional_copy, gen(r_regional)
	

* Limpiar Segmento
	replace segmento = "1.Alto Patrimonio" if segmento == "1.ALTO PATRIMONIO" 
	replace segmento = "2.Prime" if segmento == "2.PRIME"
	replace segmento = "3.Alto Valor" if segmento == "3.ALTO VALOR"
	replace segmento = "4.Rentas Medias A" if segmento == "4.RENTAS MEDIAS A"
	replace segmento = "5.Rentas Masivas B" if segmento == "5.RENTAS MASIVAS B"
	replace segmento = "6.Rentas Masivas C" if segmento == "6.RENTAS MASIVAS C"
	replace segmento = "7.Sin segmento" if segmento == "7.SIN SEGMENTO"
	replace segmento = "8.No segmentado" if segmento == "8.NO SEGMENTADO"
	
	tab segmento
	
	encode segmento, gen(r_segmento)
	recode r_segmento (9=1) (12=2) (10=3) (15=4) (13=5) (14=6) (16=7) (11=8)
	* 1.Alto Patrimonio: 324
	* 2.Prime: 549
	* 3. Alto valor: 837
	* 4. Rentas Medias A: 1.265
	* 5. Rentas Masivas B: 462
	* 6. Rentas Masivas C: 62
	* 7. Sin Segmento: 6
	* 8. No Segmentado: 29
* Label varianza_riesgo_categ
	label var varianza_riesgo_categ "Varianza Perfil de Riesgo"

* Label n_asesores_hist
	label var n_asesores_hist "Num. ases. históricos"

	
	
	
save "${intermediatedata}/base_completa_1.dta", replace
*End
