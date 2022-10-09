#
# core-dataset.sh
#
#     MAUDE Dataset support routines
#
#   Description:
#
#       Routines and data for datasets
#
#   Datasets:
#       Dataset Date  Source  Goon Library  Add Date
#       2021-10-01     002    maudelib003   2022.10.09
#       2013-06-01     001    maudelib003   2022.09.27
#       2014-09-01     001    maudelib003   2022.09.27
#       2015-10-01     001    maudelib003   2022.09.27
#       2016-01-01     001    maudelib003   2022.09.25
#       2016-09-01     001    maudelib001   2021.12.31
#		2017-07-12     001    maudelib003   2022.09.25
#		2017-10-31     001    maudelib003   2022.09.25
#       2019-01-01     002    maudelib002   2022.09.03
#       2019-10-01     002    maudelib002   2022.09.24
#       2020-03-01     002    maudelib002   2022.09.03
#       2020-06-01     002    maudelib002   2022.09.03
#       2020-10-01     002    maudelib002   2022.09.03
#       2020-11-01     002    maudelib002   2022.09.03
#       2020-12-01     002    maudelib002   2022.09.03
#       2021-01-01     002    maudelib001   2021.01.22
#       2021-04-01     002    maudelib002   2022.09.03
#		2021-10-01     002    maudelib002   2022.09.24
#		2021-12-01     002    maudelib002   2022.09.24
#       2022-02-01     002    maudelib001   2021.02.22
#       2022-03-01     002    maudelib001   2022.09.03
#       2022-04-01     002    maudelib001   2022.09.03
#       2022-05-01     002    maudelib001   2022.09.03
#       2022-06-01     002    maudelib001   2022.09.03
#       2022-07-01     002    maudelib002   2022.09.03
#       2022-08-01     002    maudelib001   2022.08.28
#       2022-09-01     002    maudelib002   2022.09.16
#
#   Data Sources:
#       001         Unknown    http://69.64.83.144/~mi/download/
#       002         Psypher    <n/a>
#
#   Copyright:
#       Copyright (c) 2022, Kurt Schulte - All rights reserved.  No use without written authorization.
#
#   History:
#       Date        Version  Author         Desc
#       2022.10.09  01.09    Kurt Schulte   Add 2022-10-01
#       2022.09.25  01.08    Kurt Schulte   Add 2013-06-01, 2014-09-01,2015-10-01, 2016-01-01, 2017-05-12, 2017-10-31, 2019-10-01, 2021-10-01, 2021-12-01
#       2022.09.21  01.07    Kurt Schulte   Add aggregate schema, datasetIdShortText, datasetIdMediumText
#       2022.09.16  01.06    Kurt Schulte   Add 2022-09-01
#       2022.09.13  01.03    Kurt Schulte   Add reference dataset fields
#       2022.09.03  01.02    Kurt Schulte   Add 2022-01-01, 2022-03-01, 2022-04-01, 2022-05-01, 2022-06-01 datasets
#       2022.08.28  01.01    Kurt Schulte   Add 2022-08-01 dataset
#       2022.01.21  01.00    Kurt Schulte   Original Version
#
####################################################################################################

# 
# Constants
#
datasetList="2022-10-01,2022-09-01,2022-08-01,2022-07-01,2022-06-01,2022-05-01,2022-04-01,2022-03-01,2022-02-01,2022-01-01"
datasetList="${datasetList},2021-12-01,2021-10-01,2021-04-01,2021-01-01"
datasetList="${datasetList},2020-12-01,2020-11-01,2020-10-01,2020-06-01,2020-03-01"
datasetList="${datasetList},2019-10-01,2019-01-01"
datasetList="${datasetList},2017-10-31,2017-05-12"
datasetList="${datasetList},2016-09-01,2016-01-01,2015-10-01,2014-09-01,2013-06-01,2000-01-01"
datasetCurrent=$(echo "${datasetList}" | cut -d, -f1)
datasetPrior=$(echo "${datasetList}" | cut -d, -f1)
datastoreList="common,specific,aggregate"
datasetQvfObfuscationName="Corn-Data"
datasetHistoryObfuscationName="Corn-History"

