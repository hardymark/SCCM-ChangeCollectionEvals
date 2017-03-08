# SCCM-ChangeCollectionEvals

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
