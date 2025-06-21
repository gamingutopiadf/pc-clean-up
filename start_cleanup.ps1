$response = Read-Host "`n[?] Run startup cleanup now? (Y/N)"
if ($response -ne 'Y' -and $response -ne 'y') {
    Write-Host "`nCleanup canceled by user."
    exit
}

# === Log setup ===
$desktop = [Environment]::GetFolderPath("Desktop")
$logDir = Join-Path $desktop "PC-Clean-Logs"

if (-Not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logPath = "$logDir\startup_cleanup_$timestamp.txt"

Function Log($msg) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$time - $msg"
    $line | Out-File -FilePath $logPath -Append
    Write-Host $line
}

Log "===== Startup Cleanup Started ====="

# === Delete old logs > 10 days ===
try {
    $oldLogs = Get-ChildItem -Path $logDir -Filter "*.txt" | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-10) }
    foreach ($log in $oldLogs) {
        Log "Deleting old log: $($log.Name)"
        Remove-Item $log.FullName -Force
    }
    if ($oldLogs.Count -eq 0) {
        Log "No old logs found."
    }
} catch {
    Log "Error deleting old logs: $_"
}

# === Disable unwanted startup items ===
$appsToDisable = @(
    "BraveSoftware Update", "ChatGPT", "Copilot", "CurseForge",
    "Hamachi Client Application", "IriunWebcam",
    "Microsoft 365 Copilot", "Microsoft Edge", "Microsoft To Do", "We couldn't find this app"
)

foreach ($app in $appsToDisable) {
    Log "Disabling: $app"
    try {
        Get-CimInstance -ClassName Win32_StartupCommand | Where-Object { $_.Name -eq $app } | Remove-CimInstance
    } catch {
        Log "Could not disable $app"
    }
}

# === Clear TEMP files ===
try {
    Log "Cleaning TEMP directories..."
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
} catch {
    Log "Error cleaning TEMP directories: $_"
}

# === Clean Discord cache ===
$discordPaths = @(
    "$env:APPDATA\discord\Cache",
    "$env:APPDATA\discord\Code Cache",
    "$env:APPDATA\discord\GPUCache",
    "$env:APPDATA\discord\Local Storage",
    "$env:APPDATA\discord\logs"
)

foreach ($path in $discordPaths) {
    if (Test-Path $path) {
        Log "Cleaning Discord: $path"
        Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# === Clean browser cache ===
$browserPaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Cache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default\GPUCache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache",
    "$env:APPDATA\Mozilla\Firefox\Profiles"
)

foreach ($path in $browserPaths) {
    if (Test-Path $path) {
        Log "Cleaning browser cache: $path"
        Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# === Clear Explorer history ===
try {
    Log "Clearing Explorer recent files..."
    Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:APPDATA\Microsoft\Windows\Recent Items\*" -Recurse -Force -ErrorAction SilentlyContinue
} catch {
    Log "Failed to clear Explorer history: $_"
}

# === Remove crash dumps and error logs ===
try {
    Log "Removing crash dumps and error logs..."
    Remove-Item "C:\ProgramData\Microsoft\Windows\WER\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Users\Public\CrashDumps\*" -Recurse -Force -ErrorAction SilentlyContinue
} catch {
    Log "Error cleaning crash dumps: $_"
}

# === Restart Windows Explorer ===
try {
    Log "Restarting Windows Explorer..."
    Stop-Process -Name explorer -Force
    Start-Process explorer
} catch {
    Log "Failed to restart Explorer: $_"
}

# === Final message ===
Log "Cleanup complete."
Write-Host "`n✅ Clean-up complete — Log output posted to Desktop\PC-Clean-Logs" -ForegroundColor Green
