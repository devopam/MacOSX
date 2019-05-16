#!/bin/bash
#set -x
####################################################################################### 
#Script to check if specific features are installed and operational
#Developed by        : Devopam 
#Initial Version     : 1.1
#Release Date        : 13 May, 2019
####################################################################################### 

#Global vars
flag=0
fqdn=`hostname`;localName=`basename $fqdn .local`
userName=`whoami`
counter=0

#Functions
#1 : Check if FileVault is enabled 
filevaultStatus=''
fileVaultCheck()
{
    filevaultStatus=`fdesetup status`
    if [[ $filevaultStatus =~ .*"FileVault is On".* ]]; then
        echo $filevaultStatus
    else 
        echo "Filevault isn't turned ON in your machine. Please change it through System Preferences -> Security & Privacy -> FileVault pane"
        flag=1
    fi    
}

#2 : Check if Firewall is enabled
firewallStatus=''
firewallCheck()
{
    firewallStatus=`/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate`
    if [[ $firewallStatus =~ .*"Firewall is enabled".* ]]; then
        echo $firewallStatus
    else
        echo  "Firewall isn't turned ON in your machine. Please change it through System Preferences -> Security & Privacy -> Firewall pane"   
        flag=1
    fi
}

#3 : Check if Screensave is enabled
screensaverStatus=''
screenSaverCheck()
{
	idleTime=`defaults -currentHost read com.apple.screensaver 'idleTime'`
	if [ $idleTime -gt 500 ]; then
		screensaverStatus=' ScreenSaver is set to higher than 5 minutes. Please change it through System Preferences -> Desktop & ScreenSaver pane'
		flag=1
	else 
	    screensaverStatus=' ScreenSaver is set with default lockout of '$idleTime' seconds. System is compliant'
	fi
	echo $screensaverStatus
}

# Spacer ( for printing an incremental number and a newline
spacer()
{
    echo; ((counter++)); echo $counter
}

#4 : Check if FileSharing is disabled
filesharingStatus=''
fileSharingDisabledCheck()
{
    currentStatus=`cat /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist | strings`
    if [ `echo $currentStatus|grep -e "'<key>Disabled</key>' '<true/>'"` ]; then
        filesharingStatus=' File Sharing is turned ON in your machine, in violation of policy. Please disable it through System Preferences -> Sharing pane'
        flag=1
    else
        filesharingStatus=' File Sharing is disabled.
    fi
    echo $filesharingStatus
}

#5 : See if Time Machine based backup on private hard disk is disabled
timemachineStatus=''
timeMachineDisabledCheck()
{
    tmstatus=`tmutil listbackups > /dev/null 2>&1`
    if [ `echo $tmstatus| grep -e "No machine directory found for host."` ] ; then
        timemachineStatus=' Time Machine backup detected possibly on external hard disk. Please immediately contact LTI-IT team to cleanup system.'
        flag=1
    else
        timemachineStatus=' Time Machine backup is disabled.'
    fi
    echo $timemachineStatus        
}
####################################################################################### 
#main program
echo $'........System Check in progress. Please do not interrupt ........\n'
echo 'Machine Name: '$localName' User Name: '$userName

spacer
fileVaultCheck
spacer
firewallCheck
spacer
screenSaverCheck
spacer
fileSharingDisabledCheck
spacer
timeMachineDisabledCheck


#Add more validation functionalities here and the corresponding function above. spacer is only for numbering and formatting.

if [ $flag -ne 0 ]; then
    echo $'\n........One or the other validations failed for your machine. Please fix the same and re-run the validation script........'
else
    echo $'\n........Validations completed. Machine is found complaint for checks mentioned above........'
fi
exit 0
