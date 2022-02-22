#
# maude-ubergen-config.sh
#	
#	Description:
#
#		Utility to install UberGen and build a LAMP system suitable for MAUDE
#
#		This tool edits a UberGen build-variable.sh template, replacing the
#		following fields;
#
#			Replacement Field			Replace With
#			-------------------------	----------------------------
#			{{hostname}}				System host name
#			{{domainname}}				System domain name
#			{{root_password}}}			Root password
#			{{org_country}}				Organization country
#			{{org_state}}				Organization state
#			{{org_name}}				Organization name
#			{{org_abbr}}				Organization abbr
#			{{org_locality}}			Organization city
#			{{org_organization}}		Organization sub-organization
#			{{org_unit}}				Organization unit
#			{{org_email}}				Organization email
#			{{client_hostname}}			Client workstation hostname
#			{{client_ipaddr}}			Client workstation IPv4 address
#			{{client_email}}			Client workstation system admin email
#			{{ftps_command_port}}		Secure FTP command port
#			{{ftps_data_port}}			Secure FTP data port
#			{{ssh_port}}				Secure Shell (SSH) port
#			{{mariadb_port}}			MariaDB Database port
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

#
# Files
#
defaultLogFile="${maudLogFolder}/${prognm//.sh/}-$(date +%Y.%m.%d-%H.%M.%S).log"

# Constants
nettoolsPackage="net-tools"
ubergenMinimumVersion="01.04"
defaultFtpsCommandPort=3321
defaultFtpsDataPort=3320
defaultSshPort=3322
defaultMariadbPort=3369

# Working Data
pingCheckCt=0

#
# Files
#
[ "${maudLocalUbergenFolder}" == "" ] 			&& barfe  "${prognm}.Error: maudLocalUbergenFolder is not defined"
[ "${maudUbergenFolder}" == "" ]				&& barfe  "${prognm}.Error: maudUbergenFolder is not defined"
[ "${maudUbergenBuildValuesDefault}" == "" ] 	&& barfe  "${prognm}.Error: maudUbergenBuildValuesDefault is not defined"
[ "${maudUbergenBuildValuesLocal}" == "" ] 		&& barfe  "${prognm}.Error: maudUbergenBuildValuesLocal is not defined"
[ "${maudUbergenBuildTemplate}" == "" ] 		&& barfe  "${prognm}.Error: maudUbergenBuildTemplate is not defined"

#
# Replacement Fields
#

# Fields List
replacementFields="hostname,domainname,root_password,ftps_command_port,ftps_data_port,ssh_port,mariadb_port"
replacementFields="${replacementFields},org_country,org_state,org_name,org_abbr,org_locality"
replacementFields="${replacementFields},org_organization,org_unit,org_email,client_hostname,client_ipaddr,client_email"

# Field Validation Patterns
field_hostname_pattern='^[a-zA-Z][-a-zA-Z0-9]\{1,62\}$'
field_domainname_pattern='^[a-z][-a-zA-Z0-9.]*[.][a-z]\{2,6\}$'
field_ipaddr_pattern='^\(\([0-9]\|[1-9][0-9]\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)\.\)\{3\}\([0-9]\|[1-9][0-9]\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)$'
field_email_pattern='^[a-zA-Z][a-zA-Z0-9_-]\+@[a-zA-Z][a-zA-Z0-9.]*[.][a-z]\{2,6\}$'
field_port_pattern='^[1-9][0-9][0-9][0-9][0-9]\?$'
field_password_pattern='^[-a-zA-Z0-9_.,;:=#%^()]\{6,128\}$'

# Field Requirements Descriptions
field_hostname_valid_desc='Alphanumeric characters, 1-62 in length'
field_domainname_valid_desc='Alphanumeric and period characters'
field_ipaddr_valid_desc='An IPv4 address (<0-255>.<0-255>.<0-255>.<0-255>)'
field_email_valid_desc='A valid email address (<name>@<domain>)'
field_port_valid_desc='A port address (1000-99999)'
field_password_valid_desc="From 6 to 128 of the following cahracters; '-a-zA-Z0-9_.,;:=#%^()'"

