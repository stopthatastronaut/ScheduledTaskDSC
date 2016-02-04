configuration ScheduleTest
{
    Import-DscResource -ModuleName ScheduledTaskDSC

    node (hostname)
    {
        # Call Resource Provider
        # E.g: WindowsFeature, File


        xScheduledTask TestTask
        {
            Ensure = "Present"
            Name = "Test ScheduledTask"
            Arguments = " -noprofile -command `"Get-Website`""
            Execute = "powershell.exe"
            At = "9:30AM"
            Repeat = "Custom"
            IntervalMinutes = 20
            UserName = "SYSTEM"
        }       
    }
}

ScheduleTest

Start-DscConfiguration -Path .\ScheduleTest -verbose -wait -Force