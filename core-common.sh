#
# core-common.sh
#
#	Michigan Audit of Elections (MAUDE) Common Includes
#
#	Description:
#
#       Common Includes
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
# System Info
#
hostDomain=$(dnsdomainname | tr -d '\n')
if [ "${hostDomain}" == "" ] ; then echo "Unable to determine host domain"; exit 1; fi

#
# Core Routines
#
source "${maudProgFolder}"/core-version.sh							# Application version and build info
source "${maudProgFolder}"/core-folders.sh							# Folder definitions
source "${maudProgFolder}"/core-filesystem.sh						# File system routines
source "${maudProgFolder}"/core-io.sh								# I/O routines
source "${maudProgFolder}"/core-time.sh								# Time and timer routines