datasetGoonKeyNA="<na>"
dataset000101_goonKey="1ZAOj4XUKhoyBQoUUXGOA1Bi_gMMUutZC"
dataset130601_goonKey="1DfMoghg5Pe9qwrbm1HGQwjNjZosrcsIk"		# https://drive.google.com/file/d/1DfMoghg5Pe9qwrbm1HGQwjNjZosrcsIk/view?usp=sharing
dataset140901_goonKey="1xBLzMlzlVLfEqLNXLNCp1HTM0nVyhDbV"		# https://drive.google.com/file/d/1xBLzMlzlVLfEqLNXLNCp1HTM0nVyhDbV/view?usp=sharing
dataset151001_goonKey="1-wgEcjDF4sv5MEZ4UEhlsoxoSYSQxkge"		# https://drive.google.com/file/d/1-wgEcjDF4sv5MEZ4UEhlsoxoSYSQxkge/view?usp=sharing
dataset160101_goonKey="1cFzEUKPRCA7W4vwxFbpcqcoF8hRNIF-z"		# https://drive.google.com/file/d/1cFzEUKPRCA7W4vwxFbpcqcoF8hRNIF-z/view?usp=sharing
dataset160901_goonKey="1DzNC6V2aJAlAMdPfXuCekiIeUUGq2BIv"		# https://drive.google.com/file/d/1DzNC6V2aJAlAMdPfXuCekiIeUUGq2BIv/view?usp=sharing
dataset170512_goonKey="1XcOHZLgJ8O-aJtJHwHpUVVCV799MNpLF"		# https://drive.google.com/file/d/1XcOHZLgJ8O-aJtJHwHpUVVCV799MNpLF/view?usp=sharing
dataset171031_goonKey="1sOjZbtNuK5WRF5_I0Zch4vIkDGp0R7w0"		# https://drive.google.com/file/d/1sOjZbtNuK5WRF5_I0Zch4vIkDGp0R7w0/view?usp=sharing
dataset190101_goonKey="1TSXSSHQdXiTRbIgWqJ4qHqujFwoSDfeg"		# https://drive.google.com/file/d/1TSXSSHQdXiTRbIgWqJ4qHqujFwoSDfeg/view?usp=sharing
dataset191001_goonKey="1a6wS7wpBczb1geA24EaAPQzxfUzwWkXW"		# https://drive.google.com/file/d/1a6wS7wpBczb1geA24EaAPQzxfUzwWkXW/view?usp=sharing
dataset200301_goonKey="1d8KHnEMv_M5hV8CRxEfn4p1HC_UyOABu"		# https://drive.google.com/file/d/1d8KHnEMv_M5hV8CRxEfn4p1HC_UyOABu/view?usp=sharing
dataset200601_goonKey="1u20LiJMIkkCIpcIMT-Shs5muerA84uz3"		# https://drive.google.com/file/d/1u20LiJMIkkCIpcIMT-Shs5muerA84uz3/view?usp=sharing
dataset201001_goonKey="1jGSwKjd2rc_kSfnpgboUiFKOjgQjyGOh"		# https://drive.google.com/file/d/1jGSwKjd2rc_kSfnpgboUiFKOjgQjyGOh/view?usp=sharing
dataset201101_goonKey="1h1r-U2AWXgeXIA_EnRAm2i2IYWKoMUXp"		# https://drive.google.com/file/d/1h1r-U2AWXgeXIA_EnRAm2i2IYWKoMUXp/view?usp=sharing
dataset201201_goonKey="1aWw-20sz_OL6FUV6qa4tABcBezpM--pP"		# https://drive.google.com/file/d/1aWw-20sz_OL6FUV6qa4tABcBezpM--pP/view?usp=sharing
dataset210101_goonKey="1o-eJaRHd8lmkTIL355rUJKyf9YC79jgQ"		# https://drive.google.com/file/d/1o-eJaRHd8lmkTIL355rUJKyf9YC79jgQ/view?usp=sharing
dataset210401_goonKey="1CXg4JGMfzrGxgsIZoegGoe5gIRSe5bKM"		# https://drive.google.com/file/d/1CXg4JGMfzrGxgsIZoegGoe5gIRSe5bKM/view?usp=sharing
dataset211001_goonKey="1aIap1YD_aDxt-XcnQyG0zwnYhzBXVHwe"		# https://drive.google.com/file/d/1aIap1YD_aDxt-XcnQyG0zwnYhzBXVHwe/view?usp=sharing
dataset211201_goonKey="1XijobE7Krhsx6cd0TlpgFyiEO4Gyfamg"		# https://drive.google.com/file/d/1XijobE7Krhsx6cd0TlpgFyiEO4Gyfamg/view?usp=sharing
dataset220101_goonKey="1Bhp7udNXHT0ZEPKqpmAHkMYylv7Fcs_0"		# https://drive.google.com/file/d/1Bhp7udNXHT0ZEPKqpmAHkMYylv7Fcs_0/view?usp=sharing
dataset220201_goonKey="19F1R1AQ8-zym0Je-bMCkcyX3lt_FCOfz"		# https://drive.google.com/file/d/19F1R1AQ8-zym0Je-bMCkcyX3lt_FCOfz/view?usp=sharing
dataset220301_goonKey="1Fijr_96g_4lsjbqiXrF13AcQ0_LJRJ_K"		# https://drive.google.com/file/d/1Fijr_96g_4lsjbqiXrF13AcQ0_LJRJ_K/view?usp=sharing
dataset220401_goonKey="14sdE_FDTeGrRzGDEOuqEqnqWXTpnGel8"		# https://drive.google.com/file/d/14sdE_FDTeGrRzGDEOuqEqnqWXTpnGel8/view?usp=sharing
dataset220501_goonKey="1d6xQa-7Z9ivlV6p5_5Fk896bZuj6YwdV"		# https://drive.google.com/file/d/1d6xQa-7Z9ivlV6p5_5Fk896bZuj6YwdV/view?usp=sharing
dataset220601_goonKey="1Kz3uXQM_6lw4HhFY1sTnvSUKsQQIAGp8"		# https://drive.google.com/file/d/1Kz3uXQM_6lw4HhFY1sTnvSUKsQQIAGp8/view?usp=sharing
dataset220701_goonKey="1k_JXp6h-09jetHcEbRpyIMhV_LgV2dmM"		# https://drive.google.com/file/d/1k_JXp6h-09jetHcEbRpyIMhV_LgV2dmM/view?usp=sharing
dataset220801_goonKey="1J7C7plGUzrlDc0hNkoAmQn8p7JvxteVu"		# https://drive.google.com/file/d/1J7C7plGUzrlDc0hNkoAmQn8p7JvxteVu/view?usp=sharing
dataset220901_goonKey="1cO5lmI3e1xhPKE2_lvY1IJEPKzZL0U_S"		# https://drive.google.com/file/d/1cO5lmI3e1xhPKE2_lvY1IJEPKzZL0U_S/view?usp=sharing
dataset221001_goonKey="1zEpUVTCbCV4KDTLXi7vYd0WIApypagzq"		# https://drive.google.com/file/d/1zEpUVTCbCV4KDTLXi7vYd0WIApypagzq/view?usp=sharing
datasethist130601_goonKey="1j1n3vu_nb_-Ki8edURHSJ3skFlUIC0Ej"	# https://drive.google.com/file/d/1j1n3vu_nb_-Ki8edURHSJ3skFlUIC0Ej/view?usp=sharing
datasethist140901_goonKey="1ibku2sRDI9nuOvsNbBywELYkJBL76SGz"	# https://drive.google.com/file/d/1ibku2sRDI9nuOvsNbBywELYkJBL76SGz/view?usp=sharing
datasethist151001_goonKey="1zZkJlxQ-LEJe0dRKLH7bgZpHbNi43gZl"	# https://drive.google.com/file/d/1zZkJlxQ-LEJe0dRKLH7bgZpHbNi43gZl/view?usp=sharing
datasethist160101_goonKey="19gjXLuyNBiB5ElHZtZYHZ24EiSyYp62u"	# https://drive.google.com/file/d/19gjXLuyNBiB5ElHZtZYHZ24EiSyYp62u/view?usp=sharing
datasethist160901_goonKey="1z9PfDtNxccRdjoWm7eN3nqAXvgb8CXxD"	# https://drive.google.com/file/d/1z9PfDtNxccRdjoWm7eN3nqAXvgb8CXxD/view?usp=sharing
datasethist170512_goonKey="1hMPQKsYZ32wsVV6hmvegXSbieehJPZed"	# https://drive.google.com/file/d/1hMPQKsYZ32wsVV6hmvegXSbieehJPZed/view?usp=sharing
datasethist171031_goonKey="1kXi_1SxpA4N1aXcR61F4rwzQG-fRF08C"	# https://drive.google.com/file/d/1kXi_1SxpA4N1aXcR61F4rwzQG-fRF08C/view?usp=sharing
datasethist190101_goonKey="1wx5_xMTHKbq_LbYZkYBFaACcugxVB1P8"	# https://drive.google.com/file/d/1wx5_xMTHKbq_LbYZkYBFaACcugxVB1P8/view?usp=sharing
datasethist191001_goonKey="1S6TQDqqBgc__O-e5tgawYOsOc41kQTe0"	# https://drive.google.com/file/d/1S6TQDqqBgc__O-e5tgawYOsOc41kQTe0/view?usp=sharing
datasethist200301_goonKey="1jlEcQS6xeF_llPB29CrEYQpTrx-zdQyb"	# https://drive.google.com/file/d/1jlEcQS6xeF_llPB29CrEYQpTrx-zdQyb/view?usp=sharing
datasethist200601_goonKey="1oU6_6a9Q7FFjoEwX6-OboXFVy-zKqwY_"	# https://drive.google.com/file/d/1oU6_6a9Q7FFjoEwX6-OboXFVy-zKqwY_/view?usp=sharing
datasethist201001_goonKey="1SbWQ1cHMyUAryhpeW0cxPhUdV2L4c0jG"	# https://drive.google.com/file/d/1SbWQ1cHMyUAryhpeW0cxPhUdV2L4c0jG/view?usp=sharing
datasethist201101_goonKey="1MFxDvMuit4q65wV8DylgL4CfLSMLHCnw"	# https://drive.google.com/file/d/1MFxDvMuit4q65wV8DylgL4CfLSMLHCnw/view?usp=sharing
datasethist201201_goonKey="1noPii6FW-qW6jAAL01dwPQ8gjO3d-XeK"	# https://drive.google.com/file/d/1noPii6FW-qW6jAAL01dwPQ8gjO3d-XeK/view?usp=sharing
datasethist210101_goonKey="1ncHaCrsL6WARKlHj3CH2tWWmGYubwWpb"	# https://drive.google.com/file/d/1ncHaCrsL6WARKlHj3CH2tWWmGYubwWpb/view?usp=sharing
datasethist210401_goonKey="1h3D-OCiYNljTnis_KzkqDKQQjerlBUlW"	# https://drive.google.com/file/d/1h3D-OCiYNljTnis_KzkqDKQQjerlBUlW/view?usp=sharing
datasethist211001_goonKey="1suA2zjgC-GjFslzjMtGnd4wjn2NYiiwN"	# https://drive.google.com/file/d/1suA2zjgC-GjFslzjMtGnd4wjn2NYiiwN/view?usp=sharing
datasethist211201_goonKey="1zSf1w2R-umuIKA8TeZnAS0o34xjLHRgL"	# https://drive.google.com/file/d/1zSf1w2R-umuIKA8TeZnAS0o34xjLHRgL/view?usp=sharing
datasethist220101_goonKey="14YeyQOi0TeuAYvRUQ3ZqX_PU4dr_Urzb"   # https://drive.google.com/file/d/14YeyQOi0TeuAYvRUQ3ZqX_PU4dr_Urzb/view?usp=sharing
datasethist220201_goonKey="1PqEIMRsvF5g2X6jp13WxnQrDxzLpJgPt"	# https://drive.google.com/file/d/1PqEIMRsvF5g2X6jp13WxnQrDxzLpJgPt/view?usp=sharing
datasethist220301_goonKey="1HhPrOm5ID4Rju_QBlW3hwytjlTReH-hw"   # https://drive.google.com/file/d/1HhPrOm5ID4Rju_QBlW3hwytjlTReH-hw/view?usp=sharing
datasethist220401_goonKey="1ry8tj6vkpSyBkJjGJRMFSgX2Otc4-D0F"	# https://drive.google.com/file/d/1ry8tj6vkpSyBkJjGJRMFSgX2Otc4-D0F/view?usp=sharing
datasethist220501_goonKey="1kKY7VnSUTkrm-G86gvMlsQC4nXPo_nup"	# https://drive.google.com/file/d/1kKY7VnSUTkrm-G86gvMlsQC4nXPo_nup/view?usp=sharing
datasethist220601_goonKey="1QbXmDqwdLbR_8G_Rw_aY2TiDQtrBtYMv"	# https://drive.google.com/file/d/1QbXmDqwdLbR_8G_Rw_aY2TiDQtrBtYMv/view?usp=sharing
datasethist220701_goonKey="1WZC3b3KnnwSO_nWqVUyPwoQ-pMq0pCoh"	# https://drive.google.com/file/d/1WZC3b3KnnwSO_nWqVUyPwoQ-pMq0pCoh/view?usp=sharing
datasethist220801_goonKey="1AiIEmy08g1558IKWXkmKKJjS6C5mBOA9"	# https://drive.google.com/file/d/1AiIEmy08g1558IKWXkmKKJjS6C5mBOA9/view?usp=sharing
datasethist220901_goonKey="1RJVI_BOo-Ypdu60S3SOe5MhiKZWN7Dr_"	# https://drive.google.com/file/d/1RJVI_BOo-Ypdu60S3SOe5MhiKZWN7Dr_/view?usp=sharing
datasethist221001_goonKey="1psDl_JnrQ3n6ELddOsj1LgWyGBVCRzNy"	# https://drive.google.com/file/d/1psDl_JnrQ3n6ELddOsj1LgWyGBVCRzNy/view?usp=sharing

