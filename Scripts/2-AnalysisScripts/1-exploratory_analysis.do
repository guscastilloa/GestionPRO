use "${intermediatedata}/base_completa_2.dta", clear

* Variables Independientes
	* X1. Tiene asesor
	* X2. Region (oficina)
	* X3. perfil de riesgo
	* X4. Sociodemográficas: sexo, grupo_edad, r_segmento)
	* X5. Puso PQRs	
	* X6. Varianza perfil de riesgo
	* X7. n_asesores_hist





*******************************************************************************
***************				 ANÁLISIS DESCRIPTIVO. 			*******************
*******************************************************************************
set scheme s1color

* Variables Independientes ************************************

* X1: Tiene asesor
graph pie, over(tiene_asesor) by(cancelo, title("¿Tiene Asesor?") ///
	subtitle("Según estado en GestionPro ")) ///
	plabel(_all percent, format(%9.2g) c(white) size(3.5))
graph export "${output}/pie_tiene_asesor.png", replace

* X2: Regional
graph pie, over(r_regional)	by(cancelo, title("Regional") ///
	subtitle("Según estado en GestionPro")) ///
	plabel(_all percent, format(%9.2g) c(white) size(3.5)) ///
	pie(3, explode)
graph export "${output}/pie_regional.png", replace

* X3: Perfil de Riesgo 
graph pie, over(r_perfilderiesgo) by(cancelo, title("Perfil de Riesgo") ///
	subtitle("Según estado en GestionPro")) ///
	plabel(_all percent, format(%9.2g) c(white) size(3.5))
graph export "${output}/pie_perfil_riesgo.png", replace

* X4: Sociodemográficas
	* Grupos de edad
	graph pie, over(grupo_edad) by(cancelo, title("Grupos de Edad") ///
		subtitle("Según estado en GestionPro")) ///
		plabel(_all percent, format(%9.2g) c(white) size(3.5))
	graph export "${output}/pie_grupo_edad.png", replace
	
	* Sexo
	graph pie, over(sexo_r) by(cancelo, title("Sexo") ///
		subtitle("Según estado en GestionPro")) ///
		plabel(_all percent, format(%9.2g) c(white) size(3.5))
	graph export "${output}/pie_sexo.png", replace	

	* Segmento	
	graph pie, over(r_segmento) by(cancelo, title("Segmento estratégico") ///
		subtitle("Según estado en GestionPro")) ///
		plabel(_all percent, format(%9.2g) c(black) size(3.5))
	graph export "${output}/pie_segmento.png", replace	

* X5: Puso PQRs
	graph pie, over(puso_pqr) by(cancelo, title("Puso PQRs") ///
		subtitle("Según estado en GestionPro")) ///
		plabel(_all percent, format(%9.3g) c(black) size(3.5))
	graph export "${output}/pie_pqr.png", replace	
	
* X6: Varianza perfil de riesgo
	hist varianza_riesgo_categ, freq by(cancelo, title("Varianza Perfil de Riesgo") ///
		subtitle("Según estado en GestionPro")) 
	graph export "${output}/hist_varianza_perfil_de_riesgo.png", replace

* X7: n_asesores_hist
	graph pie if eliminar==0, over(n_asesores_hist) by(cancelo)
	
	sum n_asesores_hist if cancelo ==0 & eliminar ==0
	gen media_s = r(mean)
	
	sum n_asesores_hist if cancelo ==1 & eliminar ==0
	gen media_c = r(mean)
	
	hist n_asesores_hist if eliminar==0, freq by(cancelo, title("Num. asesores histórico") ///
		subtitle("Según estado en GestionPro"))
	graph export "${output}/hist_n_asesores_hist.png", replace
	
* Otras variables +************************************************
	
* Diferencia en meses cancelación vs suscripción
hist diferenciaenmesescancelaciónvssu, freq aspect(1) title("Tiempo hasta cancelación")
graph export "${output}/diferencia_meses_cancelacion.png", replace


	








*******************************************************************************
*************** 				ANÁLISIS ESTADÍSTICO		******************* 	
*******************************************************************************

* Variables Independientes
	* X1. Tiene asesor: tiene_asesor
	* X2. Region (oficina): r_regional
	* X3. perfil de riesgo: r_perfilderiesgo
	* X4. Sociodemográficas: sexo, grupo_edad, r_segmento)
	* X5. Puso PQRs: puso_pqr
	* X6. Varianza perfil de riesgo: varianza_riesgo_categ
	* X7. Num asesores hist: n_asesores_hist
	
tab cancelo tiene_asesor, chi2

tab nombreasesor_r cancelo if tiene_asesor == 1, chi2



*********** REGRESIONES

* Generar variable logarítmica para poder interpretar en porcentajes 


