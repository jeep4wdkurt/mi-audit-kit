#
# maude-ubergen-config.sh
#	
#	Description:
#
#		Utility to configure UberGen tool, and then run to build a LAMP system
#       suitable for MAUDE
#
#	Usage:
#       maude-ubergen-config.sh [-lavdt] [-L <logfile>] -P <pass-phrase>
#
#           Options:
#               -P            Pass phrase
#               -l            Log (create)
#               -a            Log (append)
#               -L <logfile>  Write log data to <logfile> (default=./ubergen.log)
#               -v            Verbose (displays detailed info)
#               -d            Debug (displays more detailed info)
#               -t            Trace (displays exhaustive info)
#
#	Copyright:
#		Copyright (c) 2022, F. Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#		Date		Version		Author			Desc
#		2022.02.07	01.00		FKSchulte		Original Version
#
prognm=maude-ubergen-config.sh

kitFolderAbs=$(echo "${0%/*}" | sed -e "s~^[.]~`pwd`~")
kitRootFolder="${kitFolderAbs%/*}"
maudRootFolder="${kitRootFolder}"
[ ! -d "${maudRootFolder}/bash" ] && maudRootFolder="${kitFolderAbs}"
cd "${kitFolderAbs}"

kitProgFolder="${kitFolderAbs}"				; export kitProgFolder

echo "DEBUG: kitProgFolder : ${kitProgFolder}"

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

# Overrides
[ "${maudRootFolder}" == "${kitFolderAbs}" ] && maudeProgFolder="${kitFolderAbs}"

# Folders
[ "${maudLocalUbergenFolder}" == "" ] 			&& barfe "${prognm}.Error: [maudLocalUbergenFolder] is not defined"
[ "${maudUbergenFolder}" == "" ]				&& barfe "${prognm}.Error: [maudUbergenFolder] is not defined"
[ "${ubergenFolder}" == "" ]					&& barfe "${prognm}.Error: [ubergenFolder] is not defined"

# Files
defaultLogFile="${maudLogFolder}/${prognm//.sh/}-$(date +%Y.%m.%d-%H.%M.%S).log"
ubergenConfigureScript="${ubergenFolder}/ug-configure.sh"

[ "${maudUbergenBuildValuesDefault}" == "" ] 	&& barfe "${prognm}.Error: [maudUbergenBuildValuesDefault] is not defined"
[ "${maudUbergenBuildValuesLocal}" == "" ] 		&& barfe "${prognm}.Error: [maudUbergenBuildValuesLocal] is not defined"
[ "${maudUbergenBuildTemplate}" == "" ] 		&& barfe "${prognm}.Error: [maudUbergenBuildTemplate] is not defined"

maudUbergenBuildValues="${maudUbergenBuildValuesDefault}"
[ -f "${maudUbergenBuildValuesLocal}" ]	&& maudUbergenBuildValues="${maudUbergenBuildValuesLocal}"

# Constants
ubergenMinimumVersion="01.05"


#
#   MAUDE UberGen Run
#
maudeUbergenRun() {
	progLabel="maudeUbergenRun" ; barfts "${progLabel}.Entry()"

	# Validations
	[ "${maudLogFolder}" == "" ] && barfee "Configuration variable [maudLogFolder] is not defined."

	# Make sure UbereGen is there
	[ ! -d "${ubergenFolder}" ] && barfee "Configuration variable [ubergenFolder] '${ubergenFolder}' does not exist.  UberGen is not installed."

	barf ""
	barf "===================================="
	barf "Everything is ready to run UberGen."
	barf ""
	barf "Now would be a good time to take a"
	barf "snapshot or backup before proceeding."
	barf ""
	
	# Make sure user is ready
	local ok2Go=""
	while [ "${ok2Go}" == "" ] ; do
		read -p "Ready to run UberGen? (Y/N[default]): " ok2Go </dev/tty
		[ "${ok2Go}" == "" ] && ok2Go="N"
		[[ "${ok2Go}" == *[Nn]* ]] && barfe "User requested exit."
		[[ "${ok2Go}" != *[Yy]* ]] && ok2Go=""
	done

	#
	# Run UberGen
	#

	# Create LAMPPP environment
	cd "${ubergenFolder}"
	./ubergen.sh -W $logSeparateFlag $verboseFlag $debugFlag $traceFlag $logFlag					
	errCode=$? ; [ $errCode -ne 0 ] && barfee "Problem running UberGen.  Crap."

	#TODO: The rest never gets executed due to reboots... need a finalization script for UG.

	# Check log files for any errors
	problemCt=$(grep -i '\(error\|warning\|Line [0-9][0-9]\)' "${maudLogFolder}"/uber*.log |	
				grep -v 'localized-error-pages' |
				wc -l)
	errCode=$? ; [ $errCode -ne 0 ] && barfee "Problem determining if problems happened running UberGen.  Crap."
	if [ $problemCt -gt 0 ] ; then
		barf "----------------------------------------------------------------"
		barf "Review these possible install issues found in logs..."
		grep -i '\(error\|warning\|Line [0-9][0-9]\)' "${maudLogFolder}"/uber*.log |	
			grep -v 'localized-error-pages'
	fi

	# Report status
	if [ $problemCt -gt 0 ] ; then
		barf "================================================================"
		barf "UberGen created your LAMPPP environment with possible issues.   "
		barf "REVIEW BEFORE PROCEEDING.  GOOD THING YOU TOOK A SNAPSHOT, EH!? "
		barf "================================================================"
	else
		barf "================================================================"
		barf "UberGen created your LAMPPP environment flawelessly.  Awesome-O!"
		barf "================================================================"
		
		barf ""
		barf "Now would be a good time to reboot, before proceeding."
		read -p "Reboot? [Y,N(default)]: " rebootAns </dev/tty
		[[ "${rebootAns}" == *[Yy]* ]] && /sbin/shutdown -r now
	fi

	barfts "maudeUbergenRun.Exit"
}

