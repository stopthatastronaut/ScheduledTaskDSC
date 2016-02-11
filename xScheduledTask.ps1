configuration ScheduleTest
{
    Import-DscResource -ModuleName ScheduledTaskDSC

    node (hostname)
    {
        xScheduledTask TestTask
        {
            Ensure = "Present"
            Name = "Test ScheduledTask"
            Arguments = " -command `"Get-Date`""
            Execute = "powershell.exe"
            At = "9:30AM"
            Repeat = "Daily"
            IntervalMinutes = 1
            UserName = "SYSTEM"
        }
    }
}

ScheduleTest

Start-DscConfiguration -Path .\ScheduleTest -verbose -wait -Force

# Get-Process wmiprvse | kill -force # use this if you need to refresh the config