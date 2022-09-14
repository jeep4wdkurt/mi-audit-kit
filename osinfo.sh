#
# osinfo.sh
#	
#	Michigan Audit of Elections Suite
#   Get OS Information
#
#	Description:
#
#       Script to get OS Information, like type, version, revision, common name
#
#   Notes:
#
#	Copyright:
#		Copyright (c) 2021, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.02.01  01.00    KurtSchulte    Original Version
#
####################################################################################################
prognm=osinfo.sh

# Lowercase a string
lowercase() { echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"; }

getOsInfo() {

	OS_KERNEL=$(uname -r)
	OS_MACHINE=$(uname -m)

	osuname=$(uname)
	osuname=$(lowercase "${osuname}")
	
	OS_TYPE='[unknown ostype]'
	OS_FLAVOR='[unknown flavor os]'
	OS_DISTROBASE='[unknown distro]'
	OS_NAME='[unknown osname]'
	OS_VERSION='[unknown version]'
	OS_RELEASE='[unknown release]'
	OS_REVISION='[unknown revision]'
	OS_CODENAME=""
	OS_PRETTYNAME="${OSNAME} ${OSREVISION}"
	OS_FLAVVERFLAV="${OS_FLAVOR}${OS_VERSION}"

	if [[ "${osuname}" == "cygwin"* ]]; then
		OS_TYPE='Unix'
		OS_FLAVOR='Cygwin'
		OS_DISTROBASE='Cygwin'
		OS_NAME='Cygwin'
		OS_VERSION=$(uname | sed -e 's~.*[^0-9.]\([0-9]\+\)\..*~\1~')
		OS_RELEASE=$(uname | sed -e 's~.*[^0-9.]\([0-9.]\+\).*~\1~')
		OS_REVISION=$(uname | sed -e 's~.*[^0-9.]\([0-9.]\+\).*~\1~')
		OS_CODENAME=""
		OS_PRETTYNAME="$(uname)"
		OS_FLAVVERFLAV="${OS_FLAVOR}${OS_VERSION}"
	elif [[ "${osuname}" == "linux" ]] ; then
		OS_TYPE='Linux'
		if [ -f /etc/debian_version ] ; then
			OS_NAME=$(cat /etc/os-release | grep '^NAME=' | sed -e 's~.*"\(.*\)".*~\1~')
			if [ "${OS_NAME}" == "Ubuntu" ] ; then
				OS_FLAVOR='Ubuntu'
				OS_DISTROBASE='Debian'
				#OS_PRETTYNAME=$(cat /etc/os-release | grep '^PRETTY_NAME' | awk -F=  '{ print $2 }')
				OS_VERSION=$(cat /etc/os-release | grep '^VERSION_ID=' | sed -e 's~.*"\([0-9]\+\)[.].*~\1~')
				OS_RELEASE=$(cat /etc/os-release | grep '^VERSION_ID=' | sed -e 's~.*"\([0-9.]\+\)".*~\1~')
				OS_REVISION=$(cat /etc/os-release | grep '^VERSION_ID=' | sed -e 's~.*"\([0-9.]\+\)".*~\1~')
				debian_codename=$(cat /etc/debian_version)
				OS_CODENAME=$(cat /etc/os-release | grep '^VERSION_CODENAME=' | sed -e 's~.*=[ \t]*\(.*\)[ \t]*$~\1~')
				OS_PRETTYNAME="${OS_NAME} ${OS_REVISION} (${OS_CODENAME}-${debian_codename})"
				OS_FLAVVERFLAV="${OS_FLAVOR}${OS_VERSION}"
			else
				OS_FLAVOR='Debian'
				OS_DISTROBASE='Debian'
				#OS_PRETTYNAME=$(cat /etc/os-release | grep '^PRETTY_NAME' | awk -F=  '{ print $2 }')
				OS_VERSION=$(cat /etc/os-release | grep '^VERSION_ID=' | sed -e 's~.*"\(.*\)".*~\1~')
				OS_RELEASE=$(cat /etc/debian_version)
				OS_REVISION=$(cat /etc/debian_version)
				OS_CODENAME=$(cat /etc/os-release | grep '^VERSION_CODENAME=' | sed -e 's~.*=[ \t]*\(.*\)[ \t]*$~\1~')
				OS_PRETTYNAME="${OS_NAME} ${OS_REVISION} (${OS_CODENAME})"
				OS_FLAVVERFLAV="${OS_FLAVOR}${OS_VERSION}"
			fi
		elif [ -f /etc/centos-release ] ; then
			OS_FLAVOR='CentOS'
			OS_DISTROBASE='RedHat'
			OS_NAME=$(cat /etc/os-release | grep '^NAME=' | sed -e 's~.*"\(.*\)".*~\1~')
			OS_VERSION=$(cat /etc/os-release | grep '^VERSION_ID=' | sed -e 's~.*"\(.*\)".*~\1~')
			OS_RELEASE=$(cat /etc/centos-release)
			OS_REVISION=$(echo "${OS_RELEASE}" | sed -e 's~.*[^0-9.]\([0-9.]\+\).*~\1~')
			OS_CODENAME=""
			OS_PRETTYNAME="${OS_NAME} ${OS_REVISION}"
			OS_FLAVVERFLAV="${OS_FLAVOR}${OS_VERSION}"
		elif [ -f /etc/redhat-release ] ; then
			OS_DISTROBASE='RedHat'
			DIST=`cat /etc/redhat-release |sed s/\ release.*//`
			PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
			OS_REVISION=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
		elif [ -f /etc/SuSE-release ] ; then
			OS_DISTROBASE='SuSe'
			PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
			OS_REVISION=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
		elif [ -f /etc/mandrake-release ] ; then
			OS_DISTROBASE='Mandrake'
			PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
			OS_REVISION=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
		elif [ -f /etc/UnitedLinux-release ] ; then
			DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
		else
			OS_FLAVOR="Unknown flavor unix (${osuname})"
			OS_NAME="Unknown ${osuname}"
		fi
	fi
}

showOsVar() {
	varName="$1"
	varValue="$2"
	printf '%-25s: %s\n' "${varName}" "${varValue}"
}

showOsInfo() {
	showOsVar "OS_TYPE" "${OS_TYPE}"
	showOsVar "OS_FLAVOR" "${OS_FLAVOR}"
	showOsVar "OS_DISTROBASE" "${OS_DISTROBASE}"
	showOsVar "OS_MACHINE" "${OS_MACHINE}"
	showOsVar "OS_NAME" "${OS_NAME}"
	showOsVar "OS_KERNEL" "${OS_KERNEL}"
	showOsVar "OS_VERSION" "${OS_VERSION}"
	showOsVar "OS_RELEASE" "${OS_RELEASE}"
	showOsVar "OS_REVISION" "${OS_REVISION}"
	showOsVar "OS_CODENAME" "${OS_CODENAME}"
	showOsVar "OS_PRETTYNAME" "${OS_PRETTYNAME}"
	showOsVar "OS_FLAVVERFLAV" "${OS_FLAVVERFLAV}"
}

showOsValue() {
	case $optShowVariable in
		OS_TYPE)		echo "${OS_TYPE}"		;;
		OS_FLAVOR)		echo "${OS_FLAVOR}"		;;
		OS_DISTROBASE)	echo "${OS_DISTROBASE}"	;;
		OS_MACHINE)		echo "${OS_MACHINE}"	;;
		OS_NAME)		echo "${OS_NAME}" 		;;
		OS_KERNEL)		echo "${OS_KERNEL}"		;;
		OS_VERSION)		echo "${OS_VERSION}"	;;
		OS_RELEASE)		echo "${OS_RELEASE}"	;;
		OS_REVISION)	echo "${OS_REVISION}"	;;
		OS_CODENAME)	echo "${OS_CODENAME}"	;;
		OS_PRETTYNAME)	echo "${OS_PRETTYNAME}"	;;
		OS_FLAVVERFLAV)	echo "${OS_FLAVVERFLAV}"	;;
		*)				echo "##BAD_OS_VARIABLE(${optShowVariable})##"	;;
	esac
}

