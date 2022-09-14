#
# maude-install.sh
#	
#	Description:
#
#		Utility to install MAUDE software and/or data kits.
#
#           Folder                  	Use
#           ------------------      	---------------------------------------
#           /opt/mi-audit-kit       	MAUDE Software Distribution Kit
#           /opt/mi-audit-data-kit  	MAUDE Reference Data Distribution Kit
#           /usr/sbin/mi-audit      	MAUDE Application
#           /var/lib/mi-audit-data  	MAUDE Data
#			${HOME}/mi-audit/certs		MAUDE Local User Certs
#
#	Usage:
#       maude-install.sh [-lavdt] [-L <logfile>] -P <pass-phrase> [-A] [-s] [-D <dataset>[,<dataset>,...]]
#
#           Options:
#               -A            Install all (software, and any available datasets)
#               -s            Install MAUDE software
#               -D            Install MAUDE Dataset IDs (all|[[reference,][YYYY-MM-DD,]...])
#               -C            Dataset components(s) to install (all[default], qvf, or history)
#               -P            Pass phrase
#               -l            Log (create)
#               -a            Log (append)
#               -L <logfile>  Write log data to <logfile> (default=./ubergen.log)
#               -v            Verbose (displays detailed info)
#               -d            Debug (displays more detailed info)
#               -t            Trace (displays exhaustive info)
#
#            Examples:
#                ./maude-install.sh                          # Install software, and reference data (same as -s -D common)
#                ./maude-install.sh -A                       # Install software, reference data, and any available datasets
#                ./maude-install.sh -D 2021-01-01            # Install dataset 2021-01-01
#                ./maude-install.sh -s -D "reference,2021-01-01" -P "secret"	# Install software, reference data, and 2021-01-01 dataset
#
#	Copyright:
#		Copyright (c) 2022, F. Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#		Date		Version		Author			Desc
#		2022.01.24	01.00		FKSchulte		Original Version
#
prognm=maude-install.sh

kitFolderAbs=$(echo "${0%/*}" | sed -e "s~^[.]~`pwd`~")
kitRootFolder="${kitFolderAbs%/*}"
maudRootFolder="${kitFolderAbs}"
cd "${kitFolderAbs}"

export kitProgFolder="${kitFolderAbs}"

#
# Core Routines
#
source "${kitProgFolder}/core-folders.sh"						# MAUDE Application folders
source "${kitProgFolder}/core-install-folders.sh"				# MAUDE Installation folders
source "${kitProgFolder}/core-install.sh"						# MAUDE Installation routines
source "${kitProgFolder}/core-dataset.sh"						# MAUDE Dataset routines
source "${kitProgFolder}/core-filesystem.sh"					# MAUDE File system routines
source "${kitProgFolder}/core-io.sh"							# MAUDE IO routines
source "${kitProgFolder}/core-time.sh"							# MAUDE Time routines

#
# Constants
#
defaultLogFile="${maudLogFolder}/${prognm//.sh/}-$(date +%Y.%m.%d-%H.%M.%S).log"
datasetIdReference="reference"
specialDatasetList="${datasetIdReference}"
optDatasetList="all,${specialDatasetList},${datasetList}"
optDatasetComponentsList="all,qvf,history"

#
# MAUDE Prerequisites Install (pip and goon libraries)
#
maudePrerequsitesInstall() {

	local pipCommand="pip3"
	local pipPackage="python3-pip"

	# Install Python Pip
	if [ "${OS_FLAVOR}" == "Cygwin" ] ; then
		pipPackageCt=$($pipCommand list | wc -l)
		errorCode=?$?
		[ $errCode -ne 0 ] && barfe "maudePrerequsitesInstall: python pip package does not appear to be installed."
	else 
		pipInstalled=$(dpkg-query --list "*${pipPackage}*" | grep -c "^[a-z]i[ \t]*${pipPackage}[ \t].*")
		if [ $pipInstalled -eq 0 ] ; then
			barfs "MAUDE Prerequisite Python PIP installing..."
			apt-get install -y $pipPackage
			errCode=$?
			[ $errCode -ne 0 ] && barfe "maudePrerequsitesInstall: Problem installing python pip package (${pipPackage})."
			barfs "MAUDE Prerequisite Python PIP install complete."
		fi
	fi
 
	# Install Goon libraries
	goonLibsInstalled=$($pipCommand list | grep -c 'google-api-python-client')
	if [ $goonLibsInstalled -eq 0 ] ; then
	
		# Ubuntu SUX. No clue why it doesn't include testresources python lib, when Debian does.
		local osDependentLibs= ; [ "${OS_FLAVOR}" == "Ubuntu" ] && osDependentLibs="testresources"

		barfs "MAUDE Prerequisite Goon Libraries installing..."
		$pipCommand install --upgrade $osDependentLibs google-api-python-client google-auth-httplib2 google-auth-oauthlib
		errCode=$? ; [ $errCode -ne 0 ] && barfe "maudePrerequsitesInstall: Problem installing Goon libraries."
		barfs "MAUDE Prerequisite Goon Libraries install complete."
	fi
}

