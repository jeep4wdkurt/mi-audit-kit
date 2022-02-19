#
# core-filesystem.sh
#
#	MAUDE File system related routines
#
#	Description:
#
#       Routines specific to file system operations
#
#	Copyright:
#		Copyright (c) 2022, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.01.30  01.00    KurtSchulte    Original Version
#
####################################################################################################

#
# Create and optionally permission a folder
#
folderCreate() {
	local folderSpec="$1"
	local folderDesc="$2"	
	local folderPerms=$3
	barfds "folderCreate(folder='${folderSpec}',desc='${folderDesc}',perms='${folderPerms}')..."
	
	[ "${folderSpec}" == "" ] && barfe "folderCreate.Error: Folder spec cannot be blank." 
	
	if [ -d "${folderSpec}" ] ; then
		barfds "folderCreate.FolderExists"
	else
		mkdir $verboseFlag "${folderSpec}"
		errCode=$? ; [ $errCode -ne 0 ] && barfe "folderCreate.Error: Problem creating ${folderDesc} folder '${folderSpec}'."
		
		if [ "${folderPerms}" != "" ] ; then
			chmod $verboseFlag $folderPerms "${folderSpec}"
			errCode=$? ; [ $errCode -ne 0 ] &&
				barfe "folderCreate.Error: Problem permissioning ${folderDesc} folder '${folderSpec}'." ;
		fi
	fi
	
	barfds "folderCreate.Success"
	errCode=0			# Force exit status to 0 by doing something valid
}