writeOsVars() {
	cat >"${optOutFile}" <<EOD
OS_TYPE=${OS_TYPE}
OS_FLAVOR=${OS_FLAVOR}
OS_DISTROBASE=${OS_DISTROBASE}
OS_MACHINE=${OS_MACHINE}
OS_NAME=${OS_NAME}
OS_KERNEL=${OS_KERNEL}
OS_VERSION=${OS_VERSION}
OS_RELEASE=${OS_RELEASE}
OS_REVISION=${OS_REVISION}
OS_CODENAME=${OS_CODENAME}
OS_PRETTYNAME=${OS_PRETTYNAME}
EOD
}

exportOsVars() {
	export OS_TYPE
	export OS_FLAVOR
	export OS_DISTROBASE
	export OS_MACHINE
	export OS_NAME
	export OS_KERNEL
	export OS_VERSION
	export OS_RELEASE
	export OS_REVISION
	export OS_CODENAME
	export OS_PRETTYNAME
	
	[ $optDebug ] && echo "Exported OS Variables"
}

#
# Command Line Options
#
getOptions() {

optDebug=
optVerbose=
optView=
optExport=
optOutput=
optOurFile=
optShow=
optShowVariable=

while getopts "?hvdVXo:s:" OPTION
do
	case $OPTION in
        h)	usage ; exit 1                                      ;;
		V)  optView=1                                           ;;
		X)  optExport=1                                         ;;
		o)  optOutput=1 ; optOutFile=$OPTARG					;;
		s)  optShow=1 ; optShowVariable=$OPTARG					;;
        v)  optVerbose=1 ; optView=1                            ;;
        d)  optDebug=1 ; optVerbose=1 ; optView=1               ;;
		?)  usage ; exit 0                                      ;;
    esac
