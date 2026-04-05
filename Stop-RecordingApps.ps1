#Requires -Version 5.1

try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

Clear-Host

Write-Host ""
Write-Host "MCRybar tool" -ForegroundColor Cyan
Write-Host "made with " -NoNewline -ForegroundColor White
Write-Host "<3" -NoNewline -ForegroundColor Red
Write-Host " by Liafen" -ForegroundColor Magenta
Write-Host "--------------------------------------------------" -ForegroundColor DarkGray
Write-Host ""

# Skutecna jmena procesu bez .exe
# Discord sem zamerne nedavame
$targets = @(
    @{ Display = "OBS Studio 64-bit";              Names = @("obs64") }
    @{ Display = "OBS Studio 32-bit";              Names = @("obs32") }
    @{ Display = "OBS legacy";                     Names = @("obs") }

    @{ Display = "Streamlabs Desktop";             Names = @("Streamlabs", "StreamlabsOBS") }

    @{ Display = "Xbox Game Bar";                  Names = @("GameBar", "GameBarFTServer", "GameBarPresenceWriter") }

    @{ Display = "NVIDIA Share / ShadowPlay";      Names = @("NVIDIAShare", "nvcontainer", "nvsphelper64", "nvsphelper32") }
    @{ Display = "NVIDIA GeForce Experience";      Names = @("NVIDIA GeForce Experience") }

    @{ Display = "AMD ReLive / Radeon";            Names = @("RadeonSoftware", "AMDRSServ", "RadeonSettings") }

    @{ Display = "Medal.tv";                       Names = @("Medal", "MedalEncoder", "MedalOverlay") }

    @{ Display = "Outplayed";                      Names = @("outplayed") }
    @{ Display = "Overwolf";                       Names = @("Overwolf", "OverwolfBrowser", "OverwolfHelper", "OWExplorer") }

    @{ Display = "ShareX";                         Names = @("ShareX") }

    @{ Display = "Bandicam";                       Names = @("Bandicam", "bdcam") }

    @{ Display = "Fraps";                          Names = @("fraps") }

    @{ Display = "Mirillis Action";                Names = @("Action", "Action_x64", "Action_x86") }

    @{ Display = "Dxtory";                         Names = @("Dxtory") }

    @{ Display = "XSplit Broadcaster";             Names = @("XSplit.Core", "XSplitBroadcaster") }

    @{ Display = "Twitch Studio";                  Names = @("TwitchStudio") }

    @{ Display = "SteelSeries Moments";            Names = @("SteelSeriesGG", "SteelSeriesEngine") }

    @{ Display = "Loom";                           Names = @("Loom") }

    @{ Display = "Camtasia";                       Names = @("CamtasiaStudio", "CamtasiaRecorder", "Camtasia2020", "Camtasia2021", "Camtasia2022", "Camtasia2023", "Camtasia2024") }

    @{ Display = "Clipchamp";                      Names = @("Clipchamp") }
)

$ukoncene = New-Object System.Collections.ArrayList
$chyby = New-Object System.Collections.ArrayList
$nenalezeno = New-Object System.Collections.ArrayList

foreach ($entry in $targets) {
    $nalezen = $false

    foreach ($procName in $entry.Names) {
        try {
            $procs = Get-Process -Name $procName -ErrorAction SilentlyContinue
        } catch {
            $procs = $null
        }

        if (-not $procs) {
            continue
        }

        $nalezen = $true

        foreach ($p in @($procs)) {
            # extra pojistka, aby se nikdy neukoncil Discord
            if ($p.ProcessName -like "Discord*") {
                continue
            }

            try {
                Stop-Process -Id $p.Id -Force -ErrorAction Stop
                [void]$ukoncene.Add(("{0} -> {1}.exe (PID {2})" -f $entry.Display, $p.ProcessName, $p.Id))
            } catch {
                $err = $_.Exception.Message -replace "`r|`n", " "
                [void]$chyby.Add(("{0} -> {1}.exe (PID {2}) - CHYBA: {3}" -f $entry.Display, $p.ProcessName, $p.Id, $err))
            }
        }
    }

    if (-not $nalezen) {
        [void]$nenalezeno.Add($entry.Display)
    }
}

Write-Host "Vysledek kontroly:" -ForegroundColor White
Write-Host ""

if ($ukoncene.Count -gt 0) {
    Write-Host ("Nalezeno a ukonceno aktivnich procesu: {0}" -f $ukoncene.Count) -ForegroundColor Green
    foreach ($radek in $ukoncene) {
        Write-Host ("  + {0}" -f $radek) -ForegroundColor Green
    }
} else {
    Write-Host "Nebyl nalezen zadny aktivni clipovaci ani recording proces." -ForegroundColor Red
}

if ($chyby.Count -gt 0) {
    Write-Host ""
    Write-Host ("Nepodarilo se ukoncit nektere procesy: {0}" -f $chyby.Count) -ForegroundColor Yellow
    foreach ($radek in $chyby) {
        Write-Host ("  ! {0}" -f $radek) -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Zkontrolovane aplikace, ktere momentalne nebezi:" -ForegroundColor DarkGray
foreach ($radek in $nenalezeno) {
    Write-Host ("  - {0}" -f $radek) -ForegroundColor DarkGray
}

Write-Host ""
if (($ukoncene.Count -eq 0) -and ($chyby.Count -eq 0)) {
    Write-Host "Hotovo. Z kontrolovaneho seznamu momentalne na pozadi nic nebezi." -ForegroundColor Red
} elseif ($chyby.Count -eq 0) {
    Write-Host "Hotovo. Nalezene procesy byly ukonceny a z kontrolovaneho seznamu uz na pozadi nic nebezi." -ForegroundColor Green
} else {
    Write-Host "Kontrola dokoncena, ale u nekterych procesu doslo k chybe. Pokud chces jistotu, spust PowerShell jako spravce a zkus to znovu." -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Stiskni Enter pro ukonceni"