#
# MAUDE User Desktops Install
#
maudeUserDesktopsInstall() {

	[ "${maudBackgroundsFolder}" == "" ]			&& barfe "maudeUserDesktopsInstall.Error: maudBackgroundsFolder is not defined"
	[ "${maudBackgroundDefaultFile}" == "" ]		&& barfe "maudeUserDesktopsInstall.Error: maudBackgroundDefaultFile is not defined"
	[ "${maudUserSharedFolder}" == "" ]				&& barfe "maudeUserDesktopsInstall.Error: maudUserSharedFolder is not defined"
	[ "${maudUserSharedBackgroundsFolder}" == "" ]	&& barfe "maudeUserDesktopsInstall.Error: maudUserSharedBackgroundsFolder is not defined"
	[ "${maudFolderPerms}" == "" ]					&& barfe "maudeUserDesktopsInstall.Error: maudFolderPerms is not defined"
	[ "${maudPublicFolderPerms}" == "" ]			&& barfe "maudeUserDesktopsInstall.Error: maudPublicFolderPerms is not defined"
	[ "${maudFilePerms}" == "" ]					&& barfe "maudeUserDesktopsInstall.Error: maudFilePerms is not defined"
	[ "${maudPublicExecutablePerms}" == "" ]		&& barfe "maudeUserDesktopsInstall.Error: maudPublicExecutablePerms is not defined"

	# Create MAUDE User Shared Backgrounds folder
	folderCreate "${maudUserSharedFolder}" "MAUDE shared user data" $maudPublicFolderPerms
	folderCreate "${maudUserSharedBackgroundsFolder}" "MAUDE shared user backgrounds" $maudPublicFolderPerms
	
	# Copy default MAUDE desktop background to shared folder
	cp $verboseFlag --target-directory "${maudUserSharedBackgroundsFolder}" "${maudBackgroundDefaultFile}"
	errCode=$? ; [ $errCode -ne 0 ] && barfe "maudeUserDesktopsInstall.Error: Problem copying default background from kit'${maudBackgroundDefaultFile}'"

	chmod $verboseFlag $maudFilePerms "${maudUserSharedBackgroundDefaultFile}"
	errCode=$? ; [ $errCode -ne 0 ] && barfe "maudeUserDesktopsInstall.Error: Problem permissioning default background '${maudUserSharedBackgroundDefaultFile}'"

	# Create maude system profile script
	cp $verboseFlag --target-directory /etc/profile.d "${maudSoftwareKitDesktopSetupScript}"
	errCode=$? ; [ $errCode -ne 0 ] && barfe "maudeUserDesktopsInstall.Error: Problem copying MAUDE system profile desktop setup script from kit '${maudSoftwareKitDesktopSetupScript}'"

	chmod $verboseFlag $maudPublicExecutablePerms "${maudSystemSharedDesktopSetupScript}"
	errCode=$? ; [ $errCode -ne 0 ] && barfe "maudeUserDesktopsInstall.Error: Problem permissioning MAUDE system profile desktop setup script '${maudSystemSharedDesktopSetupScript}'"
}

#
# MAUDE Fix Folder Perms
#
maudeFolderPermsFix() {

	[ "${maudDataFolder}" == "" ]					&& barfe "maudeUserDesktopsInstall.Error: maudDataFolder is not defined"
	[ "${maudFolderPerms}" == "" ]					&& barfe "maudeUserDesktopsInstall.Error: maudFolderPerms is not defined"
	[ "${maudPublicFolderPerms}" == "" ]			&& barfe "maudeUserDesktopsInstall.Error: maudPublicFolderPerms is not defined"
	
	if [ -d "${maudDataFolder}" ] ; then
		chmod $verboseFlag $maudPublicFolderPerms "${maudDataFolder}"
		find "${maudDataFolder}" -type d -printf '"%p"\n' | xargs -L1 chmod $verboseFlag $maudPublicFolderPerms
	fi
	
	if [ -d "${maudReportFolder}" ] ; then
		chmod $verboseFlag $maudPublicReportFolderPerms "${maudReportFolder}"
		find "${maudReportFolder}" -type d -printf '"%p"\n' | xargs -L1 chmod $verboseFlag $maudPublicReportFolderPerms
	fi

}