* Regresion 1
 * Factores sociodemográficos + perfil de riesgo
	reg cancelo i.sexo_r i.grupo_edad ib6.r_segmento ib4.r_perfilderiesgo, r
	coefplot, drop(_cons) aspect(1) xline(0, lpattern("dash")) ///
		title("Probabilidad de cancelación - Modelo 1")
	graph export "${output}/coefplot_reg1.png", replace

* Regresión 2:
	* Sociodemográficas significativas + demás var. independientes (excepto n_asesores_hist)
	reg cancelo i.grupo_edad ib6.r_segmento i.tiene_asesor ib1.r_regional ///
		ib4.r_perfilderiesgo i.puso_pqr varianza_riesgo_categ, r
	coefplot, aspect(1) xline(0, lpattern("dash")) ///
	title("Probabilidad de cancelación - Modelo 2")
	graph export "${output}/coefplot_reg2.png", replace

* Regresión 3:
	* Sociodemográficas + demás variables independientes significativas (salvo n_asesores_hist)
	
	* Sociodemográficas + asesor
	reg cancelo i.grupo_edad i.r_segmento i.tiene_asesor, r
	outreg2 using "${output}/reg3.doc", replace
	
	
	* Sociodemográficas + asesor + perfil_riesgo
	reg cancelo i.grupo_edad i.r_segmento i.tiene_asesor ib3.r_perfilderiesgo, r
	outreg2 using "${output}/reg3.doc", replace
	
	* Sociodemográficas + asesor + perfil_riesgo + regional
	reg cancelo i.grupo_edad i.r_segmento i.tiene_asesor ib3.r_perfilderiesgo ///
		ib1.r_regional, r
	outreg2 using "${output}/reg3.doc", append 
	
	* Sociodemográficas + asesor + perfil_riesgo + regional + pqr
	reg cancelo i.grupo_edad i.r_segmento i.tiene_asesor ib3.r_perfilderiesgo ///
		ib1.r_regional	i.puso_pqr, r
	outreg2 using "${output}/reg3.doc", append 
	
	* Sociodemográficas + asesor + perfil_riesgo + regional + pqr + varianza_riesgo_categ
	reg cancelo i.grupo_edad i.r_segmento i.tiene_asesor ib3.r_perfilderiesgo ///
		ib1.r_regional i.puso_pqr varianza_riesgo_categ, r
	outreg2 using "${output}/reg3.doc", append 	
	
	
	
	
	* Regresión completa
	reg cancelo i.grupo_edad i.r_segmento i.tiene_asesor ib3.r_perfilderiesgo ///
		ib1.r_regional i.puso_pqr varianza_riesgo_categ, r
	coefplot, aspect(1) xline(0, lpattern("dash")) ///
		title("Probabilidad de cancelación - Modelo 3")
	graph export "${output}/coefplot_reg3.png", replace	
	
* Regresion 4: sociodemográficos + n_asesores_hist
	* NOTA: No olvidar la condición **if eliminar==0**
	reg cancelo i.sexo_r i.grupo_edad ib6.r_segmento n_asesores_hist if eliminar==0, r
	coefplot, aspect(1) xline(0, lpattern("dash")) ///
		title("Probabilidad de cancelación - Modelo 4")
	graph export "${output}/coefplot_reg4.png", replace
	
	
* Otras regresiones
	
reg cancelo i.tiene_asesor n_asesores_hist i.grupo_edad varianza_riesgo_categ, r	
	coefplot, drop(_cons) aspect(1) xline(0, lpattern("dash")) ///
	title("Probabilidad de cancelación")
	graph export "${output}/coefplot_2.png", replace	

reg cancelo i.tiene_asesor n_asesores_hist i.r_regional varianza_riesgo_categ, r	
	coefplot, drop(_cons) aspect(1) xline(0, lpattern("dash")) ///
	title("Probabilidad de cancelación")
	graph export "${output}/coefplot_3.png", replace	

reg cancelo i.tiene_asesor n_cambio_plazometa ib1.r_regional varianza_riesgo_categ, r	
	coefplot, drop(_cons) aspect(1) xline(0, lpattern("dash")) ///
	title("Probabilidad de cancelación")
	graph export "${output}/coefplot_4.png", replace		

reg cancelo i.tiene_asesor n_cambio_plazometa ib2.r_regional varianza_riesgo_categ, r	
	coefplot, drop(_cons) aspect(1) xline(0, lpattern("dash")) ///
	title("Probabilidad de cancelación")
	graph export "${output}/coefplot_5.png", replace			
	
outreg2 using "lr_1.doc", replace drop(sexo_r)


logit cancelo i.tiene_asesor i.sexo_r i.grupo_edad i.r_perfilderiesgo
outreg2 using "lr_1.doc", append ctitle("logit") drop(sexo_r) 

probit cancelo i.tiene_asesor i.sexo_r i.grupo_edad i.r_perfilderiesgo
outreg2 using "lr_1.doc", append ctitle("probit") drop(sexo_r) 



