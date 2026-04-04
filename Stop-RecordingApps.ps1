#Requires -Version 5.1
<#
.SYNOPSIS
  Okamžitě ukončí běžné nahrávací / klipovací programy a vypíše stav.
.NOTES
  Spusť v PowerShellu:  powershell -ExecutionPolicy Bypass -File ".\Stop-RecordingApps.ps1"
#>

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

Write-Host ""
Write-Host "  MCRybar" -ForegroundColor Cyan
Write-Host "  Made with " -NoNewline -ForegroundColor White
Write-Host ([char]0x2764) -NoNewline -ForegroundColor Red   # ❤
Write-Host " Liafen" -ForegroundColor Magenta
Write-Host "  ----------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# Zobrazovaný název | jméno procesu (bez .exe), jak ho vidí Get-Process -Name
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

$terminated = [System.Collections.Generic.List[string]]::new()
$notRunning = [System.Collections.Generic.List[string]]::new()

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
                $terminated.Add("$($entry.Display) [$($p.ProcessName).exe, PID $($p.Id)]")
            } catch {
                $terminated.Add("$($entry.Display) [$($p.ProcessName).exe, PID $($p.Id)] — CHYBA: $($_.Exception.Message)")
            }
        }
    }
    if (-not $foundAny) {
        $namesJoined = $entry.Names -join ", "
        $notRunning.Add("$($entry.Display) (hledáno: $namesJoined)")
    }
}

Write-Host "=== TERMINOVÁNO ($($terminated.Count)) ===" -ForegroundColor Green
if ($terminated.Count -eq 0) {
    Write-Host "  (žádný z cílových procesů neběžel)" -ForegroundColor DarkGray
} else {
    foreach ($line in $terminated) {
        Write-Host "  $line" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== NEBĚŽÍ / NENALEZENO ($($notRunning.Count)) ===" -ForegroundColor DarkGray
foreach ($line in $notRunning) {
    Write-Host "  $line" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "Hotovo." -ForegroundColor White
