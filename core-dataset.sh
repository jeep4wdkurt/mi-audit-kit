#
# core-dataset.sh
#
#	MAUDE Dataset support routines
#
#	Description:
#
#       Routines specific to datasets
#
#	Copyright:
#		Copyright (c) 2022, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#       Date        Version  Author         Desc
#       2022.01.21  01.00    KurtSchulte    Original Version
#
####################################################################################################

# 
# Constants
#
datasetList="2000-01-01,2016-09-01,2021-01-01,2022-02-01"
datastoreList="common,specific"
datasetQvfObfuscationName="Corn-Data"
datasetHistoryObfuscationName="Corn-History"

datasetGoonKeyNA="<na>"
dataset000101_goonKey="1ZAOj4XUKhoyBQoUUXGOA1Bi_gMMUutZC"
dataset160901_goonKey="1DzNC6V2aJAlAMdPfXuCekiIeUUGq2BIv"		# https://drive.google.com/file/d/1DzNC6V2aJAlAMdPfXuCekiIeUUGq2BIv/view?usp=sharing
dataset210101_goonKey="1o-eJaRHd8lmkTIL355rUJKyf9YC79jgQ"
dataset220201_goonKey="19F1R1AQ8-zym0Je-bMCkcyX3lt_FCOfz"		# https://drive.google.com/file/d/19F1R1AQ8-zym0Je-bMCkcyX3lt_FCOfz/view?usp=sharing
datasethist160901_goonKey="1z9PfDtNxccRdjoWm7eN3nqAXvgb8CXxD"	# https://drive.google.com/file/d/1z9PfDtNxccRdjoWm7eN3nqAXvgb8CXxD/view?usp=sharing
datasethist210101_goonKey="1ncHaCrsL6WARKlHj3CH2tWWmGYubwWpb"
datasethist220201_goonKey="1PqEIMRsvF5g2X6jp13WxnQrDxzLpJgPt"	# https://drive.google.com/file/d/1PqEIMRsvF5g2X6jp13WxnQrDxzLpJgPt/view?usp=sharing

#  Validate a dataset ID (format yyyy-mm)
#
#	If dataset ID is valid, sets:
#
#		datasetIdentifier		- dataset ID yyyy-mm-dd
#		datasetDate				- Date of dataset yyyy-mm-dd
#		datasetYear				- Year of dataset yyyy
#		datasetIdShort			- yymmdd from dataset identifier
#		datasetElectionDate		- election date, derived from datasetDate
#		datasetElectionYear		- election year, from datasetElectionDate
#		datasetName				- EntireStateVoters-${datasetID}
#		datasetFilespec 		- Dataset QVF file specification
#		datasetChecksumFilespec - Dataset QVF checksum file specification
#		datasetHistoryName		- EntireStateVoterHistory-${datasetID}
#		datasetHistoryFilespec	- Dataset Voter History file specification
#		datasetHistoryChecksumFilespec	- Dataset Voter History checksum file specification
# 		datasetReportFolder		- Folder for reports for this dataset (<report-folder>/<dataset-identifier>)
#		datasetSaltFile			- Dataset distribution encryption salt
#		datasetGoonKey			- Location on Goon shares of dataset QVF archive.
#		datasethistGoonKey		- Location on Goon shares of dataset Voter history archive.
# 
DatasetId_Validate() {
	local datasetID="$1"

	[ $(echo ",${datasetList}," | grep -c ",${datasetID},") -eq 0 ] &&
		barfe "Invalid dataset id '${datasetID}'. Valid options are: '${datasetList}'"
		
	datasetIdentifier="${datasetID}"
	datasetDate="${datasetIdentifier}"

	datasetName="EntireStateVoters-${datasetIdentifier}"
	datasetFilespec="${maudStateDataFolder}/${datasetName}.csv"
	datasetChecksumFilespec="${maudStateDataFolder}/${datasetName}.cks"
	
	datasetHistoryName="EntireStateVoterHistory-${datasetIdentifier}"
	datasetHistoryFilespec="${maudStateDataFolder}/${datasetHistoryName}.csv"
	datasetHistoryChecksumFilespec="${maudStateDataFolder}/${datasetHistoryName}.cks"

	datasetReportFolder="${maudReportFolder}/${datasetIdentifier}"
	datasetImportWorkFolder="${maudWorkFolder}/qvf-${datasetIdentifier}"
	datasetLoadWorkFolder="${maudWorkFolder}/load-${datasetIdentifier}"

	# Create variables based on dataset id
	datasetIdShort="${datasetIdentifier:2}"
	datasetIdShort="${datasetIdShort//-/}"

	datasetYear="${datasetIdentifier:0:4}"
	datasetElectionDate="2020-11-03"
	[ $(("${datasetYear}" <= 2016)) == 1 ] && datasetElectionDate="2016-11-01"
	datasetElectionYear="${datasetElectionDate:0:4}"
	
	datasetPrepareQvfControl="${maudReferenceFolder}/qvf-load-prepare-control.dat"
	datasetPrepareHistoryControl="${maudReferenceFolder}/history-load-prepare-control.dat"

	# Installation stuff

	datasetSaltFile="${maudReferenceFolder}/qvf-salt.dat"
	datasetGoonKeyVar="dataset${datasetIdShort}_goonKey"
	datasetGoonKey="${!datasetGoonKeyVar}"
	[ "${datasetGoonKey}" == "" ] && barfe "Error: Goon Key not configured for dataset ${datasetIdentifier}"

	datasethistGoonKeyVar="datasethist${datasetIdShort}_goonKey"
	datasethistGoonKey="${!datasethistGoonKeyVar}"

}

#
# Validate a list of dataset IDs
#
DatasetList_Validate() {
	local datasetIDs="$1"
	
	local checkId
 	while read checkId ; do
		[ $(echo ",${datasetList}," | grep -c ",${checkId},") -eq 0 ] &&
			barfe "Invalid dataset id '${datasetID}'. Valid options are: '${datasetList}'"
	done < <(printf "%s" "${datasetIDs}" | tr ',' '\n')
}

#
# Validate a datatstore specification (common or specific)
#		If valid, sets:
#			datastoreType		- common or specific
#			datastoreSchema		- schema to use for datastore
#
Datastore_Validate() {
	local aDatastoreType="$1"
	[ $(echo ",${datastoreList}," | grep -c ",${aDatastoreType},") -eq 0 ] &&
		barfe "Invalid datastore id '${aDatastoreType}'. Valid options are: '${datastoreList}'"

	datastoreType="${aDatastoreType}"
	datastoreSchema="ma"
	datastoreTitle="common"
	if [ "${datastoreType}" == "specific" ] ; then
		[ "${datasetIdShort}" == "" ] && barfe "Code error.... Dataset info not set for datastore '${datastoreType}'"
		datastoreSchema="ma${datasetIdShort}"
		datastoreTitle="Dataset ${datasetIdentifier}"
	fi
}
