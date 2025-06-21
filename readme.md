# PC Clean-Up 🧹

A PowerShell script to clean up temporary files, browser caches, Discord logs, Explorer history, and disable startup bloat on Windows 10/11.

## 🔧 Features

- Deletes:
  - Temp files (`%TEMP%`, `C:\Windows\Temp`)
  - Browser caches (Chrome, Brave, Edge, Firefox)
  - Discord cache and logs
  - Explorer recent history
  - Crash dumps and WER logs
- Disables startup apps
- Logs cleanup runs to `D:\logs for clean-up script`
- Auto-deletes logs older than 10 days
- Real-time output in console and saved to `.txt`

## 🚀 Usage

```powershell
powershell -ExecutionPolicy Bypass -File "start_cleanup.ps1"
