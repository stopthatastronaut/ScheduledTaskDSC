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

$client = [System.Net.WebClient]::new()  # can't just invoke-webrequest, due to double-byte chars in github

$client.DownloadString("$gitroot/DSCResources/xScheduledTask/xScheduledTask.psm1") | Out-File  "$diskroot\DSCResources\xScheduledTask\xScheduledTask.psm1" 
$client.DownloadString("$gitroot/DSCResources/xScheduledTask/xScheduledTask.schema.mof") | Out-File  "$diskroot\DSCResources\xScheduledTask\xScheduledTask.schema.mof"
$client.DownloadString("$gitroot/ScheduledTaskDSC.psd1") | Out-File "$diskroot\ScheduledTaskDSC.psd1"
