#Requires -Version 5.1
# ASCII-only file: works after download from GitHub / wrong default encoding in Windows PowerShell 5.1
<#
.SYNOPSIS
  Stops common recording / clipping apps and prints status.
.NOTES
  Run: powershell -NoProfile -ExecutionPolicy Bypass -File ".\Stop-RecordingApps.ps1"
#>

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

Write-Host ""
Write-Host "  MCRybar" -ForegroundColor Cyan
Write-Host "  Made with " -NoNewline -ForegroundColor White
Write-Host ([char]0x2764) -NoNewline -ForegroundColor Red
Write-Host " Liafen" -ForegroundColor Magenta
Write-Host "  ----------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# Display label | process name(s) for Get-Process -Name (no .exe)
$targets = @(
    @{ Display = "OBS Studio (64-bit)";       Names = @("obs64") }
    @{ Display = "OBS Studio (32-bit)";       Names = @("obs32") }
    @{ Display = "Streamlabs Desktop";         Names = @("Streamlabs OBS", "Streamlabs") }
    @{ Display = "Xbox Game Bar";              Names = @("GameBar", "GameBarFTServer") }
    @{ Display = "NVIDIA Share (ShadowPlay)";  Names = @("NVIDIA Share") }
    @{ Display = "NVIDIA Overlay helper";     Names = @("nvsphelper64", "nvsphelper32") }
    @{ Display = "AMD Software / Adrenalin";   Names = @("RadeonSoftware", "AMDRSServ") }
    @{ Display = "Medal.tv";                   Names = @("Medal", "MedalEncoder") }
    @{ Display = "Outplayed (Overwolf)";      Names = @("outplayed") }
    @{ Display = "Overwolf";                   Names = @("Overwolf") }
    @{ Display = "ShareX";                     Names = @("ShareX") }
    @{ Display = "Bandicam";                   Names = @("Bandicam", "bdcam") }
    @{ Display = "Fraps";                      Names = @("fraps") }
    @{ Display = "Mirillis Action!";          Names = @("Action!") }
    @{ Display = "Dxtory";                     Names = @("Dxtory") }
    @{ Display = "XSplit Broadcaster";        Names = @("XSplit.Core", "XSplitBroadcaster") }
    @{ Display = "Twitch Studio";             Names = @("TwitchStudio") }
    @{ Display = "SteelSeries GG / Moments";  Names = @("SteelSeriesGG", "SteelSeriesEngine") }
    @{ Display = "Loom";                       Names = @("Loom") }
    @{ Display = "Camtasia";                   Names = @("CamtasiaStudio", "Camtasia2019", "Camtasia2020", "Camtasia2021", "Camtasia2022", "Camtasia2023", "Camtasia2024") }
    @{ Display = "Clipchamp (Windows)";       Names = @("Clipchamp") }
    @{ Display = "GeForce Experience";        Names = @("NVIDIA GeForce Experience") }
    @{ Display = "Open Broadcaster (legacy)"; Names = @("obs") }
)

$terminated = New-Object System.Collections.ArrayList
$notRunning = New-Object System.Collections.ArrayList

foreach ($entry in $targets) {
    $foundAny = $false
    foreach ($procName in $entry.Names) {
        $procs = $null
        try {
            $procs = Get-Process -Name $procName -ErrorAction SilentlyContinue
        } catch {
            $procs = $null
        }
        if (-not $procs) { continue }
        $foundAny = $true
        foreach ($p in @($procs)) {
            try {
                Stop-Process -Id $p.Id -Force -ErrorAction Stop
                [void]$terminated.Add(('{0} [{1}.exe, PID {2}]' -f $entry.Display, $p.ProcessName, $p.Id))
            } catch {
                $err = $_.Exception.Message -replace "`r|`n", ' '
                [void]$terminated.Add(('{0} [{1}.exe, PID {2}] - ERROR: {3}' -f $entry.Display, $p.ProcessName, $p.Id, $err))
            }
        }
    }
    if (-not $foundAny) {
        $namesJoined = $entry.Names -join ', '
        [void]$notRunning.Add(('{0} (searched: {1})' -f $entry.Display, $namesJoined))
    }
}

Write-Host ('=== TERMINATED ({0}) ===' -f $terminated.Count) -ForegroundColor Green
if ($terminated.Count -eq 0) {
    Write-Host '  (none of the target processes were running)' -ForegroundColor DarkGray
} else {
    foreach ($line in $terminated) {
        Write-Host ('  {0}' -f $line) -ForegroundColor Green
    }
}

Write-Host ""
Write-Host ('=== NOT RUNNING / NOT FOUND ({0}) ===' -f $notRunning.Count) -ForegroundColor DarkGray
foreach ($line in $notRunning) {
    Write-Host ('  {0}' -f $line) -ForegroundColor DarkGray
}

Write-Host ""
Write-Host 'Done.' -ForegroundColor White