#  Validate a dataset ID (format yyyy-mm)
#
#	If dataset ID is valid, sets:
#
#		datasetIdentifier		- dataset ID yyyy-mm-dd
#		datasetDate				- Date of dataset yyyy-mm-dd
#		datasetYear				- Year of dataset yyyy
#		datasetIdShort			- dataset identifier in yymmdd format
#		datasetIdShortText		- dataset identifier in 'Mmm YY' format   (eg Jul 22)
#		datasetIdMediumText		- dataset identifier in 'Mmm YYYY' format (eg Jul 2022)
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
#		refDatasetIdentifier	- reference dataset ID yyyy-mm-dd
#		refDatasetIdShort		- reference dataset identifier in yymmdd format
#		refDatasetIdShortText	- reference dataset identifier in 'Mmm YY' format   (eg Jul 22)
#		refDatasetIdMediumText	- reference dataset identifier in 'Mmm YYYY' format (eg Jul 2022)
#		refDatasetDate			- Date of dataset yyyy-mm-dd
#		refDatasetYear			- Year of dataset yyyy
# 
DatasetId_Validate() {
	local datasetID="$1"
	local refDatasetID="$2"

	# Validate dataset ID
	[ $(echo ",${datasetList}," | grep -c ",${datasetID},") -eq 0 ] &&
		barfe "Invalid dataset id '${datasetID}'. Valid options are: '${datasetList}'"
		
	# Validate reference dataset ID
	[ "${refDatasetID}" != "" ] && [ $(echo ",${datasetList}," | grep -c ",${refDatasetID},") -eq 0 ] &&
		barfe "Invalid reference dataset id '${refDatasetID}'. Valid options are: '${datasetList}'"
		
	# Dataset Fields
	datasetIdentifier="${datasetID}"
	datasetDate="${datasetIdentifier}"

	datasetIdShort="${datasetIdentifier:2}"
	datasetIdShort="${datasetIdShort//-/}"
	datasetIdShortText=$(date -d "${datasetDate}" '+%b %y')
	datasetIdMediumText=$(date -d "${datasetDate}" '+%b %Y')

	datasetYear="${datasetIdentifier:0:4}"
	datasetElectionDate="2020-11-03"
	[ $(("${datasetYear}" <= 2016)) == 1 ] && datasetElectionDate="2016-11-01"
	datasetElectionYear="${datasetElectionDate:0:4}"
	
	
	# Reference Dataset Fields
	refDatasetIdentifier="${refDatasetID}"
	refDatasetDate="${refDatasetIdentifier}"
	refDatasetIdShort="${refDatasetIdentifier:2}"
	refDatasetIdShort="${refDatasetIdShort//-/}"
	refDatasetIdShortText=$(date -d "${refDatasetDate}" '+%b %y')
	refDatasetIdMediumText=$(date -d "${refDatasetDate}" '+%b %Y')
	refDatasetYear="${refDatasetIdentifier:0:4}"
	
	# Folders
	datasetReportFolder="${maudReportFolder}/${datasetIdentifier}"
	datasetImportWorkFolder="${maudWorkFolder}/qvf-${datasetIdentifier}"
	datasetLoadWorkFolder="${maudWorkFolder}/load-${datasetIdentifier}"
	datasetNetworkReportFolder="${maudNetworkReportFolder}/${datasetIdentifier}"

	# Installation
	datasetName="EntireStateVoters-${datasetIdentifier}"
	datasetFilespec="${maudStateDataFolder}/${datasetName}.csv"
	datasetChecksumFilespec="${maudStateDataFolder}/${datasetName}.cks"
	
	datasetHistoryName="EntireStateVoterHistory-${datasetIdentifier}"
	datasetHistoryFilespec="${maudStateDataFolder}/${datasetHistoryName}.csv"
	datasetHistoryChecksumFilespec="${maudStateDataFolder}/${datasetHistoryName}.cks"

	datasetPrepareQvfControl="${maudReferenceFolder}/qvf-load-prepare-control.dat"
	datasetPrepareHistoryControl="${maudReferenceFolder}/history-load-prepare-control.dat"

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
#			datastoreType		- common, specific, oir aggretage
#			datastoreSchema		- schema to use for datastore
#
Datastore_Validate() {
	local aDatastoreType="$1"
	[ $(echo ",${datastoreList}," | grep -c ",${aDatastoreType},") -eq 0 ] &&
		barfe "Invalid datastore id '${aDatastoreType}'. Valid options are: '${datastoreList}'"

	datastoreType="${aDatastoreType}"
	datastoreSchema="ma"
	refDatastoreSchema="ma"
	datastoreTitle="common"
	if [ "${datastoreType}" == "specific" ] ; then
		[ "${datasetIdShort}" == "" ] && barfe "Code error.... Dataset info not set for datastore '${datastoreType}'"
		datastoreSchema="ma${datasetIdShort}"
		datastoreTitle="Dataset ${datasetIdentifier}"
		refDatastoreSchema="ma${refDatasetIdShort}"
	fi
	if [ "${datastoreType}" == "aggregate" ] ; then
		datastoreSchema="maag"
		datastoreTitle="aggregate"
		refDatastoreSchema="maag"
	fi
}
