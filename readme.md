# README #

I needed to manage scheduled tasks in OctopusDeploy projects. DSC seemed ideal for my purposes.

However, I couldn't find a pre-existing DSC resource to manage Scheduled Tasks on Windows, so I made one. 

### What is this repository for? ###

An open DSC resource for managing simple scheduled task in Windows. It'll become more complete and complex over time, but for now it:

- Creates new tasks
- Removes unwanted tasks
- Deletes and recreates them if their actions change

### Detailed Setup ###

You will of course need PowerShell v4 and any Desired State Configuration Updates that apply to your system

Tested so far on Windows 8, Server 2012 and 2012 R2. Backward compat is for future testing.

### FAQ ###

Nobody's asked questions yet, so here's a socratic dialogue with an imaginary user/contributor

1. Why has it got an 'x' in the name?
A. This is in line with Microsoft's Guidelines for community DSC resources, and aims to prevent collisions with future "official" DSC resources

2. Can I have multiple actions in one Task using xScheduledTask?
A. No, not right now you can't. Do what we used to do back in the old days. Put your multiple actions in a .ps1 or batch file and schedule that instead

3. Can I have multiple triggers on a single task?
A. No, not yet. In the spirit of Answer #2, make multiple tasks instead. This is for simple tasks, not complex rules-based business-logic-bound shenanigans

4. Can I contribute?
A. Why yes you can. Either in code or in beer, I don't care. As long as it's nice beer.

### Example ###

```
configuration ScheduleTest
{
    Import-DscResource -ModuleName ScheduledTaskDSC
    node (hostname)
    {
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
```