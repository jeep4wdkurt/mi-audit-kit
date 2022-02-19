#
# core-install-folders.sh
#
#	MAUDE Install folder definitions
#
#	Description:
#
#       Folder environment variable definitions for MAUDE scripts.
#
#	Copyright:
#		Copyright (c) 2022, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.01.25  01.00    KurtSchulte    Original Version
#
####################################################################################################

#
# Folders
#
export maudRootFolder
export maudProgFolder

export maudAppsRoot="/usr/sbin"				
export maudAppFolder="${maudAppsRoot}/mi-audit"	

export maudKitsRoot="/opt"											
export maudSoftwareKitFolder="${maudKitsRoot}/mi-audit-kit"	
export maudSoftwareKitCertsFolder="${maudSoftwareKitFolder}/certs"	
export maudSoftwareKitImagesFolder="${maudSoftwareKitFolder}/images"	
export maudSoftwareKitBackgroundsFolder="${maudSoftwareKitImagesFolder}/backgrounds"
export maudSoftwareKitPythonFolder="${maudSoftwareKitFolder}/python"		
export maudSoftwareKitPythonLibFolder="${maudSoftwareKitPythonFolder}/maudelib"	
export maudSoftwareKitUbergenFolder="${maudSoftwareKitFolder}/ubergen"			

export maudDataKitFolder="${maudKitsRoot}/mi-audit-data-kit"				
[ ! -d "${maudKitsRoot}" ] && mkdir "${maudKitsRoot}"	

export maudDataRoot="/var/lib"												
export maudCommonDataFolder="${maudDataRoot}/mi-audit-data"

#
# Constants
# 
export maudSoftwareKitArchivePattern='.*/mi-audit-kit-[.0-9]+.zip'
export maudDataKitArchivePattern='.*/mi-audit-data-kit-[.0-9]+.zip'

export maudSoftwareKitProject="https://github.com/jeep4wdkurt/mi-audit-kit"
export maudDataKitProject="https://github.com/jeep4wdkurt/mi-audit-data-kit"

export maudLocalUbergenFolder="${maudLocalFolder}/ubergen"
export maudUbergenFolder="${maudRootFolder}/ubergen"
export maudUbergenBuildTemplate="${maudUbergenFolder}/build-variables-maude-template.sh"
export maudUbergenBuildValuesDefault="${maudUbergenFolder}/build-variables-maude-default.ini"
export maudUbergenBuildValuesLocal="${maudLocalUbergenFolder}/build-variables-maude-local.ini"

export ubergenRoot="/usr/sbin"
export ubergenFolder="${ubergenRoot}/UberGen"
export ubergenKitProject="https://github.com/jeep4wdkurt/UberGen"

#
# Files
#
export maudSoftwareKitDesktopSetupScript="${maudSoftwareKitFolder}/maude-desktop-setup.sh"
export maudSystemSharedDesktopSetupScript="/etc/profile.d/maude-desktop-setup.sh"
export maudlibGoonCertName="maudelib_credentials.json"
export maudUserGoonCert="${maudLocalCertsFolder}/${maudlibGoonCertName}"
export maudUbergenKeyFileName="ubergen_credentials.dat"
export maudUbergenKeyFileSpec="${maudCertsFolder}/${maudUbergenKeyFileName}"

export ubergenBuildVariables="${ubergenFolder}/build-variables.sh"
export ubergenVersionFile="${ubergenFolder}/core-configuration.sh"

