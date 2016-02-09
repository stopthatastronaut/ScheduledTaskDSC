ipmo pester

$splat = @{
            "Ensure" = "Present"
            "Name" = "xScheduledTaskDSC Pester Test ScheduledTask"
            "Arguments" = " -noprofile -command `"Get-Website`""
            "Execute" = "powershell.exe"
            "At" = "9:30AM"
            "Repeat" = "Custom"
            "IntervalMinutes" = 20
            "UserName" = "SYSTEM"
          } # standard splat for tests
        
$badsplat = @{
            "Ensure" = "Present"
            "Name" = "xScheduledTaskDSC Pester Test ScheduledTask"
            "Arguments" = " -noprofile -command `"Get-Website`""
            "Execute" = "powershell.exe"
            "At" = "9:30AM"
            "Repeat" = "Custom"
            "UserName" = "SYSTEM"
            } # splat with incorrect Repeat and Interval

$removesplat  = @{
            "Ensure" = "Absent"
            "Name" = "xScheduledTaskDSC Pester Test ScheduledTask"
            "Arguments" = " -noprofile -command `"Get-Website`""
            "Execute" = "powershell.exe"
            "At" = "9:30AM"
            "Repeat" = "Custom"
            "IntervalMinutes" = 20
            "UserName" = "SYSTEM"
          } # standard splat for tests


Describe "Top level repo tests" {
    It "includes some documentation" { # not a very good test yet.
        test-Path .\en-US\About_DSCResource_xScheduledTask.help.txt | Should Be $true
    }
}

Describe "Module tests" {



    Context "With Module dot-loaded" {
    
        # Everything dot-relative to repo root
        Copy-Item .\DSCResources\xScheduledTask\xScheduledTask.psm1 $env:tmp\xScheduledTaskDSC.ps1 
        . $env:tmp\xScheduledTaskDSC.ps1 

        $tokens = $null;
        $errors = $null;
        $inputString = gc $env:tmp\xScheduledTaskDSC.ps1  -raw
        $parsedCode = [System.Management.Automation.Language.Parser]::ParseInput($inputstring, [ref]$tokens, [ref]$errors)

        It "Should have no syntax errors when parsed" {
            $errors | Should Be $null        
        }



        # get-targetresource
        Mock New-ScheduledTask {
        
        } 

        Mock Get-ScheduledTask {

        } -Verifiable

        $returnvalue = Get-TargetResource @splat 

        It "Runs the Get Mock, showing that we ARE checking for existence" {
            Assert-VerifiableMocks
        }
        
        It "Returns a hashtable" {
            $returnvalue.GetType() -eq [hashtable] | Should Be $true
        }

        It "Should fail if you specify Custom Repeat but no interval" {          
            { Get-TargetResource @badsplat } | Should Throw
        }

        # set-targetresource

    }

    Context "Let's actually create some tasks" {

    }

    Context "Running module in DSC" {
        # not implemented yet
    }

}

Describe "Testing the tests" {
    # picks up the example scripts and makes sure they do nothing bad
}