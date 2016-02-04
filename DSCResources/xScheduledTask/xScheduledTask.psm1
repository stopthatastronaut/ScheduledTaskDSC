<#
A simple DSC Scheduled Task resource. 
Only one Action permitted at present
Only one Trigger permitted at present

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

#>

Function Get-TargetResource
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $Name,
        [ValidateSet("Absent", "Present")]
        $Ensure,
        [string]
        [ValidateScript({
            # maybe check if the path is resolvable?
            $true # temporary
        })]
        $Execute,
        $Arguments,
        [ValidateScript({
            [datetime]$_
        })]
        $At,
        [string]
        [ValidateSet("Daily", "Weekly", "Once", "DaysOfWeek", "Hourly", "Custom")]
        $Repeat, 
        [int]
        [ValidateRange(1,1339)] # one minute to one day minus one minute
        $IntervalMinutes, # Only usable if Repeat is Custom
        $UserName = "SYSTEM", #  Always runs as a BUILTIN principal. ValidateSet should ideally allow LocalSystem, LocalService or NetworkService
        $TaskPath = "\ScheduledTaskDSC\"
    )

    $Tasks = Get-ScheduledTask -TaskPath $TaskPath | ? { $_.TaskName -eq $Name }

    if($Tasks.count -gt 0)
    {
        # task exists
        Write-Verbose "Task exists, returning Task details as hashtable"
        $ensureResult = "Present"
        $Task = $Tasks | select -first 1
        $getTargetResourceResult = @{
                                        Name = $Task.TaskName
                                        Ensure = $ensureResult
                                        Execute = $Task.Actions | select -First 1 | select -ExpandProperty Execute
                                        Arguments = $Task.Actions | select -First 1 | select -ExpandProperty Argument
                                        At = $Task.Triggers | select -first 1 | select -ExpandProperty StartBoundary 
                                        Repeat = $Task.Triggers | select -first 1 | select -ExpandProperty Repetition | select -expand Interval
                                        IntervalMinutes = $null
                                        UserName = $Task.Principal.UserId
                                        TaskPath = $TaskPath
                                    }
    }
    else
    {
        # no task exists
        $ensureResult = "Absent"
        $getTargetResourceResult = @{
                                        Name = $Name
                                        Ensure = $ensureResult
                                        Execute = $Execute
                                        Arguments = $arguments
                                        At = $At
                                        Repeat = $Repeat
                                        IntervalMinutes = $IntervalMinutes
                                        UserName = $UserName
                                        TaskPath = $TaskPath
                                    }
    }


    return $getTargetResourceResult

}

Function Test-TargetResource
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $Name,
        [ValidateSet("Absent", "Present")]
        $Ensure,
        [string]
        [ValidateScript({
            # maybe check if the path is resolvable?
            $true # temporary
        })]
        $Execute,
        $Arguments,
        [ValidateScript({
            [datetime]$_
        })]
        $At,
        [string]
        [ValidateSet("Daily", "Weekly", "Once", "DaysOfWeek", "Hourly", "Custom")]
        $Repeat, 
        [int]
        [ValidateRange(1,1339)] # one minute to one day minus one minute
        $IntervalMinutes, # Only useful if $Repeat is "Custom"
        $UserName = "SYSTEM", #  ValidateSet should ideally allow LocalSystem, LocalService or NetworkService
        $TaskPath = "\ScheduledTaskDSC\"
    )

    Write-Verbose "Running Test-TargetResource now"

    if(($Repeat -eq "Custom") -and ($IntervalMinutes -eq "" -or $IntervalMinutes -eq "")) {
        throw "`r`nIf using Custom Repetition, you must supply the `$intervalMinutes parameter"
    }

    $Task = Get-TargetResource  -Name $Name `
                                -Ensure $Ensure `
                                -Execute $execute `
                                -Arguments $Arguments `
                                -at $at `
                                -Repeat $Repeat `
                                -IntervalMinutes $IntervalMinutes `
                                -UserName $UserName `
                                -Verbose

    $taskOK = $true # assume it's OK

    $taskName = $Task.Name

    Write-Verbose "Examining Task name $Name ($TaskName)"

    if($ensure -eq $Task.Ensure -and 
        $Execute -eq $Task.Execute -and 
        $Arguments -eq $Task.Arguments
      )
    {
        # things match, to the extent that we're checking them. no worries, McFlurries.

        Write-Verbose "Test-TargetResource has detected no drift"
    }
    else
    {
        
        Write-Verbose "Test-TargetResource has detected variance from desired state"

        Write-Verbose "Execute requested: $Execute "
        Write-Verbose "Execute in service: ${Task.Execute} "

        Write-Verbose "Ensure requested: $Ensure "
        Write-Verbose "Ensure in service: ${Task.Ensure} "

        Write-Verbose "Arguments requested: $arguments"
        Write-Verbose "Arguments in service"

        $TaskOK = $false # it either exists when it shouldn't, or it doesn't exist when it should
                         # return false here and let Set-TargetResource do its job
    }

    return $taskOK
}