#
# MAUDE Software Install
#
maudeSoftwareInstall() {
	barfs "MAUDE Software installing..."

	[ "${maudAppFolder}" == "" ] 					&& barfe "maudeSoftwareInstall.Error: maudAppFolder is not defined"
	[ "${maudAppsRoot}" == "" ]  					&& barfe "maudeSoftwareInstall.Error: maudAppsRoot is not defined"
	[ "${maudLocalFolder}" == "" ]  				&& barfe "maudeSoftwareInstall.Error: maudLocalFolder is not defined"
	[ "${maudLocalCertsFolder}" == "" ]				&& barfe "maudeSoftwareInstall.Error: maudLocalCertsFolder is not defined"
	[ "${maudFolderPerms}" == "" ]					&& barfe "maudeSoftwareInstall.Error: maudFolderPerms is not defined"
	[ "${maudPublicFolderPerms}" == "" ]			&& barfe "maudeSoftwareInstall.Error: maudPublicFolderPerms is not defined"
	[ "${maudUserGoonCert}" == "" ]					&& barfe "maudeSoftwareInstall.Error: maudUserGoonCert is not defined"
	[ "${maudlibGoonCertName}" == "" ]				&& barfe "maudeSoftwareInstall.Error: maudlibGoonCertName is not defined"
	[ "${maudSoftwareKitArchivePattern}" == "" ]	&& barfe "maudeSoftwareInstall.Error: maudSoftwareKitArchivePattern is not defined"

	# Fix Folder Permissions ###TODO: Remove###
	maudeFolderPermsFix

	# Install prerequisites if needed
	maudePrerequsitesInstall

	# Determine kit zip file name
	local kitFileCt=$(find "${kitFolderAbs}" -type f -regex "${maudSoftwareKitArchivePattern}" | wc -l)
	#echo "kitFileCt  = ${kitFileCt}"
	[ $kitFileCt -ne 1 ] && barfe "Software kit configuration problem, ${kitFileCt} MAUDE Software kits found... aborting. "
	local kitZipFile=$(find "${kitFolderAbs}" -type f -regex "${maudSoftwareKitArchivePattern}")
	#echo "maudSoftwareKitArchivePattern  = ${maudSoftwareKitArchivePattern}"
	#echo "kitZipFile  = ${kitZipFile}"

	# Remove any prior install
	if [ -d "${maudAppFolder}" ] ; then
		maudeFileCt=$(find "${maudAppFolder}" -type f | wc -l)
		#echo "maudeFileCt = ${maudeFileCt}"
		if [ $maudeFileCt -ne 0 ] ; then
			find "${maudAppFolder}" -type f -exec rm '{}' \;
		fi
		find "${maudAppFolder}" -type d | sort -r | xargs -L1 rmdir $verboseFlag
		[ -d "${maudAppFolder}" ] && barfe "ERROR! Failed to remove MAUDE application folder ''"
	fi

	# Install MAUDE software
	cd "${maudAppsRoot}"
	if [ ! -d "${maudAppFolder}" ] ; then
		folderCreate "${maudAppFolder}" "MAUDE Application" $maudPublicFolderPerms
 		errCode=$?
		[ $errCode -ne 0 ] && barfe "maudeSoftwareInstall.Error: MAUDE App folder '${maudAppFolder}' cannot be created (err=${errCode})."
	fi
	cd "${maudAppFolder}"
	quietFlag="-q"
	[ $optVerbose ] && quietFlag=
	unzip $quietFlag -P "${optPass}" "${kitZipFile}"
	errorCode=$?
	[ $errorCode -ne 0 ] && barfe "maudeSoftwareInstall.Error: MAUDE failed to install. :-("

	# Make scripts executable
	find "${maudAppFolder}/bash" -type f -iregex '.*[.]sh' | xargs -L1 chmod 740

	# Create user certs folder, if needed.
	folderCreate "${maudLocalFolder}" "MAUDE local user data" $maudFolderPerms
	folderCreate "${maudLocalCertsFolder}" "MAUDE local user certs" $maudFolderPerms

	# Decrypt Goon cert
	local kitGoonCert="${maudCertsFolder}/${maudlibGoonCertName}"
	[ ! -f "${kitGoonCert}" ] && barfe "maudeSoftwareInstall.CertError: Configuration problem; cert file is not in kit."
	
	barfds "kitGoonCert      : '${kitGoonCert}'"
	barfds "maudUserGoonCert : '${maudUserGoonCert}'"
	
	[ -f "${maudUserGoonCert}" ] && rm $verboseFlag "${maudUserGoonCert}"
	$gpgCommand --batch --quiet --decrypt --passphrase "${optPass}" --output "${maudUserGoonCert}" "${kitGoonCert}"
	errCode=$?
	[ $errCode -ne 0 ] && barfe "maudeSoftwareInstall.DecryptGoonCert.Error: Can't decrypt Goon cert file '${kitGoonCert}'."
	
	# Install user desktops
	maudeUserDesktopsInstall

	# Done
	barfs "MAUDE Software has been installed to ${maudAppFolder}."
}

