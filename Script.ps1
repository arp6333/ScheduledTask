<#
  .SYNOPSIS
    This script will create a scheduled task or an 
    automatic task.
  .DESCRIPTION
    Scheduled: Sets UAC Level to 2 every minute. To 
    remove the scheduled task, go into Task
    Scheduler and remove the task named "UACLevel".

    Automatic: Sets UAC Level everytime it is modified
    by another task. To remove the scheduled task, go into 
    Task Scheduler and remove the task named "UACLevelAuto".
  #>

#Stores Script's Current Location
$sCurrDir = $myinvocation.mycommand.path
$sCurrDir = $sCurrDir.Replace("\" + $myinvocation.MyCommand, "")

#Controls Script Actions
function Start-Main{
    Create-AutoTask
}

#Creates Scheduled Task
function Create-ScheduledTask{
    #Creates Scheduled Task Actions
    $TaskAction1 = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass -noprofile -command ""&{ start-process powershell -ArgumentList '-noprofile -file $sCurrDir\UACLevel.ps1' -verb RunAs}"""
            
    #Assigns Username
    $TaskUsername = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    #Creates Scheduled Task Settings
    $TaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries

    #Creates Triggers
    $TaskTrigger  = New-ScheduledTaskTrigger -AtLogOn
            
    #Create Scheduled Task
    $Task = New-ScheduledTask -Action $TaskAction1 -Principal $TaskUsername -Trigger $TaskTrigger -Settings $TaskSettings
        
    #Register Scheduled Task
    Register-ScheduledTask "UACLevel" -InputObject $Task -Force

    #Configure Scheduled Task
    $Task = Get-ScheduledTask -TaskName "UACLevel"
    #Omit Duration for infinite duration
    #$Task.Triggers.Repetition.Duration = "P1D"
    #Interval to repeat task (60M = 1 hour)
    $Task.Triggers.Repetition.Interval = "PT1M"

    #Update Scheduled Task
    $Task | Set-ScheduledTask -User "NT AUTHORITY\SYSTEM"
}

#Creates Automatic Task
function Create-AutoTask{
    $taskName = "UACLevelAuto"
    $Path = 'PowerShell.exe'
    $Arguments = "-ExecutionPolicy Bypass -noprofile -command ""&{ start-process powershell -ArgumentList '-noprofile -file $sCurrDir\UACLevel.ps1' -verb RunAs}"""

    $Service = new-object -ComObject ("Schedule.Service")
    $Service.Connect()
    $RootFolder = $Service.GetFolder("\")
    $TaskDefinition = $Service.NewTask(0)
    $TaskDefinition.RegistrationInfo.Description = ''
    $TaskDefinition.Settings.Enabled = $True
    $TaskDefinition.Settings.AllowDemandStart = $True
    $TaskDefinition.Settings.DisallowStartIfOnBatteries = $False
    $Triggers = $TaskDefinition.Triggers
    $Trigger = $Triggers.Create(0)
    $Trigger.Enabled = $true
    $Trigger.Id = '102'
    $Trigger.Subscription = "<QueryList><Query Id=""0"" Path=""Microsoft-Windows-TaskScheduler/Operational""><Select Path=""Microsoft-Windows-TaskScheduler/Operational"">*[EventData[@Name='TaskSuccessEvent'][Data[@Name='TaskName']='\Microsoft\Windows\DeviceDirectoryClient\RegisterDevicePolicyChange']]</Select></Query></QueryList>"
    $Action = $TaskDefinition.Actions.Create(0)
    $Action.Path = $Path
    $action.Arguments = $Arguments
    $RootFolder.RegisterTaskDefinition($taskName, $TaskDefinition, 6, "System", $null, 5) | Out-Null
}

#Starts Script
Start-Main