![SleepwarningPreview](https://github.com/user-attachments/assets/95d23811-a6f4-4690-9588-bd21821672ea)
<img width="417" height="263" alt="seelen-ui_Yea6HDYXRe" src="https://github.com/user-attachments/assets/ff28c26e-6660-4c87-9f4d-7a9250c07e58" />

# BETTER PC SLEEP + SLEEP WARNING
This feature simulates the regular sleeping system and adds more convenience to it.  
Comes with a mini UI in command prompt.

---

## MAIN USES:
— **Ease of access & speed with changing specifics to your sleeping setup, useful for certain tasks**

— **Got a task that requires your PC to stay awake for long periods of time?** Set a sleep timer, or disable sleep in seconds with the cmd UI

— **Want you're PC to sleep after a download/upload is expected to finish?** Set a sleep timer for it

— **You're PC refues to sleep and you just can't figure out the cause of it?** This will simulate the default sleeping system for you

---

### CMD SLEEP COMMANDS:
`sleep` — Display this list of commands  
`sleepon` — Enable idle sleep  
`sleepoff` — Disable idle sleep (perfect for long downloads & so on)  
`sleepstatus` — Check if the watcher is enabled/disabled  
`sleeptime` — Change the set idle time to trigger sleep  
`sleeprestart` — Restart the sleep watcher task manually  

You can cancel sleep by pressing `Ctrl + C` while the warning is visible,  
or pause/resume the countdown by clicking the window and pressing any key.

If you have media/audio playing, it will pause all audio before sleep triggers

---

## HOW TO SETUP SLEEP WATCHER / SLEEP WARNING:

- Go to your Documents folder

- Create a folder called `Scripts`

- Create another folder inside `Scripts` called `ForceSleep`

- Place all the files from this download into there

- Search Windows for "Environment Variables"

- Once the System Properties tab opens, select Environment Variables again.

- Under User Variables (top list), select `Path`, then click `Edit`

- Click `New` and paste the path to your sleep watcher folder  
`C:\Users\%USERNAME%\Documents\Scripts\ForceSleep`

- (Optional but foolproof) Add the Scripts folder path too:  
`C:\Users\%USERNAME%\Documents\Scripts`

- Replace `%USERNAME%` with your PC user name

- Click OK a few times to close Environment Variables

- Open PowerShell as Administrator and run the following command:

```powershell
$taskName    = "ForceSleep_Watcher"
$scriptPath  = "$env:USERPROFILE\Documents\Scripts\ForceSleep\forcesleep.ps1"
$powershellExe = Join-Path $env:WINDIR "System32\WindowsPowerShell\v1.0\powershell.exe"

try {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
} catch {
    # Task doesn't exist yet – that's fine
}

$action    = New-ScheduledTaskAction -Execute $powershellExe `
    -Argument "-NoProfile -NoLogo -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
$trigger   = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

$settings  = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Days 3)
$settings.DisallowStartIfOnBatteries = $false
$settings.StopIfGoingOnBatteries     = $false
$settings.StartWhenAvailable         = $true

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings
Start-ScheduledTask   -TaskName $taskName
```

- Once the task is created, open Task Scheduler and confirm the `ForceSleep_Watcher` task is running

## DISABLE THE DEFAULT SLEEPING SYSTEM
Run this in PowerShell Administrator

```powershell
powercfg -change -standby-timeout-ac 0
powercfg -change -standby-timeout-dc 0
```

---

## TEST THAT IT WORKS:

- Open a command prompt window and run `sleep`

- Confirm the watcher is enabled (`sleepstatus`) or turn it on (`sleepon`)

- Run `sleeptime` and set the idle time to 1 minute for testing

- Wait a full minute, don't touch your keyboard or mouse, once the sleep warning appears let it play out to confirm the PC sleeps

- When you're done testing, use `sleeptime` again to set your idle time however you'd like

---

## Found this useful?<img src="https://media.tenor.com/23NitOvEEkMAAAAj/optical-illusion-rotating-head.gif" width="30"><br>

[![Follow Me <3](https://img.shields.io/badge/Follow%20Me%20%3C3-000000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/landnthrn)  
[![Find More of my Creations on GitHub](https://img.shields.io/badge/Find%20More%20of%20my%20Creations%20on%20GitHub-311A82?style=for-the-badge&logo=github&logoColor=white)](https://github.com/landnthrn?tab=repositories)  
[![Gists: landnthrn](https://img.shields.io/badge/Gists-311A82?style=for-the-badge&logo=github&logoColor=white)](https://gist.github.com/landnthrn)  
[![Discord: landn.thrn](https://img.shields.io/badge/Discord-311A82?style=for-the-badge&logo=discord&logoColor=white)](https://discord.com/users/831735011588964392)  
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-311A82?style=for-the-badge&logo=buymeacoffee&logoColor=white)](https://buymeacoffee.com/landn.thrn/extras)  
[![PayPal](https://img.shields.io/badge/PayPal-311A82?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.com/donate/?hosted_button_id=K4PLHFVBH7X8C)