#
# MAUDE Reference Data Install
#
maudeReferenceDataInstall() {

	barfs "MAUDE Reference Data Installing..."
	referenceDataInstallTimer=$(timerStart "ReferenceeDataInstall")

	[ "${maudAppsRoot}" == "" ]  			&& barfe "maudeReferenceDataInstall.Error: maudAppsRoot is not defined"
	[ "${maudCommonDataFolder}" == "" ] 	&& barfe "maudeReferenceDataInstall.Error: maudCommonDataFolder is not defined"
	[ "${maudDataKitFolder}" == "" ] 		&& barfe "maudeReferenceDataInstall.Error: maudDataKitFolder is not defined"
	
	# Pull latest data kit from repository
	referenceDataProjectPull
	barfds "HERE2"
	if [ "${referencePullStatus}" == "" ] || [ $referencePullStatus -ne 0 ] ; then
		barfe "maudeReferenceDataInstall.Error: Problem pulling reference data project"
	fi
	barfds "MAUDE Reference project pull success."
	
	# Determine kit zip file name
	local kitFileCt=$(find "${maudDataKitFolder}" -type f -regex "${maudDataKitArchivePattern}" | wc -l)
	#echo "kitFileCt  = ${kitFileCt}"
	[ $kitFileCt -ne 1 ] && barfe "Reference Data kit configuration problem, found ${kitFileCt} zip files.... aborting."
	local kitZipFile=$(find "${maudDataKitFolder}" -type f -regex "${maudDataKitArchivePattern}")
	
	# Create MAUDE datafolder if needed
	#           /var/lib/mi-audit-data  MAUDE Data
	if [ ! -d "${maudCommonDataFolder}" ] ; then
		folderCreate "${maudCommonDataFolder}" "MAUDE Common Data" $maudPublicFolderPerms
	fi

	barfds "MAUDE Reference Data unpack..."
	# Install MAUDE Reference Data
	cd "${maudCommonDataFolder}"
	unzip -o -P "${optPass}" "${kitZipFile}"
	errorCode=$? ; [ $errorCode -ne 0 ] && barfe "MAUDE Reference Data failed to install. :-("

	elapsedTime=$(timerElapsed ${referenceDataInstallTimer})
	barfs "MAUDE Reference Data install complete. Elapsed: ${elapsedTime}"
}

# Clean up dataset import work files
#
maudeWorkDataCleanup() {
	local datasetWorkFolder="$1"
	local datasetWorkFilePattern='^.*[.]\(csv\|cks\|dat\|zip\|qvz\)$'

	[ "${datasetWorkFolder}" == "" ] && barfe "maudeWorkDataCleanup.Error: datasetWorkFolder is blank!"

	if [ -d "${datasetWorkFolder}" ] ; then
		cd "${datasetWorkFolder}"
		[ $( find . -type f -regex "${datasetWorkFilePattern}" | wc -l ) -gt 0 ] &&
			find . -type f -regex "${datasetWorkFilePattern}" -exec rm $verboseFlag '{}' \;
	fi
}

