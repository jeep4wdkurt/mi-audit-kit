#
# core-install.sh
#
#	MAUDE Installation related routines
#
#	Description:
#
#       Routines specific to installation and publication
#
#	Copyright:
#		Copyright (c) 2022, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.01.29  01.00    KurtSchulte    Original Version
#
####################################################################################################

#
# MAUDE Dataset Encryption Salt generation
#
datasetSaltGenerate() {
	local saltPass="$1"
	local saltLength=128
	progLabel="${datasetSaltGenerate}" ; barfts "${progLabel}.Entry(saltLength=${saltLength},saltFile='${datasetSaltFile}')..."

	[ "${saltPass}" == "" ] && barfee "Pass phrase is required."

	# Make Dataset Salt
	head -c $(( $saltLength * 4 )) /dev/random |
		tr -d '[\n\r]' |
		sed -e 's~[^A-Za-z0-9_#^&%]*~~g' |
		head -c $saltLength |
		$gpgCommand --batch --symmetric --passphrase "${saltPass}" >"${datasetSaltFile}"

	errCode=$? ; [ $errCode -ne 0 ] && barfee "Problem generating dataset salt file '${datasetSaltFile}'"

	barfvs "MAUDE Dataset Salt Generate complete."
	
	barfts "datasetSaltGenerate.Exit"
}

#
# Get dataset encryption salt
#
datasetSaltFetch() {
	local saltPass="$1"
	progLabel="datasetSaltFetch"
	barfts "${progLabel}.Entry()"

	# Get Dataset Salt
	[ ! -f "${datasetSaltFile}" ] && barfee "Can't find salt file '${datasetSaltFile}'"
	datasetSalt=$($gpgCommand --quiet --batch --decrypt --output - --passphrase "${saltPass}" "${datasetSaltFile}")
	errCode=$? 
	if [ $errCode -ne 0 ] || [ "${datasetSalt}" == "" ] ; then
		barfee "Bad pass phrase for salt."
	fi
	#barfd "datasetSalt : ${datasetSalt}"
	barfts "datasetSaltFetch.Exit"
}

#
# Pull latest MAUDE Software project from github
#
softwareProjectPull() {
	progLabel="softwareProjectPull" ; barfts "${progLabel}.Entry()"
	
	softwarePullStatus=1	; export softwarePullStatus

	if [ ! -d "${maudSoftwareKitFolder}" ] ; then
		# Clone MAUDE Software kit project
		[ ! -d "${maudKitsRoot}" ] &&
			barfee "Configuration problem - Can't find [maudKitsRoot] folder '${maudKitsRoot}', aborting."
		cd "${maudKitsRoot}"
		
		barfvs "MAUDE Software project coning..."
		git clone "${maudSoftwareKitProject}"
		errorCode=$?
		[ $errorCode -eq 0 ] && { cd "${maudSoftwareKitFolder}" ; git config pull.rebase false ; }
		[ $errorCode -ne 0 ] && barfee "Failed to clone MAUDE softare project '${maudSoftwareKitProject}'"
		barfvs "MAUDE.SoftwareProjectPull. MAUDE Software project cloning complete."
	else
		# Pull latest version of MAUDE Software kit
		cd "${maudSoftwareKitFolder}"
		
		barfvs "MAUDE Software pulling latest version of project..."
		git pull origin main
		errorCode=$?
 		[ $errorCode -ne 0 ] && barfee "Failed to pull latest version of MAUDE software project"
		barfvs "MAUDE Software pulling latest version of project complete."
	fi
	
	softwarePullStatus=0	; export softwarePullStatus
	
	barfts "softwareProjectPull.Exit(softwarePullStatus=${softwarePullStatus})"
}

#
# Pull latest MAUDE Reference data project from github
#
referenceDataProjectPull() {
	progLabel="referenceDataProjectPull" ; barfts "${progLabel}.Entry()"

	referencePullStatus=1	; export referencePullStatus

	if [ ! -d "${maudDataKitFolder}" ] ; then
		# Clone MAUDE Reference Data kit project
		[ ! -d "${maudKitsRoot}" ] &&
			barfee "Configuration problem - Can't find [maudKitsRoot] folder '${maudKitsRoot}', aborting."
		cd "${maudKitsRoot}"
		
		barfvs "MAUDE Reference Data cloning reference data project..."
		git clone "${maudDataKitProject}"
		errorCode=$?
		[ $errorCode -eq 0 ] && { cd "${maudDataKitFolder}"; git config pull.rebase false ; errCode=$? ; }
		[ $errorCode -ne 0 ] && barfee "Failed to clone MAUDE Reference Data project '${maudDataKitProject}'"
		barfvs "MAUDE.ReferenceDataProjectPull: MAUDE Data install cloning reference data project complete."
	else
		# Pull latest version of MAUDE Reference Data kit
		cd "${maudDataKitFolder}"
		
		barfvs "MAUDE Reference Data pulling latest version of reference project..."
		git pull origin main
		errorCode=$?
 		[ $errorCode -ne 0 ] && barfee "Failed to pull latest version of MAUDE Reference Data project"
		barfvs "MAUDE Reference Data pulling latest version of reference data project complete."
	fi

	barfds "HERE1"
	referencePullStatus=0	; export referencePullStatus
	
	barfts "referenceDataProjectPull.Exit(referencePullStatus=${referencePullStatus})"
}