done
shift $(($OPTIND - 1)) 

if [ ! $optExport ] && [ ! $optOutFile ] && [ ! $optShow ] ; then optView=1 ; fi

if [ $optView ] ; then
	showOsVar "OS Variable" "Value"
	showOsVar "------------------------" "------------------------------------------------------------"
fi

verboseFlag=
if [ $optVerbose ] ; then verboseFlag=-v; fi

}

usage() {
    cat <<EOFUsage
${prognm} [-v] [-V] [-X] [-o <filename>]

    Options:
        -V               View system information (default if no options specified)
        -X               Export OS variables
        -s <variable>    Get and show value of variable <variable>
        -o <filename>    Write OS variables to file <filename>
        -v               Verbose (displays detailed info)
        -d               Debug (displays more detailed info)
EOFUsage
}

# ==========================================================================================================
# NOTES 
# ==========================================================================================================
# Cygwin
#
#	Result:
#		$ /cygdrive/i/kode/mhg/mhgPress/serverConfig/osInfo.sh
#		OS Variable              : Value
#		------------------------ : ------------------------------------------------------------
#		OS_TYPE                  : Unix
#		OS_FLAVOR                : Cygwin
#		OS_DISTROBASE            : Cygwin
#		OS_MACHINE               : x86_64
#		OS_NAME                  : Cygwin
#		OS_KERNEL                : 3.1.4(0.340/5/3)
#		OS_VERSION               : 10
#		OS_RELEASE               : 10.0
#		OS_REVISION              : 10.0
#		OS_CODENAME              :
#		OS_PRETTYNAME            : CYGWIN_NT-10.0	elif [ "${osuname}" == "linux" ] ; then
#
# ==========================================================================================================
# Ubuntu
#
#	Files:
#		root@ubuntu: ls -l /etc | grep -i '\(version\|release\|info\)'
#		-rw-r--r--  1 root root  	11 Aug  6  2018 debian_version
#		lrwxrwxrwx  1 root root  	39 Aug  4 11:55 localtime -> /usr/share/zoneinfo/America/Los_Angeles
#		-rw-r--r--  1 root root  	97 Dec  5  2019 lsb-release
#		lrwxrwxrwx  1 root root  	21 Dec  5  2019 os-release -> ../usr/lib/os-release
#		drwxr-xr-x  2 root root	4096 Feb  2  2020 terminfo
#
#		root@ubuntu: cat /etc/lsb-release
#		DISTRIB_ID=Ubuntu
#		DISTRIB_RELEASE=19.10
#		DISTRIB_CODENAME=eoan
#		DISTRIB_DESCRIPTION="Ubuntu 19.10"
#
#		root@ubuntu: cat /etc/os-release
#		NAME="Ubuntu"
#		VERSION="19.10 (Eoan Ermine)"
#		ID=ubuntu
#		ID_LIKE=debian
#		PRETTY_NAME="Ubuntu 19.10"
#		VERSION_ID="19.10"
#		HOME_URL="https://www.ubuntu.com/"
#		SUPPORT_URL="https://help.ubuntu.com/"
#		BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
#		PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
#		VERSION_CODENAME=eoan
#		UBUNTU_CODENAME=eoan
#
#		root@ubuntu:/mnt/kode/mhg/mhgPress/serverConfig# cat /etc/debian_version
#		buster/sid
#
#	Result:
#		root@ubuntu: ./osInfo.sh
#		OS Variable          	: Value
#		----------------------- : ------------------------------------------------------------
#		OS_TYPE              	: Unix
#		OS_FLAVOR            	: Ubuntu
#		OS_DISTROBASE        	: Debian
#		OS_MACHINE           	: x86_64
#		OS_NAME              	: Ubuntu
#		OS_KERNEL            	: 5.3.0-29-generic
#		OS_VERSION           	: 19
#		OS_RELEASE           	: 19.10
#		OS_REVISION          	: 19.10
#		OS_CODENAME          	: eoan
#		OS_PRETTYNAME        	: Ubuntu 19.10 (eoan-buster/sid)
#
# ==========================================================================================================
# Debian
#
#	Files:
#		root@mhgpress: cat /etc/os-release
#		PRETTY_NAME="Debian GNU/Linux 10 (buster)"
#		NAME="Debian GNU/Linux"
#		VERSION_ID="10"
#		VERSION="10 (buster)"
#		VERSION_CODENAME=buster
#		ID=debian
#		HOME_URL="https://www.debian.org/"
#		SUPPORT_URL="https://www.debian.org/support"
#		BUG_REPORT_URL="https://bugs.debian.org/"
#
#	Result:
#		root@mhgpress:/mnt/kode/mhg/mhgPress/serverConfig# ./osInfo.sh
#		OS Variable          	 : Value
#		------------------------ : ------------------------------------------------------------
#		OS_TYPE              	 : Unix
#		OS_FLAVOR            	 : Debian
#		OS_DISTROBASE        	 : Debian
#		OS_MACHINE           	 : x86_64
#		OS_NAME              	 : Debian GNU/Linux
#		OS_KERNEL            	 : 4.19.0-9-amd64
#		OS_VERSION           	 : 10
#		OS_RELEASE           	 : 10.5
#		OS_REVISION          	 : 10.5
#		OS_CODENAME          	 : buster
#		OS_PRETTYNAME        	 : Debian GNU/Linux 10.5 (buster)
#
# ==========================================================================================================
# CentOS
#
#  Files:
#		[mhgadmin@mhgpress ~]$ ls -l /etc | grep -i release
#		-rw-r--r--.  1 root root    	38 Jun  2 21:02 centos-release
#		-rw-r--r--.  1 root root    	51 Jun  2 21:02 centos-release-upstream
#		lrwxrwxrwx.  1 root root    	21 Jun  2 21:02 os-release -> ../usr/lib/os-release
#		lrwxrwxrwx.  1 root root    	14 Jun  2 21:02 redhat-release -> centos-release
#		lrwxrwxrwx.  1 root root    	14 Jun  2 21:02 system-release -> centos-release
#		-rw-r--r--.  1 root root    	23 Jun  2 21:02 system-release-cpe
#		[mhgadmin@mhgpress ~]$ cat /etc/centos-release
#		CentOS Linux release 8.2.2004 (Core)
#		[mhgadmin@mhgpress ~]$ cat /etc/redhat-release
#		CentOS Linux release 8.2.2004 (Core)
#		[mhgadmin@mhgpress ~]$ cat /etc/system-release
#		CentOS Linux release 8.2.2004 (Core)
#		[mhgadmin@mhgpress ~]$ cat /etc/os-release
#		NAME="CentOS Linux"
#		VERSION="8 (Core)"
#		ID="centos"
#		ID_LIKE="rhel fedora"
#		VERSION_ID="8"
#		PLATFORM_ID="platform:el8"
#		PRETTY_NAME="CentOS Linux 8 (Core)"
#		ANSI_COLOR="0;31"
#		CPE_NAME="cpe:/o:centos:centos:8"
#		HOME_URL="https://www.centos.org/"
#		bugs.centos.org/"
#		CENTOS_MANTISBT_PROJECT="CentOS-8"
#		CENTOS_MANTISBT_PROJECT_VERSION="8"
#		REDHAT_SUPPORT_PRODUCT="centos"
#		REDHAT_SUPPORT_PRODUCT_VERSION="8"
#
#	Result:
#		[root@mhgpress serverConfig]# ./osInfo.sh
#		OS Variable          	: Value
#		----------------------- : ------------------------------------------------------------
#		OS_TYPE              	: Unix
#		OS_FLAVOR            	: CentOS
#		OS_DISTROBASE        	: RedHat
#		OS_MACHINE           	: x86_64
#		OS_NAME              	: CentOS Linux
#		OS_KERNEL            	: 4.18.0-193.14.2.el8_2.x86_64
#		OS_VERSION           	: 8
#		OS_RELEASE           	: CentOS Linux release 8.2.2004 (Core)
#		OS_REVISION          	: 8.2.2004
#		OS_CODENAME          	:
#		OS_PRETTYNAME        	: CentOS Linux 8.2.2004			

#
# MAIN
#
getOptions "$@"
getOsInfo

if [ $optView ] ; then showOsInfo; fi
if [ $optExport ] ; then exportOsVars; fi
if [ $optOutput ] ; then writeOsVars ; fi
if [ $optShow ] ; then showOsValue ; fi