# Field Definitions
# 	replacement token,data type,blank allowed,reentry required,validationPattern,Desc
field_hostname="{{hostname}},string,N,N,hostname,System host name"
field_domainname="{{domainname}},string,N,N,domainname,System domain name"
field_root_password="{{root_password}},string,N,Y,password,Root password"
field_ftps_command_port="{{ftps_command_port}},string,N,N,port,Secure FTP (FTPS) Command port"
field_ftps_data_port="{{ftps_data_port}},string,N,N,port,Secure FTP (FTPS) Data port"
field_ssh_port="{{ssh_port}},string,N,N,port,Secure FTP (FTPS) Data port"
field_mariadb_port="{{mariadb_port}},string,N,N,port,Secure Shell (SSH) port"
field_org_country="{{org_country}},string,Y,N,,Organization country"
field_org_state="{{org_state}},string,Y,N,,Organization state"
field_org_name="{{org_name}},string,Y,N,,Organization name"
field_org_abbr="{{org_abbr}},string,Y,N,,Organization abbr"
field_org_locality="{{org_locality}},string,Y,N,,Organization city"
field_org_organization="{{org_organization}},string,Y,N,,Organization sub-organization"
field_org_unit="{{org_unit}},string,Y,N,,Organization unit"
field_org_email="{{org_email}},string,Y,N,,Organization email"
field_client_hostname="{{client_hostname}},string,Y,N,hostname,Client workstation hostname"
field_client_ipaddr="{{client_ip_addr}},string,Y,N,ipaddr,Client workstation IPv4 address"
field_client_email="{{client_email}},string,Y,N,email,Client workstation system admin email"

#
#   Read an Ini Variable value
# 
IniVarRead() {
	local iniFile="$1"
	local iniField="$2"
	local fieldDefault="$3"
	
	[ "${iniFile}" == "" ]		&& barfe "IniVarRead.Error: iniFile is not defined"
	[ "${iniField}" == "" ]		&& barfe "IniVarRead.Error: iniField is not defined"
	[ $(echo ",${replacementFields}," | grep -c ",${iniField}," ) -eq 0 ] &&
								barfe "IniVarRead.Error: iniField '${iniField}' is not a valid field"	
	
	local varValue=$(cat "${iniFile}" |
						tr -d '\r' |
						grep "^[[:blank:]]*${iniField}[[:blank:]]*=" |
						sed -e "s~^[ \t]*${iniField}[ \t]*=[ \t]*\x22\([^\x22]*\)\x22.*~\1~")
	errCode=$?
	[ $errCode -ne 0 ] && barfe "IniVarRead.Error: Problem getting field '${iniField}' from file '${iniFile}'"	
	
	[ $(echo "${varValue}" | wc -l) -gt 1 ] &&
		barfe "IniVarRead.Error: Problem getting field '${iniField}' from file '${iniFile}'.. multiple values??"	
	
	[ "${varValue}" == "" ] && [ "${fieldDefault}" != "" ] && varValue="${fieldDefault}"
	
	echo "${varValue}"
}

