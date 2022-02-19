#
# goon-drive-api.py
#	
#	Description:
#
#       Google Drive API Class
#
#	Usage:
#
#       from .lib.goon-drive-api import DriveAPI
#       
#	Copyright:
#		Copyright (c) 2022, F. Kurt Schulte - All rights reserved.  No use without written authorization.
#
#	History:
#		Date		Version		Author			Desc
#		2022.02.05	01.00		FKSchulte		Original Version
#

import io
import os
import pickle
import re
import requests
import shutil
import sys

import os.path

from datetime import datetime
from mimetypes import MimeTypes

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaIoBaseDownload, MediaFileUpload
#from google.cloud import storage

# If modifying these scopes, delete the file token.json.
SCOPES  =   ['https://www.googleapis.com/auth/drive.metadata.readonly']

#
#   Constants
#
k_readBlockSize             = 1024 * 1024
k_progressInterval          = 100

#
#   Google Drive API Class
#
class DriveAPI:
    global SCOPES
      
    # Define the scopes
    SCOPES = ['https://www.googleapis.com/auth/drive']
  
    def __init__(self,optCredentials,optPickle,optDebug=False,optLogfile=""):
        
        self.opt_credentials    = optCredentials
        self.opt_pickle         = optPickle
        self.opt_debug          = optDebug
        self.opt_logfile        = optLogfile
        
        # Variable self.creds will store the user access token.
        # If no valid token found create one.
        self.creds = None
  
        # The file token.pickle stores the user's access and refresh
        # tokens. It is created automatically when the authorization
        # flow completes for the first time.
  
        # Check if file token.pickle exists
        if os.path.exists(optPickle):
  
            # Read the token from the file and store
            # it in the variable self.creds
            with open(optPickle, 'rb') as token:
                self.creds = pickle.load(token)
  
        # If no valid credentials are available, 
        # request the user to log in.
        if not self.creds or not self.creds.valid:
  
            # If token is expired, it will be refreshed,
            # else, we will request a new one.
            #
            if self.creds and self.creds.expired and self.creds.refresh_token:
                # If token is expired, refesh will get this error...
                #   google.auth.exceptions.RefreshError: ('invalid_grant: Token has been expired or revoked.', {'error': 'invalid_grant', 'error_description': 'Token has been expired or revoked.'})
                self.creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(optCredentials, SCOPES)
                self.creds = flow.run_local_server(port=0)
  
            # Save the access token in token.pickle
            # file for future usage
            with open(optPickle, 'wb') as token:
                pickle.dump(self.creds, token)
  
        # Connect to the API service
        self.barfd("DriveAPI.DriveServiceCreate...")
        self.service = build('drive', 'v3', credentials=self.creds)
        self.barfd("DriveAPI.DriveServiceCreate successful.")
  
    def FilesList(self):
        # request a list of first N files or folders with name
        # and id from the API.
        results = self.service.files().list(
            pageSize=100, fields="files(id, name)").execute()
        items = results.get('files', [])
        return items

    def FilesPrint(self):
        # request a list of first N files or folders with name
        # and id from the API.
        self.barfd("DriveAPI.DriveFilesPrint...")
        results = self.service.files().list(
            pageSize=100, fields="files(id, name)").execute()
        items = results.get('files', [])
  
        # print a list of files
        if self.opt_debug:
            print("GoonDriveAPI: Here's a list of files: \n")
            print(*items, sep="\n", end="\n\n")

        self.barfd("DriveAPI.DriveFilesPrint done.")

    def FileDownload(self, file_id, file_name):
        request = self.service.files().get_media(fileId=file_id)
        fh = io.BytesIO()

        self.barfs(f"FileDownload (file_id='{file_id}',file_name='{file_name}')...")

        # Initialise a downloader object to download the file
        downloader = MediaIoBaseDownload(fh, request, chunksize=k_readBlockSize)
        done = False
  
        try:
            # Download the data in chunks
            chunkNo = 0
            while not done:
                chunkNo += 1
                #self.barfs(f"Read chunk {chunkNo}")
                status, done = downloader.next_chunk()
                if chunkNo % k_progressInterval == 0:
                    bytesRead   = k_readBlockSize * chunkNo
                    humanRead   = self.ByteCountHumanized(bytesRead)
                    self.barfs(f"Progress: at chunk {chunkNo}, {humanRead} downloaded, continuing...")
  
            fh.seek(0)

            # Write the received data to the file
            with open(file_name, 'wb') as f:
                shutil.copyfileobj(fh, f)
  
            bytesRead   = k_readBlockSize * chunkNo           # estimate
            humanRead   = self.ByteCountHumanized(bytesRead)
            self.barfs(f"File Downloaded, {humanRead} stored.")
            # Return True if file Downloaded successfully
            return True
        except:
            
            # Return False if something went wrong
            self.barfs("GoonDriveAPI.Error: Something went wrong.")
            return False
  
    def FileUpload(self, filepath):
        
        # Extract the file name out of the file path
        name = filepath.split('/')[-1]
          
        # Find the MimeType of the file
        mimetype = MimeTypes().guess_type(name)[0]
          
        # create file metadata
        file_metadata = {'name': name}
  
        try:
            media = MediaFileUpload(filepath, mimetype=mimetype)
              
            # Create a new file in the Drive storage
            file = self.service.files().create(
                body=file_metadata, media_body=media, fields='id').execute()
              
            self.barfs("GoonDriveAPI: File Uploaded.")
          
        except:
              
            # Raise UploadError if file is not uploaded.
            raise UploadError("GoonDriveAPI: Can't Upload File.")

    def ByteCountHumanized(self,byteCount):

        mbCount      = byteCount / ( 1024 ** 2 )
        gbCount      = byteCount / ( 1024 ** 3 )

        humanRead   = "{:.2f} MB".format(mbCount)
        if gbCount > 1.0:
            humanRead   = "{:.2f} GB".format(gbCount)
            
        return humanRead
    
    def currentTS(self):
        currDT  = datetime.now()
        tsFormat    = "{:04d}.{:02d}.{:02d}.{:02d}.{:02d}.{:02d}"
        currTS  = tsFormat.format(currDT.year,currDT.month,currDT.day,currDT.hour,currDT.minute,currDT.second)
        return currTS

    def barfs(self,aText):
        currTS  = self.currentTS()
        outText = f"{currTS}: {aText}"
        print(outText)
        self.barfl(outText)

    def barfd(self,aText):
        if self.opt_debug:
            self.barfs(f"PYDEBUG; {aText}")

    def barfl(self,aText):
        if self.opt_logfile and self.opt_logfile != "":
            logfile = open(self.opt_logfile,'a', encoding='latin_1')
            logfile.write(f"{aText}\n")
            logfile.close()