#
# MAUDE QVF Data Install
#
maudQvfInstall() {
	local datasetID="$1"

	barfs "MAUDE Dataset ${datasetID} QVF installing..."
	qvfInstallTimer=$(timerStart "QvfInstall")
	
	[ "${datasetID}" == "" ] 			&& barfe "maudQvfInstall.Error: datasetID parameter was not passed"
	[ "${datasetName}" == "" ] 			&& barfe "maudQvfInstall.Error: datasetName parameter was not passed"
	[ "${datasetSalt}" == "" ]			&& barfe "maudQvfInstall.Error: datasetSalt is not defined"
	[ "${datasetWorkFolder}" == "" ]	&& barfe "maudQvfInstall.Error: datasetWorkFolder is not defined"
	[ "${maudDataKitFolder}" == "" ]	&& barfe "maudQvfInstall.Error: maudDataKitFolder is not defined"
	[ "${maudStateDataFolder}" == "" ]	&& barfe "maudQvfInstall.Error: maudStateDataFolder is not defined"
	[ "${maudWorkFolder}" == "" ]		&& barfe "maudQvfInstall.Error: maudWorkFolder is not defined"
	[ "${datasetQvfObfuscationName}" == "" ]	&& barfe "maudQvfInstall.Error: datasetQvfObfuscationName is not defined"
	[ "${PYTHONPATH}" == "" ]			&& barfe "maudQvfInstall.Error: PYTHONPATH is not defined"

	barfds "maudQvfInstall.PYTHONPATH : '${PYTHONPATH}'"
	
	DatasetId_Validate "${datasetID}"

	# Check if dataset file exists
	# [ -f "${datasetFilespec}" ] && [ ! $optOverwrite ] &&
	#	barfe "Error. Dataset ${datasetID} file exists. Delete, or use overwrite option (-O)"

	# Warn and skip, if dataset has not been uploaded to server
	if [ "${datasetGoonKey}" == "${datasetGoonKeyNA}" ] || [ "${datasetGoonKey}" == "" ] ; then
		barfs "WARNING: MAUDE Dataset ${datasetID} QVF has no repository instance yet.  Skipping install."
		return 0
	fi

	# Determine QVF work file specs
	local workKitFile="${datasetWorkFolder}/${datasetQvfObfuscationName}-${datasetIdentifier}.qvz"
	local workArchiveFile="${datasetWorkFolder}/${datasetQvfObfuscationName}-${datasetIdentifier}.zip"
	local workDatasetFile="${datasetWorkFolder}/${datasetName}.csv"
	local workChecksumFile="${datasetWorkFolder}/${datasetName}.cks"

	# Fetch QVF dataset kit
	barfds "MaudeQvfDataInstall.FetchDataset..."
	pylogFlag="" ; [ $optLog ] && pylogFlag="--logfile="'"'"${optLogFile}"'"'
	python3 "${maudPythonFolder}/fetch.py" $debugFlag ${pylogFlag} \
				--googleid "${datasetGoonKey}" \
				--output "${workKitFile}" 			
	errorCode=$? ; [ $errorCode -ne 0 ] &&
	barfe "MaudeQvfDataInstall.FetchDataset: Failed to fetch goon file id '${datasetGoonKey}' for file '${workKitFile}'."	
	barfds "MaudeQvfDataInstall.FetchDataset complete."

	inChecksum=$(shasum "${workKitFile}")
	barfds "Fetched encrypted kit checksum: ${inChecksum}"

	# Decrypt QVF Archive
	barfds "MaudeQvfDataInstall.DecryptDataset..."
	[ -f "${workArchiveFile}" ] && rm $verboseFlag "${workArchiveFile}"
	$gpgCommand --batch --decrypt --passphrase "${datasetSalt}" --output "${workArchiveFile}" "${workKitFile}"
	errCode=$?
	[ $errCode -ne 0 ] && barfe "MaudeQvfDataInstall.DecryptDataset.Error: Can't decrypt dataset file '${workKitFile}'."
	barfds "MaudeQvfDataInstall.DecryptDataset complete."

	# Restore QVF files from archive.  Clean up any old work files, first.
	barfds "MaudeQvfDataInstall.ArchiveExpand..."
	cd "${datasetWorkFolder}"
	unzip -P "${optPass}" "${workArchiveFile}"
	errorCode=$?
	[ $errorCode -ne 0 ] && barfe "MaudeQvfDataInstall.ArchiveExpand: Problem expanding archive '${workArchiveFile}'"

	# Check QVF files restored okay
	[ ! -f "${workDatasetFile}" ]  && barfe "MaudeQvfDataInstall.ArchiveExpand: Dataset file missing?"
	[ ! -f "${workChecksumFile}" ] && barfe "MaudeQvfDataInstall.ArchiveExpand: Dataset checksum file missing?"
	barfds "MaudeQvfDataInstall.ArchiveExpand complete."
	
	# Check QVF data matches published checksum
	barfds "MaudeQvfDataInstall.ChecksumValidate..."
	restoredChecksum=$(shasum "${workDatasetFile}")
	errCode=$? ; [ $errCode -ne 0 ] &&
		barfe "MaudeQvfDataInstall.ChecksumValidate: Can't calculate checksum of dataset file '${workDatasetFile}'."
	restoredChecksum="${restoredChecksum:0:40}"
	expectedChecksum=$(head -c 40 "${workChecksumFile}")
	barfds "restoredChecksum: '${restoredChecksum}'"
	barfds "expectedChecksum: '${expectedChecksum}'"
	[ "${restoredChecksum}" != "${expectedChecksum}" ] &&
		barfe "MaudeQvfDataInstall.ChecksumValidate: Checksum of restored file doesn't match published value."
	barfds "MaudeQvfDataInstall.ChecksumValidate complete."
	
	# Move QVF data to destination
	mv $verboseFlag "${workDatasetFile}" "${datasetFilespec}"
	errCode=$? ; [ $errCode -ne 0 ] &&
		barfe "MaudeQvfDataInstall.Deploy: Can't move imported dataset '${workDatasetFile}' to destination '${datasetFilespec}'."

	elapsedTime=$(timerElapsed ${qvfInstallTimer})
	barfs "MAUDE Dataset ${datasetID} QVF install complete. Elapsed: ${elapsedTime}"
}

