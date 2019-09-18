**About**

This powershell script ('Script') can either create a scheduled task or an automatic task in windows Task Scheduler that calls another script. A scheduled task will run over a designated interval for a designated time. An automatic task will run when another task completes.

Code built off of 

https://blogs.technet.microsoft.com/platformspfe/2015/10/26/configuring-advanced-scheduled-task-parameters-using-powershell/

and 

https://stackoverflow.com/questions/42801733/creating-a-scheduled-task-which-uses-a-specific-event-log-entry-as-a-trigger

**Instructions**

Any places in the script that you see "--text--" is text to be replaced. These include the path to the script you want to call 
(--ScriptToRun--) and the name of the scheduled task to create (--TaskName--) (see below for help with modifications). There is also
--TaskNameHere-- at '$Trigger.Subscription' if you choose to create an Automatic task which will be the task that you want to wait to
finish before you run your task.

Using an Administator PowerShell:
1. Run "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass" to allow the script to run for this session
2. Run the file "./Script.ps1"

Note:
If you move this folder, you will have to rerun "./Script.ps1" as the location has changed

To remove Task:
1. Open Task Scheduler
2. Open Task Scheduler Library (left side)
3. Delete task named "--TaskName--"

**Example**

Currently, I have included an example script to try called "UACLevel.ps1". This script will change the UAC level of the current user
to level 3 when run. Feel free to use this example script to test by replacing the path in '$Arguments' to point to "UACLevel.ps1".

**Modifications**

To switch between Scheduled or Automatic, call the desired function in the 'Start-Main' function.

Modify Scheduled Task:
- Set a different script to run in the '$Arguments' variable
- Change the Duration of the taskto run at '$Task.Triggers.Repetition.Duration'
- Change the Interval to repeat task at '$Task.Triggers.Repetition.Interval'
- Change the task Trigger (when the task starts) at '$TaskTrigger'
- Change task name at 'Register-ScheduledTask "--TaskName--" -InputObject $Task -Force' and '$Task = Get-ScheduledTask -TaskName "--TaskName--"'

Modify Automatic Task
- Set a different script to run in the '$Arguments' variable
- Change the task that you want to wait to finish at '$Trigger.Subscription' (see 
http://woshub.com/schedule-task-to-start-when-another-task-finishes/ for help with this)
