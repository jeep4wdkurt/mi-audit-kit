#
# fetch.py
#	
#	Description:
#
#       Utility to fetch a file from a Goon folder share
#
#	Usage:
#       python3 --googleid "<goon-id>" \
#               --credentials "<goon-json-credentials-file>" \
#               --output "<output-file>"
#               [--logfile <logfile>]           Log file specification
#               [--log]                         Turn on logging, use default log file if none specified
#
#   Security:
#       API Deashboard: https://console.cloud.google.com/apis/dashboard?authuser=1&project=maude-339514
#
#       Note that OAuth cert is set to no expire, but if cert is not used for 6 months
#           it will be auto-expired. Remediate by going to auth page and re-saving
#           credentials info to refresh.
#
#	Copyright:
#		Copyright (c) 2022, F. Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#		Date		Version		Author			Desc
#		2022.01.27	01.00		FKSchulte		Original Version
#
progName='fetch.py'

import argparse
import csv
import io
import os
import pickle
import re
import requests
import shutil
import sys

import os.path

from datetime import datetime

from goon_drive_api import DriveAPI

# If modifying these scopes, delete the file token.json.
SCOPES  =   ['https://www.googleapis.com/auth/drive.metadata.readonly']

#
#   Folders
#
maudPythonFolder            = os.getenv('kitPythonFolder','')
maudCertsFolder             = os.getenv('kitCertsFolder','')
maudLogFolder               = os.getenv('maudLogFolder','')
maudUserCertsFolder         = os.getenv('maudLocalCertsFolder','')
maudUserGoonCert            = os.getenv('maudUserGoonCert','')
logfolderDefault            = maudLogFolder if maudLogFolder != '' else '.'

#
#   Constants
#
k_maud_folder_perms         = os.getenv('maudFolderPerms',741)

k_googleApiKeyMaudelib001   = 'AIzaSyChny6NNLWjfwHkV-_SsAOlv9G4yPcAdy4'
#k_googleFileMaudelib001a    = '1IHbfILNzCPYy7Bmvi51BxB7I9WRsm5Du'

k_googleOAuthClientId       = '1017086664236-q1h512v67o9lbksk756q9lnjotdb720m.apps.googleusercontent.com'    # NOT USED - now in certs/maudelib_credentials.json
k_googleOAuthClientSecret   = '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'                                          # NOT USED - now in certs/maudelib_credentials.json

k_pickleFile                = 'token.pickle'

#
#   Command Line Data
# 
optUrl              = None
optOutput           = None
optLogfile          = None
optLog              = False
optLogAppend        = False
optStdOut           = False
optDebug            = False
optVerbose          = False
optCredentials      = None
optPickle           = None

#
#  Driving Data
#

#
#   Time Routines
#
def currentTS():
    currDT  = datetime.now()
    tsFormat    = "{:04d}.{:02d}.{:02d}-{:02d}.{:02d}.{:02d}"
    currTS  = tsFormat.format(currDT.year,currDT.month,currDT.day,currDT.hour,currDT.minute,currDT.second)
    return currTS
    
def lognameTS():
    currDT  = datetime.now()
    tsFormat    = "{:04d}.{:02d}.{:02d}-{:02d}.{:02d}.{:02d}"
    logTS  = tsFormat.format(currDT.year,currDT.month,currDT.day,currDT.hour,currDT.minute,currDT.second)
    return logTS

#
#   I/O Routines
#
def barf(text):
    global optLog

    print(text)
    if optLog:
        barfl(text)
    
def barfl(text):
    global optLogfile

    logchan = open(optLogfile,'a', encoding='latin_1')
    
    tsPattern    = re.compile(r'^[0-9]{4}[.][0-9]{2}[.][0-9]{2}[-][0-9]{2}[.][0-9]{2}.*')
    tsMatch      = tsPattern.match(text)
    
    logTS       = f"{currentTS()}: "      if not tsMatch else ''
    outText     = f"{logTS}{text}\n"
    
    logchan.write(outText)

    logchan.close()

def barfs(aText):
    currTS  = currentTS()
    if not optStdOut or optDebug:
        barf(f"{currTS}: {aText}")
        