IniVarValidate() {
	local fieldName="$1"
	local fieldValue="$2"
	
	local fieldVariable=
	local fieldInfoVariable=
	local fieldInfo=
	local outLine=
	
	iniValidateError=
	iniValidateWarning=
	
	#local logFile="./test.log"

	fieldInfoVariable="field_${fieldName}"
	fieldInfo="${!fieldInfoVariable}"
	
	# {{hostname}},string,N,N,field_hostname_pattern,System host name
	fieldReplacementTag=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\).*~\1~')
	fieldDatatype=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\2~')
	fieldBlankAllowed=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\3~')
	fieldReentryRequired=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\4~')
	fieldValidationPatternId=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\5~')
	fieldDescription=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\6~')

	# barfds "fieldReplacementTag            : ${fieldReplacementTag}"				>>"${logFile}"
	# barfds "fieldDatatype                  : ${fieldDatatype}"					>>"${logFile}"
	# barfds "fieldBlankAllowed              : ${fieldBlankAllowed}"				>>"${logFile}"
	# barfds "fieldValidationPatternVariable : ${fieldValidationPatternVariable}"	>>"${logFile}"
	# barfds "fieldReentryRequired           : ${fieldReentryRequired}"				>>"${logFile}"
	# barfds "fieldDescription               : ${fieldDescription}"					>>"${logFile}"
		
	# Handle blanks not allowed
	[ "${fieldBlankAllowed}" != "Y" ] && [ "${fieldValue}" == "" ] && { iniValidateError="${fieldName} may not be blank"; return; }

	if [ "${fieldValidationPatternId}" != "" ] && [ "${fieldValue}" != "" ] ; then
		fieldValidationPatternVariable="field_${fieldValidationPatternId}_pattern"
		local fieldValidationPattern="${!fieldValidationPatternVariable}"
		[ "${fieldValidationPattern}" == "" ] &&
			{ iniValidateError="${fieldName} configuration error... bad pattern configured." ; return; }
		if [ $(echo "${fieldValue}" | grep -c "${fieldValidationPattern}") -eq 0 ] ; then
			requiredFormatVar="field_${fieldValidationPatternId}_valid_desc"
			requiredFormatDesc="${!requiredFormatVar}"
			iniValidateError="${fieldName} is not valid format, vaule reqires; ${requiredFormatDesc}"
		fi
	fi
	
	# Handle re-entry verification
	if [ "${fieldReentryRequired}" == "Y" ] ; then
		if [ "${fieldValue}" == "" ] ; then
			iniValidateError="${fieldName} may not be blank"
		else
			read -p "Confirm ${fieldName}: " valueConfirm </dev/tty
			[ "${fieldValue}" != "${valueConfirm}" ] && iniValidateError="values do not match"
		fi
	fi
	
	# Ping test for client_ipaddr
	if [ "${fieldName}" == "client_ipaddr" ] ; then
		[ $pingCheckCt -eq 0 ] && echo "Give me a ping, Vasily. One ping only, please..... <ping>..."
		[ $pingCheckCt -ne 0 ] && echo "Checking target via ping..."
		pingCheckCt=$(( $pingCheckCt + 1 ))
		ping ${fieldValue} -c 1 >/dev/nul
		errCode=$? ; [ $errCode -ne 0 ] && iniValidateWarning="Can't ping address ${fieldValue}"
		echo "Target ${fieldValue} pinged successfully."
	fi

}

IniVarsDump() {
	local varsTitle="$1"

	local outFormat="%-20s : %s"
	local fieldName
	local fieldVariable
	local fieldValue

	barf ""
	barf "------------------------------------------------------"
	barf "${varsTitle} UberGen LAMPPP Build Settings"
	barf "------------------------------------------------------"
	while read fieldName ; do
		fieldVariable="inival_${fieldName}"
		fieldValue="${!fieldVariable}"
		outLine=$(printf "${outFormat}" "${fieldName}" "${fieldValue}")
		barf "${outLine}"
	done < <(printf "%s" "${replacementFields}," | tr ',' '\n' )
	barf "------------------------------------------------------"
	barf ""
}

