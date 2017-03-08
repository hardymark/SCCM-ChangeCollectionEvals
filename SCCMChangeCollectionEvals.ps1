<#  
Script name: SCCMChangeCollectionEvals.ps1
Script Ver : 1.0
Script home: https://github.com/hardymark

This script is the fast solution to an SCCM environment with too many collections set
to Incremental Evaluation enabled. The script reads a list of collections with schedule
codes in one CSV, reads a list of available schedules with schedule codes from another 
CSV, and modifies the settings on each collection to turn off the Incremental Updates
checkbox, turn on Full Updates, and set a full update schedule according to your
choices in the CSV files.

Required file: Collections.csv 
    Contains two columns, CollectionID and Option. Option is an arbitrary code used
    to cross-reference against available schedules in Schedules.csv

Required file: Schedules.csv
    Contains columns
        Option	              Must match the Option code used in Collections.csv
        Type	              Daily in the only supported value here right now
        RecurCount		      Count of days in recurrence (3 equals every 3 days)
        DayofWeek		      Not used, intended to support Weekly type
        Start	              Date and Time to start the schedule. Date/time format.

Required changes to Script for your environment:
    See lines for variables under section "*** MODIFY LINES BELOW TO CUSTOMIZE FOR YOUR SITE ***"
        $SiteCode	          Three letter site code for your SCCM Site
        $SiteServer	          Full computer name for your SCCM Site Server
        $CollectionChanges    Import-CSV command to full path for collections.csv required file
        $Schedules            Import-CSV command to full path for schedules.csv required file


Written/cobbled together by: 
            Mark Hardy
            mark.hardy@compucom.com
            (310) 871-2493
            @hardymark

Includes Powershell code from: How to Disable incremental Updates script
            Michael Olson
            https://gallery.technet.microsoft.com/scriptcenter/Powershell-How-to-Disable-0c1c20ce

Includes Powershell code from: How to Change Collection Full Update Schedule in Mass script
            Michael Olson
            https://gallery.technet.microsoft.com/scriptcenter/Powershell-How-to-Change-2803470c

#>

Function CreateScheduleToken
{
param ($dayspan = 1, $starttime = (WMIDateFormat))
    $WMIPathToClass = "SMS_ST_RecurInterval"
    $WMIPathToClass = "$SiteWMIPath$WMIPathToClass"


$intervalClass = [WMICLASS]("$WMIPathToClass")
$interval = $intervalClass.CreateInstance()
$interval.dayspan = $dayspan
$interval.starttime = $starttime
return $interval
}



#formats the date/time value to be SCCM friendly
Function WMIDateFormat
{
param($hour = (get-date -format HH), $min = (get-date -format mm), $sec = (get-date -format ss), $date = (get-date))
get-date -hour $hour -minute $min -second $sec -day $date.day -month $date.month -year $date.year -format yyyyMMddHHmmss.000000+***
}



## Import ConfigMgr PS Module 
Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"


## *** MODIFY LINES BELOW TO CUSTOMIZE FOR YOUR SITE ***
## Connect to ConfigMgr Site 
$SiteCode = 'CM1'
$SiteServer = "SERVERNAME"
## Read list of collections to modify from text file
$CollectionChanges = Import-Csv 'c:\FilePath\collections.csv'
## Read list of available schedules that cross reference to the CollectionsChanges list
$Schedules = Import-Csv 'c:\FilePath\schedules.csv'



$SiteWMIPath = "\\$SiteServer\root\sms\site_${SiteCode}:"
$SiteLocation = "${SiteCode}:"
Set-Location $SiteLocation
Set-CMQueryResultMaximum 100000




## Get all the collections in the site
$AllCMCollections = Get-CMCollection 



## Loop through the collections in the text file
for ($i=0; $i -lt $CollectionChanges.length; $i++) {
    $CollID = $CollectionChanges[$i].CollectionID
    $Option = $CollectionChanges[$i].Option
    $ThisSchedule = $Schedules |Where-Object {$_.Option -eq $Option}

    
    ## Modify the schedule for the collection
   
    $ChangeTime = [datetime]$ThisSchedule.Start

    $starttime       = (WMIDateFormat $ChangeTime.Hour $ChangeTime.Minute $ChangeTime.Second $ChangeTime.date)


    $WMIPathToColl = "SMS_Collection.CollectionID='$CollID'"
    $WMIPathToColl = "$SiteWMIPath$WMIPathToColl"
    $coll = [wmi]"$WMIPathToColl"
    $coll.RefreshSchedule = CreateScheduleToken $ThisSchedule.RecurCount $starttime
    $coll.RefreshType = 2
    $coll.psbase
    $coll.Put()


}



