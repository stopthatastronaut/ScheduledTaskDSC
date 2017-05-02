if(-not (Test-Path "c:\Program Files\windowspowershell\Modules\ScheduledTaskDSC"))
{
    mkdir "c:\Program Files\windowspowershell\Modules\ScheduledTaskDSC"
}

if(-not (Test-Path "c:\Program Files\windowspowershell\Modules\ScheduledTaskDSC\DSCResources"))
{
    mkdir "c:\Program Files\windowspowershell\Modules\ScheduledTaskDSC\DSCResources"
}

if(-not (Test-Path "c:\Program Files\windowspowershell\Modules\ScheduledTaskDSC\DSCResources\xScheduledTask"))
{
    mkdir "c:\Program Files\windowspowershell\Modules\ScheduledTaskDSC\DSCResources\xScheduledTask"
}

iwr https://raw.githubusercontent.com/stopthatastronaut/ScheduledTaskDSC/master/DSCResources/xScheduledTask/xScheduledTask.psm1 -OutFile  "c:\Program Files\windowspowershell\Modules\ScheduledTaskDSC\DSCResources\xScheduledTask\xScheduledTask.psm1"
iwr https://raw.githubusercontent.com/stopthatastronaut/ScheduledTaskDSC/master/DSCResources/xScheduledTask/xScheduledTask.schema.mof -OutFile  "c:\Program Files\windowspowershell\Modules\ScheduledTaskDSC\DSCResources\xScheduledTask\xScheduledTask.schema.mof"
iwr https://raw.githubusercontent.com/stopthatastronaut/ScheduledTaskDSC/master/ScheduledTaskDSC.psd1 -OutFile  "c:\Program Files\windowspowershell\Modules\ScheduledTaskDSC\ScheduledTaskDSC.psd1"