#
#	MAUDE UberGen Init File Load
#
maudeUbergenIniLoad() {

	barfds "maudeUbergenIniLoad.Entry()"

	errCode=0
	
	# Determine initialization file to use
	[ ! -f "${maudUbergenBuildValuesDefault}" ] 	&& barfe "maudeUbergenIniLoad.Error: maudUbergenBuildValuesDefault file '${maudUbergenBuildValuesDefault}' does not exist."
	
	iniFileIsDefault=0
	if [ "${optIniFile}" == "" ] ; then
		if [ -f "${maudUbergenBuildValuesLocal}" ] ; then
			optIniFile="${maudUbergenBuildValuesLocal}"
			iniFileIsDefault=0
		else 
			optIniFile="${maudUbergenBuildValuesDefault}"
			iniFileIsDefault=1
		fi
	fi

	# Ini format...
	# hostname			= "maude-d11-01"								# System host name
	inival_hostname=$( IniVarRead "${optIniFile}" "hostname"  )			
	inival_domainname=$( IniVarRead "${optIniFile}" "domainname"  )		
	inival_root_password=$( IniVarRead "${optIniFile}" "root_password"  )
	inival_org_country=$( IniVarRead "${optIniFile}" "org_country"  )
	inival_org_state=$( IniVarRead "${optIniFile}" "org_state"  )
	inival_org_name=$( IniVarRead "${optIniFile}" "org_name"  )
	inival_org_abbr=$( IniVarRead "${optIniFile}" "org_abbr"  )
	inival_org_locality=$( IniVarRead "${optIniFile}" "org_locality"  )
	inival_org_organization=$( IniVarRead "${optIniFile}" "org_organization"  )
	inival_org_unit=$( IniVarRead "${optIniFile}" "org_unit"  )
	inival_org_email=$( IniVarRead "${optIniFile}" "org_email"  )
	inival_client_hostname=$( IniVarRead "${optIniFile}" "client_hostname"  )
	inival_client_ipaddr=$( IniVarRead "${optIniFile}" "client_ipaddr"  )
	inival_client_email=$( IniVarRead "${optIniFile}" "client_email"  )
	inival_ftps_command_port=$( IniVarRead "${optIniFile}" "ftps_command_port" $defaultFtpsCommandPort )
	inival_ftps_data_port=$( IniVarRead "${optIniFile}" "ftps_data_port" $defaultFtpsDataPort )
	inival_ssh_port=$( IniVarRead "${optIniFile}" "ssh_port" $defaultSshPort )
	inival_mariadb_port=$( IniVarRead "${optIniFile}" "mariadb_port" $defaultMariadbPort )

	[ "${inival_hostname}" == "" ] 		&& inival_hostname="${HOSTNAME}"
	[ "${inival_domainname}" == "" ]	&& inival_domainname=$(hostname --domain) 

	local badValue=0
	while read fieldName ; do
		fieldVariable="inival_${fieldName}"
		fieldValue="${!fieldVariable}"
		[[ "${fieldValue}" == *Error:* ]] 			&& { barf "${fieldValue}" ; badValue=1 ; }
	done < <(printf "%s" "${replacementFields}," | tr ',' '\n' )
	[ $badValue -ne 0 ] && barfe "Exiting on configuration error."
	
	barfds "maudeUbergenIniLoad.Exit"
}

#
#	MAUDE UberGen Config File Update
#
maudeUbergenConfigUpdate() {

	barfds "maudeUbergenConfigUpdate.Entry()"

	errCode=0
	
	folderCreate "${maudLocalFolder}"        "MAUDE Local Data Folder"                       $maudFolderPerms
	folderCreate "${maudLocalUbergenFolder}" "MAUDE Local UberGen Configuration Data Folder" $maudFolderPerms

	cat >"${maudUbergenBuildValuesLocal}" <<EOD
#
# build-variables-maude-local.ini
#
#   UberGen System Confabulation Suite
#   Build Variables Definition Module
#
#   Description:
#
#      Values for UberGen template replacement for this local installation
#
#   Copyright:
#       Copyright (c) 2022, F. Kurt Schulte - All rights reserved.  No use without written authorization.
#
#   History:
#       Date        Version     Author          Desc
#       2022.02.07  01.00       FKSchulte       Original Version

EOD

	outFormat='%-20s = %-55s # %s'

	local badValue=0
	
	local fieldName
	local fieldValue
	local outValue
	while read fieldName ; do
		fieldVariable="inival_${fieldName}"
		fieldValue="${!fieldVariable}"
		
		fieldInfoVariable="field_${fieldName}"
		fieldInfo="${!fieldInfoVariable}"
	
		# fieldReplacementTag=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),.*~\1~')
		# fieldDatatype=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\2~')
		# fieldBlankAllowed=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\3~')
		# fieldValidationPatternVariable=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\4~')
		# fieldReentryRequired=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\5~')
		fieldDescription=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\6~')
		
		outValue='"'"${fieldValue}"'"'
		outLine=$(printf "${outFormat}" "${fieldName}" "${outValue}" "${fieldDescription}")
		echo "${outLine}" >>"${maudUbergenBuildValuesLocal}"
	done < <(printf "%s" "${replacementFields}," | tr ',' '\n' )

	[ $badValue -ne 0 ] && barfe "Exiting on configuration write error."
	
	barfds "maudeUbergenConfigUpdate.Exit"
}