#
#	MAUDE UberGen Config
# 
maudeUbergenConfig() {
	progLabel="maudeUbergenConfig" ; barfts "${progLabel}.Entry()"

	# Validations
	[ "${ubergenMinimumVersion}" == "" ]	&& barfee "[ubergenMinimumVersion] is not defined"
 	[ "${maudUbergenBuildValues}" == "" ]	&& barfee "[maudUbergenBuildValues] is not defined"
	[ ! -f "${maudUbergenBuildValues}" ] &&
						barfee "MAUDE UberGen initialization parameters file '${maudUbergenBuildValues}' does not exist."

	# Delete old version UberGen, if needed
	ubergenProjectUninstall "${ubergenMinimumVersion}"
	[ $ubergenUninstallStatus -ne 0 ] && exit 1

	# Get latest copy of UberGen project
	ubergenProjectPull							
	if [ "${ubergenKeycodeStatus}" == "" ] || [ $ubergenKeycodeStatus -ne 0 ] ||
	   [ "${ubergenPullStatus}" == "" ]    || [ $ubergenPullStatus -ne 0 ] ; then
		exit 1
	fi

	# Configure UberGen
	"${ubergenConfigureScript}" $verboseFlag $debugFlag $traceFlag $logFlag -I "${maudUbergenBuildValues}"
	errCode=$? ; [ $errCode -ne 0 ] && barfee "UberGen configuration exited, unsuccessfully."

	# Run UberGen
	maudeUbergenRun

	bartfs "maudeUbergenConfig.Exit" 
}

#
# Command Line Options
#
getOptions() {

	optPass=
	optIniFile=
	optLog=1
	optLogAppend=
	optLogSeparate=1
	optLogFile=
	optVerbose=
	optDebug=
	optTrace=

	while getopts "?hplaL:vdtP:I:S" OPTION
	do
		case $OPTION in
			h)	usage ; exit 1                                      ;;
			P)	optPass="${OPTARG}"									;;
			I)	optIniFile="${OPTARG//\"/}"							;;
			l)	optLog=1                                            ;;
			S)	optLogSeparate=1 ; optLog=1                         ;;
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
	logSeparateFlag=
	[ $optLog ] && { logAppendFlag=-a ;
					 LogInitialize "${optLog}" "${optLogFile}" "${defaultLogFile}" "N" ;
					 logFlag="-L"'"'"${optLogFile}"'"' ; }
	[ $optLogSeparate ] && { logSeparateFlag=-S ; logAppendFlag= ; }

	# Pass phrase is required
	[ "${optPass}" == "" ] && barfe "Error: Pass phrase option (-P) is required."

	# Validate Ini File
	[ "${optIniFile}" != "" ] && [ ! -f "${optIniFile}" ] && barfe "Error: Ini File '${optIniFile}' does not exist."

	# Determine correct gpg command to use to run GPG v2.  Cygwin is not consistent with other linuxes
	OS_FLAVOR=$("${kitProgFolder}/osinfo.sh" -s "OS_FLAVOR")
	gpgCommand="gpg"
	[ "${OS_FLAVOR}" == "Cygwin" ] && gpgCommand="gpg2"
	
	# Check that password entered is accurate, by trying to get UberGen key code
	ubergenKeycodeDecode "${optPass}"
	if [ "${ubergenKeycodeStatus}" == "" ] || [ $ubergenKeycodeStatus -ne 0 ] ; then
		barfe "Error: Pass pharse is incorrect."
	fi

#	barfd "optDatasetIds : ${optDatasetIds}"
	barfds "maudLocalUbergenFolder        : ${maudLocalUbergenFolder}"
	barfds "maudUbergenFolder             : ${maudUbergenFolder}"
	barfds "maudUbergenBuildValuesDefault : ${maudUbergenBuildValuesDefault}"
	barfds "maudUbergenBuildValuesLocal   : ${maudUbergenBuildValuesLocal}"
	barfds "maudUbergenBuildTemplate      : ${maudUbergenBuildTemplate}"

}

usage() {
	cat <<EOFUsage
${prognm} [-lavdt] [-L <logfile>] -P <pass-phrase> 

  MAUDE UBERGEN CONFIGURE

    Options:
        -P            Pass phrase
        -l            Log (create)
        -a            Log (append)
        -L <logfile>  Write log data to <logfile> (default=./ubergen.log)
        -v            Verbose (displays detailed info)
        -d            Debug (displays more detailed info)
        -t            Trace (displays exhaustive info)

EOFUsage
}

############################################################################################
#
# MAUDE UBERGEN CONFIGURE -- MAIN
#
############################################################################################

getOptions "$@"

maudeUbergenConfig

