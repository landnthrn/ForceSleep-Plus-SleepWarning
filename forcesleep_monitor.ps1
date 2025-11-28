<# 
Monitor Sleep Timeout - Adjustment Script
Interactive helper to update the monitor sleep timeout.
#>

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$watcherScript = Join-Path $scriptDir "forcesleep.ps1"

function Format-MonitorTime([int]$minutes) {
    if ($minutes -eq 0) {
        return "Never"
    }
    if ($minutes -lt 60) {
        return "$minutes minute$(if ($minutes -eq 1) { '' } else { 's' })"
    }

    $hours = [math]::Floor($minutes / 60)
    $remainingMinutes = $minutes % 60

    if ($remainingMinutes -eq 0) {
        return "$hours hour$(if ($hours -eq 1) { '' } else { 's' })"
    }

    $parts = @()
    if ($hours -gt 0) {
        $parts += "$hours hour$(if ($hours -eq 1) { '' } else { 's' })"
    }
    if ($remainingMinutes -gt 0) {
        $parts += "$remainingMinutes minute$(if ($remainingMinutes -eq 1) { '' } else { 's' })"
    }

    return ($parts -join " ")
}

function Read-Int([string]$prompt, [int]$min, [int]$max) {
    while ($true) {
        $input = Read-Host "$prompt"
        $value = 0
        if ([int]::TryParse($input, [ref]$value) -and $value -ge $min -and $value -le $max) {
            return $value
        }
        Write-Host "Please enter a number between $min and $max." -ForegroundColor Yellow
    }
}

function Read-YesNo([string]$question) {
    while ($true) {
        if ($question) {
            Write-Host ""
            Write-Host $question
        }
        Write-Host ""
        $response = Read-Host "Enter y or n"
        switch ($response.ToLower()) {
            'y' { return $true }
            'n' { return $false }
            default {
                Write-Host ""
                Write-Host "Please enter 'y' or 'n'." -ForegroundColor Yellow
            }
        }
    }
}

# Get current monitor sleep time
$monitorMinutes = 0
try {
    $output = & powercfg /q SCHEME_CURRENT SUB_VIDEO 2>&1 | Out-String
    
    if ($output -match 'VIDEOIDLE' -and $output -match 'Current AC Power Setting Index:\s*0x([0-9a-fA-F]+)') {
        $hexValue = $matches[1]
        $seconds = [convert]::ToInt32($hexValue, 16)
        $monitorMinutes = [math]::Floor($seconds / 60)
    }
} catch {
    # If we can't read it, default to 0
    $monitorMinutes = 0
}

# Read current idle timer for recommendation
$currentIdleMinutes = 25
if (Test-Path $watcherScript) {
    $watcherContent = Get-Content -Path $watcherScript -Raw
    if ($watcherContent -match '\$ThresholdMinutes\s*=\s*(\d+)') {
        $currentIdleMinutes = [int]$Matches[1]
    }
}

Write-Host ""
$monitorTimeDisplay = Format-MonitorTime $monitorMinutes
Write-Host "Monitor Sleep Time Currently Set to: $monitorTimeDisplay"
Write-Host ""
if (-not (Read-YesNo "Would you like to change the monitor sleep time?")) {
    exit 0
}

Write-Host ""
Write-Host "Recommend to set 1 minute longer than your set idle time"
Write-Host ""

while ($true) {
    Write-Host ""
    Write-Host "(Enter 0 if you'd like)"
    $hours = Read-Int "Hours" 0 ([int]::MaxValue)
    Write-Host ""
    Write-Host "(Enter 0 if you'd like)"
    $minutes = Read-Int "Minutes" 0 59

    $newTotalMinutes = ($hours * 60) + $minutes

    if ($newTotalMinutes -lt 0) {
        Write-Host ""
        Write-Host "Monitor sleep time cannot be negative. Please try again." -ForegroundColor Yellow
        continue
    }

    break
}

Write-Host ""
Write-Host "New Monitor Sleep Time Set to: $(Format-MonitorTime $newTotalMinutes)"
Write-Host ""

if (-not (Read-YesNo "Ready to Apply?")) {
    Write-Host "No changes were made."
    exit 0
}

# Apply the monitor timeout using powercfg
Write-Host ""

try {
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = "powercfg.exe"
    $processInfo.Arguments = "/change monitor-timeout-ac $newTotalMinutes"
    $processInfo.UseShellExecute = $false
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.CreateNoWindow = $true
    
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    $null = $process.Start()
    $output = $process.StandardOutput.ReadToEnd()
    $errorOutput = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    $exitCode = $process.ExitCode
    
    if ($exitCode -eq 0) {
        Write-Host "Monitor sleep time updated."
        Write-Host ""
        
        # Flush output buffer to ensure message is displayed before script exits
        [Console]::Out.Flush()
        [Console]::Error.Flush()
        Start-Sleep -Milliseconds 300
    } else {
        Write-Host "Failed to set monitor timeout. Exit code: $exitCode" -ForegroundColor Red
        if ($errorOutput) {
            Write-Host $errorOutput -ForegroundColor Red
        }
        Write-Host ""
        [Console]::Out.Flush()
        exit 1
    }
} catch {
    Write-Host "Error executing powercfg: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    [Console]::Out.Flush()
    exit 1
}

# Flush output buffer to ensure message is displayed
[Console]::Out.Flush()
[Console]::Error.Flush()

# Wait briefly to ensure output is visible
Start-Sleep -Milliseconds 500

exit 0

