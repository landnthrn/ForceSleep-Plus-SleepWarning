
![SleepwarningPreview](https://github.com/user-attachments/assets/95d23811-a6f4-4690-9588-bd21821672ea)


# Force Sleep Plus Sleep Warning
This feature will simulate the regular sleeping timer system, while also providing a Sleep Warning display allowing you time to cancel it.  
Also helpful if your PC just refuses to sleep and you can't figure out the cause of it.

You can toggle the feature on/off with simple commands in any command prompt window:

#### ForceSleep Commands:  
`forcesleep`        — Display this list of commands  
`forcesleep on`     — Enable idle sleep  
`forcesleep off`    — Disable idle sleep  (Helpful for long downloads 
`forcesleep status` — Check if enabled/disabled  

You can cancel the sleep from happening by pressing `Ctrl + C` during the sleep warning  
or pause it by clicking inside the terminal pop-up and resume it by pressing any key.

If you have media/audio playing, it will pause all audio before sleep triggers

---

## HOW TO SETUP FORCESLEEP/SLEEPWARNING:  
\**Use all commands provided in Command Prompt Admin*\*

- Go to your **Documents** folder

- Create a folder called **Scripts**

- Create another folder inside the **Scripts** folder called **ForceSleep**

- Place all the files from this download into there

- Search Windows for **Environment Variables**

- Once the **System Properties** tab opens, select **Environment Variables** again.

- Under the **User Variables** *(top box)*, select **Path**, then **Edit**

- Select **New** and paste the path of your **ForceSleep** folder. It should look like:  
`C:\Users\%USERNAME%\Documents\Scripts\ForceSleep`

- (Optional but foolproof to add the **Scripts** folder path too):  
  `C:\Users\%USERNAME%\Documents\Scripts`

Recommended to replace the `%USERNAME%` parts with your PC username,  
so say it was Elephant it would be `C:\Users\Elephant\Documents\Scripts`  

- Click OK a few times to close **Environment Variables**

- Open **Command Prompt** as **Administrator**

- Edit the following command before running it. Replace `%USERNAME%` with your PC username *(Without the %'s)* *(there are two to replace)*

**THE COMMAND:**  
```schtasks /create /tn "ForceSleep_Watcher" /tr "powershell.exe -NoProfile -NoLogo -ExecutionPolicy Bypass -WindowStyle Hidden -File "C:\Users\%USERNAME%\Documents\Scripts\ForceSleep\forcesleep.ps1"" /sc ONLOGON /ru "%USERNAME%" /it /rl LIMITED```

- Once you've created the `ForceSleep_Watcher` task with that command

- Open **Task Scheduler** and find the `ForceSleep_Watcher` task

- Right click it > Properties > Settings > make sure “Stop the task if it runs longer than” is set to 3 days

- Close Task Scheduler

------

## TEST IF IT WORKS:

- Open the ForceSleep.ps1 file (Right click > Edit)

- At the top, change:
`$ThresholdMinutes = 25`
to
`$ThresholdMinutes = 0.5`
This makes it trigger within about 30 seconds of idle time for testing

- Save changes to the `ForceSleep.ps1` file

**Note:**  
 Every time you make a change to these files, you should restart the **ForceSleep_Watcher** task by using this command:  
`schtasks /end /tn "ForceSleep_Watcher" & timeout /t 2 /nobreak >nul & schtasks /run /tn "ForceSleep_Watcher"`

- Once you've restarted the task, don't touch your mouse or keyboard for 30 seconds.
  See if the Sleep Warning appears, don’t cancel it so you can confirm it sleeps properly

- After you've verified it works, open `ForceSleep.ps1` again and change $`ThresholdMinutes = 0.5` to any number of minutes you'd like

- Save the file

- Restart the task again with this command:  
`schtasks /end /tn "ForceSleep_Watcher" & timeout /t 2 /nobreak >nul & schtasks /run /tn "ForceSleep_Watcher"`

---

## Found this useful?<img src="https://media.tenor.com/23NitOvEEkMAAAAj/optical-illusion-rotating-head.gif" width="30"><br>

[![Follow Me <3](https://img.shields.io/badge/Follow%20Me%20%3C3-000000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/landnthrn)   
[![Find More of my Creations on GitHub](https://img.shields.io/badge/Find%20More%20of%20my%20Creations%20on%20GitHub-311A82?style=for-the-badge&logo=github&logoColor=white)](https://github.com/landnthrn?tab=repositories)  
[![Gists: landnthrn](https://img.shields.io/badge/Gists-311A82?style=for-the-badge&logo=github&logoColor=white)](https://gist.github.com/landnthrn)  
[![Discord: landn.thrn](https://img.shields.io/badge/Discord-311A82?style=for-the-badge&logo=discord&logoColor=white)](https://discord.com/users/831735011588964392)  
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-311A82?style=for-the-badge&logo=buymeacoffee&logoColor=white)](https://buymeacoffee.com/landn.thrn/extras)  
[![PayPal](https://img.shields.io/badge/PayPal-311A82?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.com/donate/?hosted_button_id=K4PLHFVBH7X8C)

---


---