#
# Verify UberGen is installed
#
ubergenProjectVerifyInstalled() { 
	progLabel="ubergenProjectVerifyInstalled" ; barfts "${progLabel}.Entry()"

	ubergenIsInstalled="N"	; export ubergenIsInstalled

	[ "${ubergenRoot}" == "" ]			&& barfee "[ubergenRoot] is not defined"
	[ "${ubergenFolder}" == "" ]		&& barfee "[ubergenFolder] is not defined"
	[ "${ubergenKitProject}" == "" ]	&& barfee "[ubergenKitProject] is not defined"

	if [ -d "${ubergenFolder}" ] ;then
		ubergenIsInstalled="Y"	; export ubergenIsInstalled
	fi
	
	barfts "ubergenProjectVerifyInstalled.Exit(ubergenIsInstalled=${ubergenIsInstalled})"
}


#
# Pull latest UberGen project from github
#
ubergenProjectPull() {
	progLabel="ubergenProjectPull" ; barfts "${progLabel}.Entry()"
	
	ubergenPullStatus=1	; export ubergenPullStatus

	[ "${maudFolderPerms}" == "" ]		&& barfee "[maudFolderPerms] is not defined"
	[ "${ubergenRoot}" == "" ]			&& barfee "[ubergenRoot] is not defined"
	[ "${ubergenFolder}" == "" ]		&& barfee "[ubergenFolder] is not defined"
	[ "${ubergenKitProject}" == "" ]	&& barfee "[ubergenKitProject] is not defined"

	# Get UberGen Key Code
	ubergenKeycodeDecode "${optPass}"
	
	barfds "DEBUG: UberGen Keycode Decode : ${ubergenKeycodeStatus}"
	#barfds "DEBUG: UberGen Keycode        : ${ubergenKeycode}"
	if [ "${ubergenKeycodeStatus}" == "" ] || [ $ubergenKeycodeStatus -ne 0 ] ; then
		barfee "Problem decrypting UberGen pass code"
	fi
	[ "${ubergenKeycode}" == "" ] && barfee "HUGE PROBLEM - UberGen key code decrypted to blank"

	# Get project
	local unpackNeeded=1
	
	if [ ! -d "${ubergenFolder}" ] ; then
		# Clone UberGen kit project
		[ ! -d "${ubergenRoot}" ] &&
			barfee "Can't find [ubergenRoot] folder '${ubergenRoot}', aborting."
		cd "${ubergenRoot}"
		
		barfs "UberGen project cloning ..."
		git clone "${ubergenKitProject}"
		errorCode=$?
		[ $errorCode -eq 0 ] && { cd "${ubergenFolder}" ; git config pull.rebase false ; }
		[ $errorCode -ne 0 ] && barfee "Failed to clone UberGen project '${ubergenKitProject}'"
		barfs "UberGen project cloning complete."
	else
		# Create user temp folder if not already there
		folderCreate  "${tempFolder}" "USER Local TEMP" $maudFolderPerms

		# Pull latest version of UberGen kit
		barfs "UberGen pulling latest version of project..."
		local gitTempLogFile="${tempFolder}/git.log"		
		cd "${ubergenFolder}"
		git pull origin main >"${gitTempLogFile}"
		errorCode=$? ;  [ $errorCode -ne 0 ] && barfee "Failed to pull latest version of UberGen project"

		# Determine if code was already up to date, or whether code pulled and needs an unpack
		uberAlreayUpdated=$(cat "${gitTempLogFile}" | grep -c 'Already up to date')
		[ $uberAlreayUpdated -ne 0 ] && unpackNeeded=0
		
		# Clean up log file
		rm "${gitTempLogFile}"

		barfs "UberGen pulling latest version of project complete."
	fi
	
	# unpack project
	if [ $unpackNeeded -ne 0 ] ; then
		barfs "UberGen unpacking project..."

		# Remove key file, so unpack will unpack
		keyFile="${ubergenFolder}/osinfo.sh"
		[ -f "${keyFile}" ] && rm $verboseFlag "${keyFile}"

		# Unpack UberGen kit
		local logFlag= ; [ $optLog ] && logFlag="-L"'"'"${optLogFile}"'"'
		cd "${ubergenFolder}"
		./ubergen.sh -u -P "${ubergenKeycode}" $logFlag
		errCode=$?
		barfs "UberGen unpacking project complete."
		[ $errorCode -ne 0 ] && barfee "Failed to unpack latest version of UberGen project"
	fi
	
	ubergenPullStatus=0	; export ubergenPullStatus

	barfts "ubergenProjectPull.Exit(ubergenPullStatus=${ubergenPullStatus})"
}

