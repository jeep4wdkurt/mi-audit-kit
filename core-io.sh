#
# core-io.sh
#
#	MAUDE Core I/O Routines
#
#	Description:
#
#       Variety of commonly used I/O routines.
#
#	Copyright:
#		Copyright (c) 2022, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.01.15  01.00    KurtSchulte    Original Version
#
####################################################################################################

#
# Prompt to Continue
#
SysadminPester() {
	local stepName="$1"
	local ans=
	if [ $optPrompt ] ; then 
		read -p "${stepName}.Ok2GO?: " ans
		if [[ "${ans}" != *[Yy]* ]] ; then exit 1 ; fi
	fi
}

SysadminPesterTrace() {
	local stepName="TRACE:$1"
	if [ $optDebug ] || [ $optTrace ] ; then SysadminPester "${stepName}" ; fi
}

#
# Output Routines
#
barf()   	{ echo "$1" ; barfl "$1" ; }
#catbarf()   { local fn="${1--}"; cat "${fn}" ;  [ $optLog ] && cat  < <(CatStamp "${fn}") >>"${optLogFile}" ; }		# Async output substitute process lags
#catbarfl()  { local fn="${1--}";                [ $optLog ] && cat  < <(CatStamp "${fn}") >>"${optLogFile}" ; }		# Async output substitute process lags
barfl()  	{ [ $optLog ] && 		cat < <(LogStamp "$1") >>"${optLogFile}" ; }
barfv()  	{ [ $optVerbose ] && 	barf  "$1" ; }
barfvs()  	{ [ $optVerbose ] && 	barfs  "$1" ; }
barfd()  	{ [ $optDebug ] &&		barfs "$1" ; }
barfdd() 	{ [ $optDebug ] &&		barf  "DEBUG:$1" ; }
barfds() 	{ [ $optDebug ] &&		barfs "DEBUG:$1" ; }
barfdt() 	{ [ $optDebug ] &&		barf  "TRACE:$1" ; }
barft()  	{ [ $optTrace ] &&		barf  "TRACE:$1" ; }
barfts()  	{ [ $optTrace ] &&		barfs "TRACE:$1" ; }
barfe()  	{ barf "$1" ; exit 1 ; }
barfee() 	{ barfe "${prognm}.${progLabel}.Error: $1" ; }
barfs()		{ local currTS=$(date +%Y.%m.%d-%H.%M.%S); barf "${currTS}: $1"; }

catbarf() {
	local fn="${1--}";
	local buffer=$(cat "${fn}")
	
	if [ "${buffer}" != "" ] ; then
		echo "${buffer}"
		[ $optLog ] && echo "${buffer}" | CatStamp >>"${optLogFile}"
	fi
}

catbarfv() {
	local fn="${1--}";
	local buffer=$(cat "${fn}")

	if [ "${buffer}" != "" ] ; then
		[ $optVerbose ] && echo "${buffer}"
		[ $optLog ] && echo "${buffer}" | CatStamp >>"${optLogFile}"
	fi
}

catbarfl() {
	local fn="${1--}";
	local buffer=$(cat "${fn}")
	
	if [ "${buffer}" != "" ] ; then
		[ $optLog ] && echo "${buffer}" | CatStamp >>"${optLogFile}"
	fi
}

#
# Debug routines
#
dumpVariable() {
	local varName="$1"
	local varValue="${!varName}"
	printf '%-25s : %s\n' "${varName}" "${varValue}"
}

dumpVariable2() {
	local varName="$1"
	local varValue="$2"
	printf '%-25s : %s\n' "${varName}" "${varValue}"
}

traceVariable() {
	local varName="$1"
	local varValue="${!varName}"
	if [ $optTrace ] ; then dumpVariable2  "${varName}" "${varValue}" ; fi
}

traceVariable2() {
	local varName="$1"
	local varValue="$2"
	if [ $optTrace ] ; then dumpVariable2  "${varName}" "${varValue}" ; fi
}

LogInitialize() {
	local logOption=$1
	local logFile="$2"
	local logDefault="$3"
	local logAppend="$4"
	progLabel="LogInitialize"

	[ "${logDefault}" == "" ] && { logDefault=$(pwd)/maude-debug.log ; logDefault="${logDefault//\/\//\/}" ; }
	
	# Determine and validate log file location, then initialize
	if [ $logOption ] ; then
	
		[ "${maudDataFolder}" == "" ]			&& barfe "LogInitialize.Error: maudDataFolder is not defined"
		[ "${maudTransitFolder}" == "" ]		&& barfe "LogInitialize.Error: maudTransitFolder is not defined"
		[ "${maudLogFolder}" == "" ]			&& barfe "LogInitialize.Error: maudLogFolder is not defined"
		[ "${maudFolderPerms}" == "" ]			&& barfe "LogInitialize.Error: $maudFolderPerms is not defined"
		[ "${maudPublicFolderPerms}" == "" ]	&& barfe "LogInitialize.Error: $maudPublicFolderPerms is not defined"

		# Create log folder, if needed
		errCode=0
		[ ! -d "${maudDataFolder}" ] && { mkdir $verboseFlag --mode=$maudPublicFolderPerms "${maudDataFolder}" ; errCode=$? ; }
		[ $errCode -eq 0 ] && [ ! -d "${maudTransitFolder}" ] &&
			{ mkdir $verboseFlag --mode=$maudPublicFolderPerms "${maudTransitFolder}" ; errCode=$? ; }
		[ $errCode -eq 0 ] && [ ! -d "${maudLogFolder}" ] &&
			{ mkdir $verboseFlag --mode=$maudPublicFolderPerms "${maudLogFolder}" ; errCode=$? ; }
		[ $errCode -ne 0 ] && { echo "LogInitialize.Error: Problem creating MAUDE log folder"; exit 1; }
	
		# Initialize new log file, if needed
		[ "${logFile}" == "" ] && logFile="${logDefault}"							# Use default log file spec, if none provided
		[ -f "${logFile}" ] && [[ "${logAppend}" != *[Yy]* ]] && rm "${logFile}"	# Remove old log
		touch "${logFile}"															# Initialize log file
		[ $? -ne 0 ] && barfee "Can't access log file (logFile=${logFile})"
		optLogFile="${logFile}" ; export optLogFile
	fi
	barft "LogInitialize:logFile='${logFile}'"

}

LogCapture() {
	tee -a "${optLogFile}"
}

LogStamp() {
	local text="$1"
	local currTS=$(date +%Y.%m.%d-%H.%M.%S)
	
	local logText="${text}"
	[ $(echo "${text}" | grep -c '^[0-9]\{4\}[.][0-9]\{2\}[.][0-9]\{2\}') -eq 0 ] &&
		logText="${currTS}: ${text}"

	printf "%s\n" "${logText}"
}

CatStamp() {
	local fileSpec="$1"
	local currTS=$(date +%Y.%m.%d-%H.%M.%S)
	[ "${fileSpec}" == "" ] && fileSpec=-
	cat "${fileSpec}" | sed -e "s~^~${currTS}: ~"
}

