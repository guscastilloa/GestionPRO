* Para correr este script primero se debió haber ejecutado el _master.do.

use "${intermediatedata}/base_completa_1.dta", clear
*******************************************************************************
* VARIABLES AUXILIARES

* Grupos etarios
	gen grupo_edad = edad
	recode grupo_edad (.=.) (-1=.) (1/29=1) (30/59=2) (else=3)
	label var edad "Grupo de edad"
	label define lab_edad 1 "Joven (1-29)" 2 "Adulto (30-59)" 3 "Mayor (60+)"
	label values grupo_edad lab_edad
	tab grupo_edad, miss

* Diferentes grupos etarios
	gen age_group = edad
	recode age_group (.=.) (-1=.) (18/28=1) (29/39=2) (40/50=3) (51/61=4) (62/72=5) (else=6) 
	label var age_group "Grupo de edad"
	label define lagegroup 1 "18-28 años" 2 "29-39 años" 3 "40-50 años" 4 "51-61 años" 5 "62-72 años" 6 "73-110 años"
	label values age_group lagegroup

	
save "${intermediatedata}/base_completa_2.dta", replace
*End