#
#	MAUDE UberGen Config Prompts
#
maudeUbergenConfigPrompts() {

	barfds "maudeUbergenConfigPrompts.Entry()"

	promptSuccess=0

	local fieldName
	local fieldVariable
	local fieldValue
	local fieldNewValue
	local ok2goAns=
	
	iniFileTitle="Default"
	[ $iniFileIsDefault -eq 0 ] && iniFileTitle="Current"
	
	IniVarsDump "${iniFileTitle}"

	barf "==================================================================="
	barf "MAUDE UberGen Configuration"
	barf "-------------------------------------------------------------------"
	barf " o The following fields need to be accurately poplated for"
	barf "     correct operation of UberGen"
	barf " o Default values are displayed in square brackets"
	barf " o Hit enter to accept the default, or supply a new value"
	barf " o Hyphen '-' entered as field value will blank field"
	barf " o 'q' or 'exit' entered as field value will abort this process"
	barf "-------------------------------------------------------------------"
	
	while [ "${ok2goAns}" == "" ] ; do
	
		barf ""
		barf "Enter UberGen Configuration Parameters..."

		while read fieldName ; do
			fieldVariable="inival_${fieldName}"
			fieldValue="${!fieldVariable}"
			fieldPrompt="${fieldName} [${fieldValue}]: "

			# Prompt user for field value and validate
			local valueIsValid=0
			local validateResult=
			while [ $valueIsValid -eq 0 ] ; do
				read -p "${fieldPrompt}" fieldNewValue </dev/tty
				if [[ "${fieldNewValue}" == [Qq] ]] || [ "${fieldNewValue}" == "exit" ] ; then barfe "User abort." ; fi
				[ "${fieldNewValue}" == "" ] && fieldNewValue="${fieldValue}"
				[ "${fieldNewValue}" == "-" ] && fieldNewValue=""				
				IniVarValidate "${fieldName}" "${fieldNewValue}"
				if [ "${iniValidateError}" != "" ] ; then
					echo "${iniValidateError}"
				else
					if [ "${iniValidateWarning}" == "" ] ; then
						valueIsValid=1
					else
						echo "Warning: ${iniValidateWarning}"
						read -p "Are you sure? (Y/N=[default]): " notSure  </dev/tty
						[[ "${notSure}" == *[Yy]* ]] && valueIsValid=1
					fi
				fi
			done
			
			# Update field value
			if [ "${fieldNewValue}" != "" ] ; then
				[ "${fieldName}" == "hostname" ]			&& inival_hostname="${fieldNewValue}"
				[ "${fieldName}" == "domainname" ]			&& inival_domainname="${fieldNewValue}"
				[ "${fieldName}" == "root_password" ]		&& inival_root_password="${fieldNewValue}"
				[ "${fieldName}" == "org_country" ]			&& inival_org_country="${fieldNewValue}"
				[ "${fieldName}" == "org_state" ]			&& inival_org_state="${fieldNewValue}"
				[ "${fieldName}" == "org_name" ]			&& inival_org_name="${fieldNewValue}"
				[ "${fieldName}" == "org_abbr" ]			&& inival_org_abbr="${fieldNewValue}"
				[ "${fieldName}" == "org_locality" ]		&& inival_org_locality="${fieldNewValue}"
				[ "${fieldName}" == "org_organization" ]	&& inival_org_organization="${fieldNewValue}"
				[ "${fieldName}" == "org_unit" ]			&& inival_org_unit="${fieldNewValue}"
				[ "${fieldName}" == "org_email" ]			&& inival_org_email="${fieldNewValue}"
				[ "${fieldName}" == "client_hostname" ]		&& inival_client_hostname="${fieldNewValue}"
				[ "${fieldName}" == "client_ipaddr" ]		&& inival_client_ipaddr="${fieldNewValue}"
				[ "${fieldName}" == "client_email" ]		&& inival_client_email="${fieldNewValue}"
			fi
		done < <(printf "%s" "${replacementFields}," | tr ',' '\n' )

		IniVarsDump "Current"

		echo " "
		ok2goAns=
		while [ "${ok2goAns}" == "" ] ; do
			read -p "OK2GO? (Y=Yes,N=No[default],Q=Quit):" ok2goAns </dev/tty
			[ "${ok2goAns}" == "" ] && ok2goAns="N"
			[[ "${ok2goAns}" != *[YyNnQq]* ]] && ok2goAns=
		done
		
		[[ "${ok2goAns}" == *[Nn]* ]] && ok2goAns=
	done

	echo "DEBUG: ok2goAns = '${ok2goAns}'"

	promptSuccess=0
	[[ "${ok2goAns}" != *[NnQq]* ]] && promptSuccess=1
	
	barfds "maudeUbergenConfigPrompts.Exit(success=${promptSuccess})"
}

