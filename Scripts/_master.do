/*******************************************************************************
*  			                	GESTION PRO 		                     	  *
********************************************************************************
*                                                                              *
*   PURPOSE:     Reproduce all data work, map inputs and outputs,              *
*                facilitate collaboration                                      *
*                                                                              *
*   OUTLINE:     PART 1:  Set standard settings and install packages           *
*                PART 2:  Prepare folder paths and define programs             *
*                PART 3:  Run do-files                                         *
*                                                                              *
********************************************************************************
    PART 0:  Install packages and harmonize settings
********************************************************************************

********************************************************************************
    PART 1:  Install packages and harmonize settings
********************************************************************************/

    local user_commands ietoolkit outreg2 coefplot ciplot //Add required commands or packages
    foreach command of local user_commands {
        cap which `command'
        if _rc == 111 ssc install `command'
    }

	*Harmonize settings across users as much as possible
    ieboilstart, v(13.1)
    `r(version)'

/*******************************************************************************
    PART 2:  Prepare folder paths and define programs
*******************************************************************************/

    * Research Assistant folder paths
   *User Number:
   * Gustavo          1 
   * Add more users here as needed

   *Set this value to the user currently using this file
   global user  1

   * Root folder globals
   * ---------------------
   if $user == 1 {
		// Path to Gustavo's directory
       global projectfolder "/Users/upar/Dropbox/02-MONEY/ETHOS_BT/Data_analysis/GestionPRO/Gestion_PRO-project"
	   *"/Users/upar/Dropbox/03-MONEY/ETHOS_BT/Data_analysis/Evaluacion_de_Impacto/Project-impact_evaluation-inhouse"
   }
   if $user == 2 {
       global projectfolder  "" // Write path to Max's project folder
   }
   
   * Globals to locate respective files
	global datafolder "${projectfolder}/Data"
	global rawdata "${datafolder}/0-InputData/raw_data"
	global intermediatedata "${projectfolder}/Data/1-IntermediateData"
	global output "${projectfolder}/Output"
********************************************************************************

/*******************************************************************************
    PART 3:  Run do files
*******************************************************************************/

* Clean missing values and assigning labels
	do "${projectfolder}/Scripts/1-ProcessingScripts/1-cleaning.do"
	
* Creating variables
	do "${projectfolder}/Scripts/1-ProcessingScripts/2-creating_variables.do"

* Exploratory analysis
	do "${projectfolder}/Scripts/2-AnalysisScripts/1-exploratory_analysis.do"

* End
