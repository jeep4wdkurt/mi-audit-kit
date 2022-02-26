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

maudRootFolder="/usr/sbin/mi-audit"
maudImagesFolder="${maudRootFolder}/images"
maudBackgroundsFolder="${maudImagesFolder}/backgrounds"
maudBackgroundDefaultName="MAUDE-MI-logo-1300x1300.png"
maudBackgroundDefaultFile="${maudBackgroundsFolder}/${maudBackgroundDefaultName}"

maudUserSharedFolder="/usr/share/mi-audit"
maudUserSharedBackgroundsFolder="${maudUserSharedFolder}/backgrounds"
maudUserSharedBackgroundDefaultFile="${maudUserSharedBackgroundsFolder}/${maudBackgroundDefaultName}"
maudUserSharedBackgroundDefaultUri="file://${maudUserSharedBackgroundDefaultFile}"

maudUserFolderPerms=755
maudUserLocalFolder="${HOME}/mi-audit"
maudUserLocalStatusFile="${maudUserLocalFolder}/.maude_status"

xfceDesktopBackgroundImageParam="/backdrop/screen0/monitorVirtual1/workspace0/last-image"
xfceDesktopBackgroundStyleParam="/backdrop/screen0/monitorVirtual1/workspace0/image-style"

# Bacground colors
colorPurple='#4f08d1'	# Purple
colorBlue='#1434be' 	# Blue
colorYellow='#fdf65d' 	# Yellow

optDebug=
[ "${MAUDE_DEBUG}" != "" ] && [ "${MAUDE_DEBUG}" -ne 0 ] && optDebug=1

barfd() { [ $optDebug ] && echo "$1" ; }

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

barfd "Display Manager   : ${dmgrName}"
barfd "Background URI    : '${maudUserSharedBackgroundDefaultUri}'"

#
# Determine if MAUDE wallpaper has already been set once.
#
backgroundAlreadySet=0
[ -f "${maudUserLocalStatusFile}" ] &&
	[ $(cat "${maudUserLocalStatusFile}" |
		grep '^[ \t]*MAUDE_BACKGROUND_INITIALIZED[ \t]*=[ \t]*1.*$' |wc -l) -gt 0 ] &&
	backgroundAlreadySet=1

barfd "MAUDE Status File : '${maudUserLocalStatusFile}'"
barfd "Background Set    : ${backgroundAlreadySet}"

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
		barfd "Setting ${dmgrName} background image..."
		gsettings set org.gnome.desktop.background picture-uri "${maudUserSharedBackgroundDefaultUri}"
		errCode=$? ; [ $errCode -ne 0 ] &&
			{ echo "${prognm//.sh/}.Error: Can't set ${dmgrName} desktop background file '${maudUserSharedBackgroundDefaultUri}'" ;
			  exit 1; }
		barfd "Setting ${dmgrName} background complete."
			  
		# Set background style
		barfd "Setting ${dmgrName} background style..."
		gsettings set org.gnome.desktop.background picture-options 'scaled'
		errCode=$? ; [ $errCode -ne 0 ] &&
			{ echo "${prognm//.sh/}.Error: Can't set ${dmgrName} desktop background style '${maudUserSharedBackgroundDefaultUri}'" ;
			  exit 1; }
		barfd "Setting ${dmgrName} background style complete."

		# Set background color
		barfd "Setting ${dmgrName} background color..."
		gsettings set org.gnome.desktop.background primary-color "${colorBlue}"
		errCode=$? ; [ $errCode -ne 0 ] &&
			{ echo "${prognm//.sh/}.Error: Can't set ${dmgrName} desktop background color '${maudUserSharedBackgroundDefaultUri}'" ;
			  exit 1; }
		barfd "Setting ${dmgrName} background color complete."

	fi

	# Indicate MAUDE background installed in MAUDE status tracking file
	[ -f "${maudUserLocalStatusFile}" ] && sed -i -e '/MAUDE_BACKGROUND_INITIALIZED/d' "${maudUserLocalStatusFile}"
	echo "MAUDE_BACKGROUND_INITIALIZED=1"	>>"${maudUserLocalStatusFile}"
	
	# Announce set up complete
	echo "MAUDE ${dmgrName} Display Manager desktop setup complete."

fi