#
# MAUDE Voter History Install
#
maudVoterHistoryInstall() {
	local datasetID="$1"

	barfs "MAUDE Dataset ${datasetID} Voter History installing..."
	historyInstallTimer=$(timerStart "HistoryInstall")
	
	[ "${datasetID}" == "" ] 			&& barfe "maudVoterHistoryInstall.Error: datasetID parameter was not passed"
	[ "${datasetName}" == "" ] 			&& barfe "maudVoterHistoryInstall.Error: datasetName parameter was not passed"
	[ "${datasetSalt}" == "" ]			&& barfe "maudVoterHistoryInstall.Error: datasetSalt is not defined"
	[ "${datasetWorkFolder}" == "" ]	&& barfe "maudVoterHistoryInstall.Error: datasetWorkFolder is not defined"
	[ "${datasetHistoryFilespec}" == "" ]	&& barfe "maudVoterHistoryInstall.Error: datasetHistoryFilespec parameter was not passed"
	[ "${datasetHistoryObfuscationName}" == "" ] &&
											barfe "maudVoterHistoryInstall.Error: datasetHistoryObfuscationName is not defined"

	[ "${maudDataKitFolder}" == "" ]	&& barfe "maudVoterHistoryInstall.Error: maudDataKitFolder is not defined"
	[ "${maudStateDataFolder}" == "" ]	&& barfe "maudVoterHistoryInstall.Error: maudStateDataFolder is not defined"
	[ "${maudWorkFolder}" == "" ]		&& barfe "maudVoterHistoryInstall.Error: maudWorkFolder is not defined"
	[ "${PYTHONPATH}" == "" ]			&& barfe "maudQvfInstall.Error: PYTHONPATH is not defined"

	DatasetId_Validate "${datasetID}"

	# Check if voter history dataset file exists
	# [ -f "${datasetHistoryFilespec}" ] && [ ! $optOverwrite ] &&
	#	barfe "Error. Dataset ${datasetID} file exists. Delete, or use overwrite option (-O)"

	# Warn and skip, if dataset has not been uploaded to server
	if [ "${datasethistGoonKey}" == "${datasetGoonKeyNA}" ] || [ "${datasethistGoonKey}" == "" ] ; then
		barfs "WARNING: MAUDE Dataset ${datasetID} Voter History has no repository instance yet.  Skipping install."
		return 0
	fi

	# Determine Voter History work file specs
	local workKitFile="${datasetWorkFolder}/${datasetHistoryObfuscationName}-${datasetIdentifier}.qvz"
	local workArchiveFile="${datasetWorkFolder}/${datasetHistoryObfuscationName}-${datasetIdentifier}.zip"
	local workDatasetFile="${datasetWorkFolder}/${datasetHistoryName}.csv"
	local workChecksumFile="${datasetWorkFolder}/${datasetHistoryName}.cks"

	# Fetch Voter History dataset kit
	barfds "maudVoterHistoryInstall.FetchDataset..."
	pylogFlag="" ; [ $optLog ] && pylogFlag="--logfile="'"'"${optLogFile}"'"'
	python3 "${maudPythonFolder}/fetch.py" $debugFlag ${pylogFlag} \
		--googleid "${datasethistGoonKey}" \
		--output "${workKitFile}" 						
	errorCode=$? ; [ $errorCode -ne 0 ] &&
		barfe "maudVoterHistoryInstall.FetchDataset: Failed to fetch goon file id '${datasethistGoonKey}' for file '${workKitFile}'."	
	barfds "maudVoterHistoryInstall.FetchDataset complete."

	inChecksum=$(shasum "${workKitFile}")
	barfds "Fetched encrypted kit checksum: ${inChecksum}"

	# Decrypt Voter History Archive
	barfds "maudVoterHistoryInstall.DecryptDataset..."
	[ -f "${workArchiveFile}" ] && rm $verboseFlag "${workArchiveFile}"
	$gpgCommand --batch --decrypt --passphrase "${datasetSalt}" --output "${workArchiveFile}" "${workKitFile}"
	errCode=$?
	[ $errCode -ne 0 ] && barfe "maudVoterHistoryInstall.DecryptDataset.Error: Can't decrypt dataset file '${workKitFile}'."
	barfds "maudVoterHistoryInstall.DecryptDataset complete."

	# Restore Voter History files from archive.
	barfds "maudVoterHistoryInstall.ArchiveExpand..."
	cd "${datasetWorkFolder}"
	unzip -P "${optPass}" "${workArchiveFile}"
	errorCode=$?
	[ $errorCode -ne 0 ] && barfe "maudVoterHistoryInstall.ArchiveExpand: Problem expanding archive '${workArchiveFile}'"

	# Check Voter History files restored okay
	[ ! -f "${workDatasetFile}" ]  && barfe "maudVoterHistoryInstall.ArchiveExpand: Dataset file missing?"
	[ ! -f "${workChecksumFile}" ] && barfe "maudVoterHistoryInstall.ArchiveExpand: Dataset checksum file missing?"
	barfds "maudVoterHistoryInstall.ArchiveExpand complete."
	
	# Check Voter History data matches published checksum
	barfds "maudVoterHistoryInstall.ChecksumValidate..."
	restoredChecksum=$(shasum "${workDatasetFile}")
	errCode=$? ; [ $errCode -ne 0 ] &&
		barfe "maudVoterHistoryInstall.ChecksumValidate: Can't calculate checksum of dataset file '${workDatasetFile}'."
	restoredChecksum="${restoredChecksum:0:40}"
	expectedChecksum=$(head -c 40 "${workChecksumFile}")
	barfds "restoredChecksum: '${restoredChecksum}'"
	barfds "expectedChecksum: '${expectedChecksum}'"
	[ "${restoredChecksum}" != "${expectedChecksum}" ] &&
		barfe "maudVoterHistoryInstall.ChecksumValidate: Checksum of restored file doesn't match published value."
	barfds "maudVoterHistoryInstall.ChecksumValidate complete."
	
	# Move Voter History data to destination
	mv $verboseFlag "${workDatasetFile}" "${datasetHistoryFilespec}"
	errCode=$? ; [ $errCode -ne 0 ] &&
		barfe "maudVoterHistoryInstall.Deploy: Can't move imported dataset '${workDatasetFile}' to destination '${datasetHistoryFilespec}'."

	elapsedTime=$(timerElapsed ${historyInstallTimer})
	barfs "MAUDE Dataset ${datasetID} Voter History install complete. Elapsed: ${elapsedTime}"
}

