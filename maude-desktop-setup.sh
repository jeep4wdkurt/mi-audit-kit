#
# desktop-setup.sh
#
#	MAUDE Desktop setup
#
#	Description:
#
#       Set up MAUDE user desktop
#
#	Copyright:
#		Copyright (c) 2022, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.01.19  01.00    KurtSchulte    Original Version
#
####################################################################################################

prognm="maude-desktop-setup.sh"

maudImagesFolder="${maudRootFolder}/images"
maudBackgroundsFolder="${maudImagesFolder}/backgrounds"
maudBackgroundDefaultName="MAUDE-MI-logo-1300x1300.png"
maudBackgroundDefaultFile="${maudBackgroundsFolder}/${maudBackgroundDefaultName}"
maudBackgroundDefaultUri="file://${maudBackgroundDefaultFile}"

maudUserSharedFolder="/usr/share/mi-audit"
maudUserSharedBackgroundsFolder="${maudUserSharedFolder}/backgrounds"
maudUserSharedBackgroundDefaultFile="${maudUserSharedBackgroundsFolder}/${maudBackgroundDefaultName}"

maudUserFolderPerms=755
maudUserLocalFolder="${HOME}/mi-audit"
maudUserLocalStatusFile="${maudUserLocalFolder}/.maude_status"

xfceDesktopBackgroundImageParam="/backdrop/screen0/monitorVirtual1/workspace0/last-image"
xfceDesktopBackgroundStyleParam="/backdrop/screen0/monitorVirtual1/workspace0/image-style"

#
# Create MAUDE User Local folder, if needed
#
if [ ! -d "${maudUserLocalFolder}" ] ; then
	mkdir --mode=$maudUserFolderPerms "${maudUserLocalFolder}"
	errCode=$? ; [ $errCode -ne 0 ] && {
		echo "${prognm//.sh/}.Error: Can't create MAUDE User Local folder '${maudUserLocalFolder}'" ;
		exit 1 ;
		}
fi

#
# Determine Desktop Manager
#
dmgrLight=$(systemctl status display-manager | grep -c 'Light Display Manager')
dmgrGnome=$(systemctl status display-manager | grep -c 'GNOME Display Manager')
dmgrName="Unknown"
[ $dmgrLight -gt 0 ] && dmgrName="Light (xfc)"
[ $dmgrGnome -gt 0 ] && dmgrName="GNOME"

#
# Determine if MAUDE wallpaper has already been set once.
#
backgroundAlreadySet=0
[ -f "${maudUserLocalStatusFile}" ] &&
	[ $(cat "${maudUserLocalStatusFile}" |
		grep '^[ \t]*MAUDE_BACKGROUND_INITIALIZED[ \t]*=[ \t]*1.*$' |wc -l) -gt 0 ] && backgroundAlreadySet=1

#
# Change Wallpaper (if never installed before)
# 
if [ $backgroundAlreadySet -eq 0 ] ; then

	#
	# Light Display Manager (xfc)
	#
	if [ $dmgrLight -gt 0 ] ; then

		# Set background
		xfconf-query -c xfce4-desktop -p "${xfceDesktopBackgroundImageParam}" -s "${maudUserSharedBackgroundDefaultFile}"
		errCode=$? ; [ $errCode -ne 0 ] &&
			{ echo "${prognm//.sh/}.Error: Can't set ${dmgrName} desktop background file '${maudUserSharedBackgroundDefaultFile}'" ;
			  exit 1; }
		
		#Set background style
		xfconf-query -c xfce4-desktop -p "${xfceDesktopBackgroundStyleParam}" -s "4"
		errCode=$? ; [ $errCode -ne 0 ] &&
			{ echo "${prognm//.sh/}.Error: Can't set ${dmgrName} desktop background style '${xfceDesktopBackgroundStyleParam}'" ;
			  exit 1; }
	fi

	#
	# GNOME Display Manager
	#
	if [ $dmgrGnome -gt 0 ] ; then

		# Set background
		gsettings set org.gnome.desktop.background picture-uri "${maudBackgroundDefaultUri}"
		errCode=$? ; [ $errCode -ne 0 ] &&
			{ echo "${prognm//.sh/}.Error: Can't set ${dmgrName} desktop background file '${maudBackgroundDefaultUri}'" ;
			  exit 1; }
			  
		# Set background style
		gsettings set org.gnome.desktop.background picture-options 'scaled'
		errCode=$? ; [ $errCode -ne 0 ] &&
			{ echo "${prognm//.sh/}.Error: Can't set ${dmgrName} desktop background style '${maudBackgroundDefaultUri}'" ;
			  exit 1; }
	fi

	# Indicate MAUDE background installed status in MAUDE status tracking file
	[ -f "${maudUserLocalStatusFile}" ] && sed -i -e '/MAUDE_BACKGROUND_INITIALIZED/d' "${maudUserLocalStatusFile}"
	echo "MAUDE_BACKGROUND_INITIALIZED=1"	>>"${maudUserLocalStatusFile}"
	
	# Announce set up complete
	echo "MAUDE ${dmgrName} Display Manager desktop setup complete."

fi


#
#  
#

