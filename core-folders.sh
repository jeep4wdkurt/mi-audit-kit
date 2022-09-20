#
# core-folders.sh
#
#	MAUDE Folder definitions
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
#       2022.01.20  01.00    KurtSchulte    Original Version
#
####################################################################################################

#
# Folders
#
export maudRootFolder
export maudProgFolder

export tempFolder="${HOME}/temp"

export homeFolder=$(echo "${HOME}" | sed -e 's~/$~~')
export maudLocalFolder="${homeFolder}/mi-audit"				
export maudLocalCertsFolder="${maudLocalFolder}/certs"			
export maudCertsFolder="${maudRootFolder}/certs"				
export maudDdlFolder="${maudRootFolder}/ddl"					
export maudPerlFolder="${maudRootFolder}/perl"					
export maudPythonFolder="${maudRootFolder}/python"
export maudPythonLibraryFolder="${maudRootFolder}/python/maudelib"
export maudImagesFolder="${maudRootFolder}/images"
export maudBackgroundsFolder="${maudImagesFolder}/backgrounds"
export maudBackgroundDefaultName="MAUDE-MI-logo-1300x1300.png"
export maudBackgroundDefaultFile="${maudBackgroundsFolder}/${maudBackgroundDefaultName}"
export maudNetworkDataFolder="/mnt/audd"

if [ $(echo "${PYTHONPATH}" | grep -c 'maudelib') -eq 0 ] ; then
	if [ "${PYTHONPATH}" == "" ] ; then
		PYTHONPATH="${maudPythonLibraryFolder}"
	else
		PYTHONPATH="${maudPythonLibraryFolder}:${PYTHONPATH}"
	fi
	export PYTHONPATH
fi

#barfs "maudProgFolder          : ${maudProgFolder}"
#barfs "maudPythonLibraryFolder : ${maudPythonLibraryFolder}"
#barfs "PYTHONPATH              : ${PYTHONPATH}"

if [ "${OSTYPE}" == "linux-gnu" ] ;then
	export maudDataFolder="/var/lib/mi-audit-data"
else
	export maudParentFolder="${maudRootFolder%/*}"
	export maudDataFolder="${maudParentFolder}/mi-audit-data"
fi

export maudReferenceFolder="${maudDataFolder}/reference"
export maudStateDataFolder="${maudDataFolder}/state"
export maudCountyDataFolder="${maudDataFolder}/county"
export maudReportFolder="${maudDataFolder}/reports"	

export maudTransitFolder="${maudDataFolder}/transit"
export maudLogFolder="${maudTransitFolder}/log"		
export maudInboundFolder="${maudTransitFolder}/inbound"		
export maudOutboundFolder="${maudTransitFolder}/outbound"

export maudWorkFolder="${maudTransitFolder}/work"

export maudUserSharedFolder="/usr/share/mi-audit"
export maudUserSharedBackgroundsFolder="${maudUserSharedFolder}/backgrounds"
export maudUserSharedBackgroundDefaultFile="${maudUserSharedBackgroundsFolder}/${maudBackgroundDefaultName}"

#
# Files
#
export maudReadmeFile="${maudRootFolder}/README.md"			
export maudVersionFile="${maudProgFolder}/core-version.sh"	

#
# Constants
# 
export maudFolderPerms=754
export maudFilePerms=744
export maudPublicExecutablePerms=755
export maudPublicFolderPerms=755
export maudPublicReportFolderPerms=777
