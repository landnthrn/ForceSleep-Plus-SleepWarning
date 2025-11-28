# Helper script to get current monitor sleep timeout in minutes
$output = powercfg /q SCHEME_CURRENT SUB_VIDEO 2>&1 | Out-String

if ($output -match 'VIDEOIDLE' -and $output -match 'Current AC Power Setting Index:\s*0x([0-9a-fA-F]+)') {
    $hexValue = $matches[1]
    $seconds = [convert]::ToInt32($hexValue, 16)
    $minutes = [math]::Floor($seconds / 60)
    Write-Output $minutes
} else {
    Write-Output "0"
}