maudeUbergenConfigEdits() {

	tmpSed=~/tmp.sed
	[ -e "${tmpSed}" ] && rm "${tmpSed}"
	
	while read fieldName ; do
		fieldVariable="inival_${fieldName}"
		fieldValue="${!fieldVariable}"
		
		fieldInfoVariable="field_${fieldName}"
		fieldInfo="${!fieldInfoVariable}"

		fieldReplacementTag=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\).*~\1~')
		# fieldDatatype=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\2~')
		# fieldBlankAllowed=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\3~')
		# fieldValidationPatternVariable=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\4~')
		# fieldReentryRequired=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\5~')
		# fieldDescription=$(echo "${fieldInfo}" | sed -e 's~^\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\),\([^,]*\)~\6~')
		
		sedEditString="s~${fieldReplacementTag}~${fieldValue//&/\\&}~g"
		echo "${sedEditString}" >>"${tmpSed}"
	done < <(printf "%s" "${replacementFields}," | tr ',' '\n' )
	
	cat "${tmpSed}"

}

#
#	Apply MAUDE UberGen Configs settings to UberGen
#
maudeUbergenConfigApply() {

	barfds "maudeUbergenConfigApply.Entry()"

	# Make sure UbereGen is there
	[ ! -d "${ubergenFolder}" ] && barfe "maudeUbergenConfigApply.Error: ubergenFolder '${ubergenFolder}' does not exist.  UberGen is not installed."

	# Copy template to UberGen app folder
	[ ! -f "${maudUbergenBuildTemplate}" ] && barfe "maudeUbergenConfigApply.Error: maudUbergenBuildTemplate file '${maudUbergenBuildTemplate}' does not exist."
	cat "${maudUbergenBuildTemplate}"			|
		sed -f <(maudeUbergenConfigEdits)		\
		>"${ubergenBuildVariables}"
	errCode=$? ; [ $errCode -ne 0 ] && barfe "maudeUbergenConfigApply.Error: Error applying MAUDE settings to UberGen build variables '${ubergenBuildVariables}'"

	# Make sure all form fields got replaced.
	[ $(cat "${ubergenBuildVariables}" | grep -c '\({{\|}}\)') -gt 0 ] && {
		barf "maudeUbergenConfigApply.Error: UberGen build variable(s) didn't get replaced properly..."
		cat "${ubergenBuildVariables}" | grep '\({{\|}}\)'
		exit 1
	}

	barfds "maudeUbergenConfigApply.Exit"
}