#
# MAUDE Dataset Install (QVF and Voter History)
#
maudDatasetInstall() {
	local datasetID="$1"

	barfs "MAUDE Dataset ${datasetID} installing..."
	datasetInstallTimer=$(timerStart "DatasetInstall")
	
	[ "${datasetID}" == "" ] 			&& barfe "maudQvfInstall.Error: datasetID parameter was not passed"
	[ "${maudDataKitFolder}" == "" ]	&& barfe "maudQvfInstall.Error: maudDataKitFolder is not defined"
	[ "${maudStateDataFolder}" == "" ]	&& barfe "maudQvfInstall.Error: maudStateDataFolder is not defined"

	datasetWorkFolder="${maudWorkFolder}/qvf-${datasetIdentifier}"

	DatasetId_Validate "${datasetID}"

	# Check if dataset file exists
	# [ -f "${datasetFilespec}" ] && [ ! $optOverwrite ] &&
	#	barfe "Error. Dataset ${datasetID} file exists. Delete, or use overwrite option (-O)"

	# Warn and skip, if dataset has not been uploaded to server
	if [ "${datasetGoonKey}" == "${datasetGoonKeyNA}" ] || [ "${datasetGoonKey}" == "" ] ; then
		barfs "WARNING: MAUDE Dataset ${datasetID} has no QVF repository instance yet.  Skipping install."
		return 0
	fi

	# Get dataset salt for decrypting stuff
	barfds "MaudeDatasetInstall.FetchDatasetSalt..."
	datasetSaltFetch "${optPass}"

	# Create dataset import work folder, if needed, else clean up any old work files
	barfds "MaudeDatasetInstall.WorkFolderPreparation..."
	folderCreate "${datasetWorkFolder}" "Dataset ${datasetIdentifier} Import Work" $maudPublicFolderPerms

	# Clean up any prior work files
	maudeWorkDataCleanup "${datasetWorkFolder}" 

	# Install Dataset QVF
	[ $optDoQvf ] && maudQvfInstall "${datasetID}"

	# Install Dataset Voter History
	[ $optDoHistory ] && maudVoterHistoryInstall "${datasetID}"

	# Clean up work files
	[ ! $optDebug ] && maudeWorkDataCleanup "${datasetWorkFolder}"

	elapsedTime=$(timerElapsed ${datasetInstallTimer})
	barfs "MAUDE Dataset ${datasetID} install complete. Elapsed: ${elapsedTime}"
}

#
# MAUDE Data Install
#
maudeDataInstall() {

	[ $optDatasetCount -gt 0 ] && barfs "MAUDE Data kits install..."
	dataInstallTimer=$(timerStart "DataInstall")

	[ "${maudDataKitFolder}" == "" ] && barfe "maudeDataInstall.Error: maudDataKitFolder is not defined"

	# Install reference dataset if requested, or if the MAUDE common data kit project
	# has not been cloned yet.
	#
	if [ $(echo ",${optDatasetIds}," | grep -c "${datasetIdReference}") -gt 0 ] || \
			[ ! -d "${maudDataKitFolder}" ] ; then
		maudeReferenceDataInstall
	fi
	
	# Install requested Datasets
	#
	local datasetID
	while read datasetID ; do
		if [ $(echo ",${optDatasetList}," | grep -i -c "${datasetID}") -eq 0 ] ; then
			barfe "Invalid dataset id '${datasetID}'.  Valid options are; '${optDatasetList}'"
		fi
		if [ $(echo ",${specialDatasetList}," | grep -i -c "${datasetID}") -eq 0 ] ; then
			maudDatasetInstall "${datasetID}"
		fi
	done < <(printf "%s" "${optDatasetIds}," | tr ',' "\n")

	elapsedTime=$(timerElapsed ${dataInstallTimer})
	[ $optDatasetCount -gt 0 ] && barfs "MAUDE Data install of (${optDatasetCount}) kits complete. Elapsed: ${elapsedTime}"
}