#
# Uninstall Ubergen Project, possibly based on version number
#
ubergenProjectUninstall() {
	local minVersion="$1"
	progLabel="ubergenProjectUninstall" ; barfts "${progLabel}.Entry(minVersion=${minVersion})"

	ubergenUninstallStatus=1	; export ubergenUninstallStatus

	[ "${ubergenRoot}" == "" ]				&& barfee "[ubergenRoot] is not defined"
	[ "${ubergenFolder}" == "" ]			&& barfee "[ubergenFolder] is not defined"
	[ "${ubergenVersionFile}" == "" ]		&& barfee "[ubergenVersionFile] is not defined"

	if [ -d "${ubergenFolder}" ] ;then

		# Determine if uninstall is needed
		local needUninstall=1
		if [ "${minVersion}" != "" ] ; then
			installedVersion=$(cat "${ubergenVersionFile}" | grep 'UBERGEN_VERSION' | sed -e 's~^.*=~~;s~#.*~~;s~ \+$~~' )
			errCode=$? ; [ $errCode -ne 0 ] &&
				barfee "Can't read UberGen version file '${ubergenVersionFile}'"
			[ "${installedVersion}" == "" ] && installedVersion=01.00

			[ $(echo "${installedVersion}" | grep -c '^[0-9][0-9][.][0-9][0-9]$') -eq 0 ] &&
				barfee "Bad installed version number format in UberGen version file '${ubergenVersionFile}', version='${installedVersion}'"
				
			versionCompare=$(perl -e "print (( ${installedVersion} < ${minVersion} ) ? "'"1":"0"); ')
			errCode=$? ; [ $errCode -ne 0 ] && barfee "Can't test UberGen version. Code Error."
			[ "${versionCompare}" == "0" ] && needUninstall=0
		fi
		
		# Uninstall UberGen
		if [ $needUninstall -ne 0 ] ; then
			find "${ubergenFolder}" -type f -printf '"%p"\n' | xargs -L1 rm $verboseFlag
			errCode=$? ; [ $errCode -ne 0 ] && barfee "Can't remove UberGen files(s)."

			find "${ubergenFolder}" -type d -printf '"%p"\n' | sort -r | xargs -L1 rmdir $verboseFlag
			errCode=$? ; [ $errCode -ne 0 ] && barfee "Can't remove UberGen folder(s)."
		fi
	fi
	
	ubergenUninstallStatus=0	; export ubergenUninstallStatus
	
	barfts "ubergenProjectUninstall.Exit(ubergenUninstallStatus=${ubergenUninstallStatus})"
}

#
# Encode UberGen Key Code
#
ubergenKeycodeEncode() {
	local keyPass="$1"
	local keyFilespec="$2"
	progLabel="ubergenKeycodeEncode" ; barfts "${progLabel}.Entry(keyCodeFile='${keyFilespec}')"

	[ "${keyPass}" == "" ]		&& barfee "[keyPass] may not be blank"
	[ "${keyFilespec}" == "" ]	&& barfee "[keyFilespec] is not defined"

	ubergenKeycodeStatus=1 ; 		export ubergenKeycodeStatus

	# Prompt for key code
	local ubergenKeycode=
	while [ "${ubergenKeycode}" == "" ] ; do
		read -p "UberGen Key Code: " ubergenKeycode
		errCode=$? ; [ $errCode -ne 0 ] && barfee "Bad, bad user."
	done

	# Encode key code
	echo "${ubergenKeycode}" |
		$gpgCommand --batch --symmetric --passphrase "${keyPass}" >"${keyFilespec}"
	errCode=$? ; [ $errCode -ne 0 ] && barfee "Problem encrypting UberGen key code."

	ubergenKeycodeStatus=0 ; 		export ubergenKeycodeStatus

	barfds "MAUDE UberGen Keycode Encode complete."
	
	barfts "ubergenKeycodeEncode.Exit(ubergenKeycodeStatus=${ubergenKeycodeStatus})"
}

#
# Decode UberGen Key Code
#
ubergenKeycodeDecode() {
	local keyPass="$1"
	progLabel="ubergenKeycodeDecode" ; barfts "${progLabel}.Entry(keyCodeFile='${maudUbergenKeyFileSpec}')"

	ubergenKeycodeStatus=1 ; 		export ubergenKeycodeStatus
	ubergenKeycode="<invalid>" ;	export ubergenKeycode
	
	[ "${keyPass}" == "" ]					&& barfee "[keyPass] may not be blank"
	[ "${maudUbergenKeyFileSpec}" == "" ]	&& barfee "[maudUbergenKeyFileSpec] is not defined"

	# decode key code
	ubergenKeycode=$(cat "${maudUbergenKeyFileSpec}" |
					 $gpgCommand --quiet --batch --decrypt --output - --passphrase "${keyPass}")
	errCode=$? ; [ $errCode -ne 0 ] && barfee "Problem decrypting UberGen key code."
	export ubergenKeycode;
	
	ubergenKeycodeStatus=0 ; export ubergenKeycodeStatus;

	barfds "MAUDE UberGen Keycode Decode complete."
	
	barfts "ubergenKeycodeDecode.Exit(ubergenKeycodeStatus=${ubergenKeycodeStatus})"
}