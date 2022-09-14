#
# core-time.sh
#
#	MAUDE Time and Timer routines
#
#	Description:
#
#       Timer and time routines
#
#	Copyright:
#		Copyright (c) 2022, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.01.15  01.00    KurtSchulte    Original Version
#
####################################################################################################

timestamp() {
	local currTS=$(date +%Y.%m.%d-%H.%M.%S)
	printf "%s" "${currTS}"
}

timerStart() {
	local startTime=$(date +%s)
	echo "${startTime}"
}	

timerElapsed() {
	local startTime="${1:-1}"
	
	local timeCurr=$(date +%s)
	local elapsedSecs=$(( $timeCurr - $startTime ))
	local elapsedHours=$(( $elapsedSecs / 3600 ))
	local elapsedSecs2=$(( $elapsedSecs - $elapsedHours * 3600 ))
	local elapsedMinutes=$(( $elapsedSecs2 / 60 ))
	elapsedSecs=$(( $elapsedSecs2 - $elapsedMinutes * 60 ))
	printf "%02d:%02d:%02d" $elapsedHours $elapsedMinutes $elapsedSecs
}