#
# Command Line Options
#
getOptions() {

	optDatasetIds=
	optDatastore=
	optDatasetComponent=
	optSoftware=
	optPass=
	optPrompt=
	optLog=1
	optLogAppend=
	optLogFile=
	optVerbose=
	optDebug=
	optTrace=

	while getopts "?hplaL:vdtsD:AP:C:" OPTION
	do
		case $OPTION in
			h)	usage ; exit 1                                      ;;
			P)	optPass="${OPTARG}"									;;
			D)	optDatasetIds="${OPTARG}"							;;
			C)	optDatasetComponent="${OPTARG}"						;;
			s)	optSoftware=1                                       ;;
			A)	optSoftware=1 ; optDatasetIds="all"                 ;;
			p)	optPrompt=1                                         ;;
			l)	optLog=1                                            ;;
			a)	optLogAppend=1 ; optLog=1							;;
			L)  optLogFile="${OPTARG//\"/}" ; optLog=1				;;
			v)  optVerbose=1 ; 			                            ;;
			d)  optDebug=1 ;   optVerbose=1 ; optLog=1              ;;
			t)  optTrace=1; optDebug=1 ;   optVerbose=1 ; optLog=1  ;;
			?)  usage ; exit                                        ;;
		 esac
	done
	shift $(($OPTIND - 1))

	# Set Verbosity, Debug, and Test flags
	verboseFlag= ;	[ $optVerbose ] && verboseFlag=-v
	debugFlag= ;	[ $optDebug ] 	&& debugFlag=-d
	traceFlag= ;	[ $optVerbose ] && traceFlag=-t

	# Initialize Log if needed
	logFlag=
	logAppendFlag=
	[ $optLog ] && { logAppendFlag=-a ;
					 LogInitialize "${optLog}" "${optLogFile}" "${defaultLogFile}" "N" ;
					 logFlag="-L"'"'"${optLogFile}"'"' ; }

	# If neither the Software option nor a Dataset were selected, use software and common data as the default
	if [ ! $optSoftware ] && [ "${optDatasetIds}" == "" ] ; then
		optSoftware=1
		optDatasetIds="reference"
	fi

	# Validate Dataset ID(s)
	[ "${optDatasetIds}" == "all" ] && optDatasetIds="${specialDatasetList},${datasetList}"
	optDatasetCount=0
	if [ "${optDatasetIds}" != "" ] ; then
		local datasetID
		while read datasetID ; do
			if [ $(echo ",${optDatasetList}," | grep -i -c "${datasetID}") -eq 0 ] ; then
				barfe "Invalid dataset id '${datasetID}'.  Valid options are; '${optDatasetList}'"
			fi
			if [ $(echo ",${specialDatasetList}," | grep -i -c "${datasetID}") -eq 0 ] ; then
				DatasetId_Validate "${datasetID}"
			fi
		done < <(printf "%s" "${optDatasetIds}," | tr ',' "\n")
		optDatasetCount=$(( $(printf "%s" "${optDatasetIds}" | sed -e 's~[^,]~~g' | wc -c) + 1))
	fi
	
	# Validate Dataset File (all, qvf, or history)
	[ "${optDatasetComponent}" == "" ] && optDatasetComponent="all"
	[ $(echo ",${optDatasetComponentsList}," | grep -c ",${optDatasetComponent},") -eq 0 ] &&
		barfe "Invalid DatasetFile option (-F '${optDatasetComponent}'), valid values are; '${optDatasetComponentsList}'."
	
	optDoQvf=$(if [ "${optDatasetComponent}" == "all" ] || [ "${optDatasetComponent}" == "qvf" ] ; then printf "%s" "1" ; fi)
	optDoHistory=$(if [ "${optDatasetComponent}" == "all" ] || [ "${optDatasetComponent}" == "history" ] ; then printf "%s" "1" ; fi)

	# Make sure database password environment variable DBPASS is set
	#[ "${DBPASS}" == "" ] && barfe "Error.  Environment variable DBPASS needs to be set."

	# Determine correct gpg command to use to run GPG v2.  Cygwin is not consistent with other linuxes
	OS_FLAVOR=$("${kitProgFolder}/osinfo.sh" -s "OS_FLAVOR")
	gpgCommand="gpg"
	[ "${OS_FLAVOR}" == "Cygwin" ] && gpgCommand="gpg2"

	barfd "optDatasetIds : ${optDatasetIds}"
	barfd "optDoQvf      : ${optDoQvf}"
	barfd "optDoHistory  : ${optDoHistory}"
 	#[ $optDebug ] && barfd "Debug exit..."
}

usage() {
	cat <<EOFUsage
${prognm} [-lavdt] [-L <logfile>] -P <pass-phrase> [-A] [-s] [-D <dataset>[,<dataset>,...]]

   Install MAUDE software and/or data kits

        Folder                      Use
        ------------------          ---------------------------------------
        /opt/mi-audit-kit           MAUDE Software Distribution Kit
        /opt/mi-audit-data-kit      MAUDE Reference Data Distribution Kit
        /usr/sbin/mi-audit          MAUDE Application
        /var/lib/mi-audit-data      MAUDE Data
        \${HOME}/mi-audit/certs     MAUDE Local User Certs

    Options:
        -A            Install all (software, and any available datasets)
        -s            Install MAUDE software
        -D            Install MAUDE Dataset IDs (all|[[reference,][YYYY-MM-DD,]...])
        -C            Dataset components(s) to install (all[default], qvf, or history)
        -P            Pass phrase
        -l            Log (create)
        -a            Log (append)
        -L <logfile>  Write log data to <logfile> (default=./ubergen.log)
        -v            Verbose (displays detailed info)
        -d            Debug (displays more detailed info)
        -t            Trace (displays exhaustive info)

    Examples:
        ./maude-install.sh                        # Install software, and reference data (same as -s -D common)
        ./maude-install.sh -A                     # Install software, reference data, and any available datasets
        ./maude-install.sh -D 2021-01-01          # Install dataset 2021-01-01
        ./maude-install.sh -s -D "reference,2021-01-01"  # Install software, reference data, and 2021-0101 dataset

EOFUsage
}

############################################################################################
#
# INSTALL MAUDE SOFTWARE -- MAIN
#
############################################################################################

getOptions "$@"

[ $optSoftware ]				&& maudeSoftwareInstall
[ "${optDatasetIds}" != "" ]	&& maudeDataInstall
