#!/usr/bin/env python3
import re
import os
import sys
import zipfile
import shutil
from zipfile import ZipFile
from datetime import datetime,date,timedelta
 
serverPattern = '(r|R|g|G)(p|P|b|B|t|T|d|D|v|V).*-'
 
ipPattern = '\d{1,3}\.\d{1,3}(?=\.\d{1,3}\.\d{1,3})'
 
ipvSix = '(([a-fA-F0-9:]+:+)+[a-fA-F0-9]+)(?=(:([a-fA-F0-9:]+:+)+[a-fA-F0-9]+))'
 
domainPattern = 'ent\.usstratcom\.mil'
 
org1 = 'usstratcom'
org2 = 'ent'
org3 = 'mil'
org4 = 'stratcom'
 
ou = 'OU=.*?\,'
cn = 'CN=.*?\,'
 
devName = 'dev\.[a-zA-Z0-9]{1,24}'
 
fileExt = '\.[^\.]{1,}$'
 
namePattern = '^(.*?)<'
 
userName = (re.findall(namePattern, sys.argv[1]))[0].replace(" ","-")
 
now = datetime.now() - timedelta(hours=5)
current_time = now.strftime("%H%M")
today = date.today()
 
files = [b for b in os.listdir('.') if os.path.isfile(b)]
 
for f in files:
 
    if f != 'scrubber.py' and f != 'README.md' and f != '.gitlab-ci.yml' and f!= 'output':
 
        ext = re.findall(fileExt,f)
 
        if len(ext)==0:
            ext.append(".txt")
 
        outName = userName+today.strftime("%Y%m%d")+"-"+current_time+ext[0]
 
        if ext[0] == ".zip":
            z = zipfile.ZipFile(f)
            z.extractall("tmp")
            tmpdir = os.path.realpath("tmp")
            newZip = ZipFile(outName, 'w')
            for subdir, dirs, files in os.walk(tmpdir):
                for file in files:
                    with open(f,"r+") as inputF:
                        lines = inputF.read()
                        output = re.sub(serverPattern,'SERVER',lines)
                        output = re.sub(ipPattern,'XXX.XXX',output)
                        output = re.sub(ipvSix,'XXXX:XXXX:XXXX:XXXX:XXXX:XXXX',output)
                        output = re.sub(domainPattern,'domain.com',output)
                        output = re.sub(cn,'CN=common-name,',output)
                        output = re.sub(ou,'OU=domain-object,',output)
                        output = re.sub(org1,'org',output)
                        output = re.sub(org2,'org',output)
                        output = re.sub(org3,'org',output)
                        output = re.sub(org4,'org',output)
                        output = re.sub(devName,'UserAccount',output)
                        inputF.seek(0)
                        inputF.write(output)
                        inputF.truncate()
                        inputF.close()
                    newZip.write(os.path.join(subdir,file),os.path.relpath(os.path.join(subdir,file),os.path.join(tmpdir, '..')))
            shutil.rmtree(tmpdir)
        else:
            with open(f) as inputF:
               
                lines = inputF.read()
 
                output = re.sub(serverPattern,'SERVER',lines)
                output = re.sub(ipPattern,'XXX.XXX',output)
                output = re.sub(ipvSix,'XXXX:XXXX:XXXX:XXXX:XXXX:XXXX',output)
                output = re.sub(domainPattern,'domain.com',output)
                output = re.sub(cn,'CN=common-name,',output)
                output = re.sub(ou,'CN=domain-object',output)
                output = re.sub(org1,'org',output)
                output = re.sub(org2,'org',output)
                output = re.sub(org3,'org',output)
                output = re.sub(org4,'org',output)
                output = re.sub(devName,'UserAccount',output)
               
                outputFile = open(outName, "w")
                outputFile.write(output)
                outputFile.close()
               
                inputF.close()