def barfe(text):
    barf(text)
    sys.exit(1)
    
def barfd(text):
    if optDebug:
        currTS  = currentTS()
        barf(f"{currTS}: PYDEBUG; {text}")

def barfv(text):
    if optVerbose:
        barf(text)

def log_initialize(logfile,logappend):

    global optLogfile
    
    # Determine log file name
    logfileDefault  = "{:s}/{:s}.{:s}.log".format(logfolderDefault,progName,lognameTS())
    optLogfile      = logfile  if logfile else logfileDefault
    optLogfile      = optLogfile.replace('"','')
    
    # Create log file folder if needed
    folderNamePattern   = re.compile(r'^(.*/)([^/]*)$')
    folderNameMatch     = folderNamePattern.match(optLogfile)
    optLogfolder    = folderNameMatch.group(1)
    if not os.path.isdir(optLogfolder):
        print(f"Creating log folder '{optLogfolder}'")
        os.makedirs(optLogfolder)
        
    # Start new log
    #print(f"Initializing log file '{optLogfile}'")
    logOpenMode = 'a'  if logappend else 'w'
    if not logappend:
        logchan = open(optLogfile,logOpenMode, encoding='latin_1')
        logchan.close()

    # Announce start of new log
    barfl(f"{progName} starting...")

#
#  Command Line Arguments
#
def command_args_get():

    global optOutput
    global optLogfile
    global optLog
    global optLogAppend
    global optStdOut
    global optGoogleId
    global optCredentials
    global optPickle
#    global optProgressInterval
    global optDebug
    global optVerbose

    # Create a parser object, define arguments, and do parsing of command line data
    parser = argparse.ArgumentParser()
    parser.add_argument("-G", "--googleid",     type=str,   help="Google file id")
    parser.add_argument("-O", "--output",       type=str,   help="Output file")
    parser.add_argument("-C", "--credentials",  type=str,   help="Credentials file")
#   parser.add_argument("-p", "--progress",     type=int,   help="report progress every N lines")
    parser.add_argument("-L", "--logfile",      type=str,   help="Log file")
    parser.add_argument("-l", "--log",          action="store_true", help="Enable logging, use default log file")
    parser.add_argument("-a", "--logappend",    action="store_true", help="Append to specified log")
    parser.add_argument("-v", "--verbose",      action="store_true", help="enable verbose info")
    parser.add_argument("-d", "--debug",        action="store_true", help="enable debug info")
    args = parser.parse_args()

    # Set debug and verbose flags
    optDebug    = args.debug
    optVerbose  = args.verbose
    if optDebug:
        optVerbose  = True

    # Initialize Logging, if needed
    optLog          = True          if args.log or args.logfile else False
    optLogAppend    = True          if args.logappend else False
    if optLog:
        optLogfile  = args.logfile
        log_initialize(optLogfile,optLogAppend)
    
    # Validate Googld File ID
    optGoogleId = args.googleid
    if not args.googleid:
        barfe(f"Error. --googleid option is required.")

    # Validate Output
    optOutput   = args.output
    if not args.output:
        optOutput   = '/dev/stdout'
        optStdOut   = True

    # Validate Credentials
    if not optCredentials:
        optCredentials  = maudUserGoonCert
    
    if not os.path.exists(optCredentials):
        barfe(f"Error. --credentials file '{optCredentials}' does not exist")

    # Validate Pickle 
    if not optPickle:
        homeFolder  = os.getenv('HOME')
        optPickle   = homeFolder + '/' + k_pickleFile

    barfd(f"optGoogleId = {optGoogleId}")
    barfd(f"optCredentials = {optCredentials}")
    barfd(f"optPickle = {optPickle}")

#
# MAIN
#
if __name__ == "__main__":
    command_args_get() 
    
    exitCode    = 0
    
    obj = DriveAPI(optCredentials,optPickle,optDebug,optLogfile)

    # Test Goon API
#    if optDebug:
 #       obj.FilesPrint()

    # Fetch File from Goon Repository
    downloadResult = obj.FileDownload(optGoogleId, optOutput)
    if not downloadResult:
        exitCode = 1

    sys.exit(exitCode)