#
#   MAUDE UberGen Run
#
maudeUbergenRun() {

	barfds "maudeUbergenRun.Entry()"

	[ "${maudLogFolder}" == "" ] && barfe "maudeUbergenRun.Error: maudLogFolder is not defined."

	# Make sure UbereGen is there
	[ ! -d "${ubergenFolder}" ] && barfe "maudeUbergenRun.Error: ubergenFolder '${ubergenFolder}' does not exist.  UberGen is not installed."

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

	# Create LAMPPP invironment
	cd "${ubergenFolder}"
	./ubergen.sh $logSeparateFlag $verboseFlag $debugFlag $traceFlag $logFlag					
	errCode=$? ; [ $errCode -ne 0 ] && barfe "maudeUbergenRun: Problem running UberGen.  Crap."

	# Configure standard database users
	[ $optLog ] && logAppendFlag=-a
	./wordpress-mariadb-config.sh $verboseFlag $debugFlag $traceFlag $logFlag $logAppendFlag
	errCode=$? ; [ $errCode -ne 0 ] && barfe "maudeUbergenRun: Problem adding UberGen users.  Crap."
	
	# Check log files for any errors
	problemCt=$(grep -i '\(error\|warning\|Line [0-9][0-9]\)' "${maudLogFolder}"/uber*.log |	
				grep -v 'localized-error-pages' |
				wc -l)
	errCode=$? ; [ $errCode -ne 0 ] && barfe "maudeUbergenRun: Problem determining if problems happened running UberGen.  Crap."
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

	barfds "maudeUbergenRun.Exit"
}

#
#   MAUDE UberGen Prerequisites
#
maudeUbergenPrerequisites() {

	barfds "maudeUbergenPrerequisites.Entry()"

	# Need net-tools for ping on Debian.  Cywgin and Ubuntu come with it installed
	if [ "${OS_FLAVOR}" == "Debian" ] ; then
		nettoolsInstalled=$(dpkg-query --list "*${nettoolsPackage}*" | grep -c "^[a-z]i[ \t]*${nettoolsPackage}[ \t].*")
		errCode=$? ; [ $errCode -ne 0  ] && barfe "maudeUbergenPrerequisites.Error: Problem checking for package '${nettoolsPackage}'" 
		if [ $nettoolsInstalled -eq 0 ] ; then
			barf "Installing ${nettoolsPackage}..."
			apt-get -y install ${nettoolsPackage}
			errCode=$? ; barfe "maudeUbergenPrerequisites.Error: Problem installing package '${nettoolsPackage}'" 
			barf "Installing ${nettoolsPackage} complete."
		fi
	fi

	barfds "maudeUbergenPrerequisites.Exit"
}

#
#	MAUDE UberGen Config
# 
maudeUbergenConfig() {

	[ "${ubergenMinimumVersion}" == "" ]	&& barfe "maudeUbergenConfig.Error: ubergenMinimumVersion is not defined"

	maudeUbergenPrerequisites						# Check prerequisites
	maudeUbergenIniLoad								# Load UberGen ini file
	maudeUbergenConfigPrompts						# Prompt for any value changes desired

	if [ $promptSuccess -ne 0 ] ; then 

		# Create/update user ini file with latest values
		maudeUbergenConfigUpdate					

		# Delete old version UberGen, if needed
		ubergenProjectUninstall "${ubergenMinimumVersion}"
		[ $ubergenUninstallStatus -ne 0 ] && exit 1

		# Get latest copy of UberGen project
		ubergenProjectPull							
		if [ "${ubergenKeycodeStatus}" == "" ] || [ $ubergenKeycodeStatus -ne 0 ] ||
		   [ "${ubergenPullStatus}" == "" ]    || [ $ubergenPullStatus -ne 0 ] ; then
			exit 1
		fi

		# Configure UberGen with MAUDE settings, and SEND IT!
		maudeUbergenConfigApply						
		if [ "${OS_FLAVOR}" == "Cygwin" ] ; then
			barf "${OS_FLAVOR} is not supported for UberGen install, exiting."
		else
			maudeUbergenRun							# Slam UberGen into gear
		fi
		
	fi
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
