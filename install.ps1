$gitroot = "https://raw.githubusercontent.com/stopthatastronaut/ScheduledTaskDSC/master"
$diskroot = "c:\Program Files\windowspowershell\Modules\ScheduledTaskDSC"

if(-not (Test-Path $diskroot))
{
    mkdir $diskroot
}

if(-not (Test-Path "$diskroot\DSCResources"))
{
    mkdir "$diskroot\DSCResources"
}

if(-not (Test-Path "$diskroot\DSCResources\xScheduledTask"))
{
    mkdir "$diskroot\DSCResources\xScheduledTask"
}

iwr "$gitroot/xScheduledTask/xScheduledTask.psm1" -OutFile  "$diskroot\DSCResources\xScheduledTask\xScheduledTask.psm1" 
iwr "$gitroot/DSCResources/xScheduledTask/xScheduledTask.schema.mof" -OutFile  "$diskroot\DSCResources\xScheduledTask\xScheduledTask.schema.mof"
iwr "$gitroot/ScheduledTaskDSC.psd1" -OutFile  "$diskroot\ScheduledTaskDSC.psd1"