Function Set-TargetResource
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $Name,
        [ValidateSet("Absent", "Present")]
        $Ensure,
        [string]
        [ValidateScript({
            # maybe check if the path is resolvable?
            $true # temporary
        })]
        $Execute,
        $Arguments,
        [ValidateScript({
            [datetime]$_
        })]
        $At,
        [string]
        [ValidateSet("Daily", "Weekly", "Once", "DaysOfWeek", "Hourly", "Custom")]
        $Repeat, 
        [int]
        [ValidateRange(1,1339)] # one minute to one day minus one minute
        $IntervalMinutes, # Only usable if Repeat is Custom
        $UserName = "SYSTEM", #  Always runs as a BUILTIN principal. ValidateSet should ideally allow LocalSystem, LocalService or NetworkService
        $TaskPath = "\ScheduledTaskDSC\"
    )

    Write-Verbose "Running Set-TargetResource"

    if($Ensure -eq "Present")
    {
        # we're trying to either create or rectify the task. Check if it exists. If it exists, remove.
        # then recreate.
        # very brute force, but expressionist painting this is not
        # you DO lose history this way, but since this resource is designed for Autoscaling Cloud environments...
        # in a CD pipeline, we frankly don't care.
        # it will be better to remove all actions and triggers, and retain the task, maybe. Future addition

        if((Get-ScheduledTask | ? {$_.TaskName -eq $Name} | measure | select -expand Count) -gt 0)
        {
            Write-Verbose "Task exists and must be updated, therefore deleting old and creating new"
            Unregister-ScheduledTask -TaskName $Name


            # here, you'll update triggers and actions, while preserving the Task (for logging etc). Future code.
        }

        # create the task now

        $trigger = $null

        switch($Repeat)
        {
            "Daily" {
                $trigger = New-ScheduledTaskTrigger -At $At -Daily
            }
            "Weekly" {
                $trigger = New-ScheduledTaskTrigger -At $At -Weekly
            }
            "DaysOfWeek" {
                $trigger = New-ScheduledTaskTrigger -At $At -DaysOfWeek
            }
            "Once" {
                $trigger = New-ScheduledTaskTrigger -At $At -Once
            }
            "Hourly" {
                $trigger = New-ScheduledTaskTrigger -At $At `
                                                    -RepetitionInterval (New-TimeSpan -Hours 1) `
                                                    -RepetitionDuration ([timespan]::MaxValue) `
                                                    -Once # [timespan]::MaxValue disables the expiry of repetitions
                #$trigger.RepetitionDuration = $null
            }
            "Custom" {
                $trigger = New-ScheduledTaskTrigger -At $At `
                                                    -RepetitionInterval (New-TimeSpan -Minutes $intervalMinutes) `
                                                    -RepetitionDuration ([timespan]::MaxValue) `
                                                    -Once 
                #$trigger.RepetitionDuration = $null
            }
            Default { #also once 
                $trigger = New-ScheduledTaskTrigger -At $At -Once 
            }
        }

        $action = New-ScheduledTaskAction -Execute $Execute -Argument $Arguments -Verbose

        $settings = New-ScheduledTaskSettingsSet -Verbose 

        Register-ScheduledTask  -TaskName $name `
                                -User $UserName `
                                -Action $action `
                                -Trigger $trigger `
                                -Settings $settings `
                                -Description "Added by DSC" `
                                -TaskPath "\ScheduledTaskDSC\" `
                                -RunLevel 1 `
                                -Verbose 
                                

    }
    else
    {
        # delete the thing, I guess
        Unregister-ScheduledTask -TaskName $Name
    }
}