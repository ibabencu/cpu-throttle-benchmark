param(
    [string]$SolutionPath  = "C:/dev/studio/Studio/Studio.sln",
    [string]$RepoPath      = "C:/dev/studio/Studio",
    [string]$OutputDir     = "C:/dev/benchmark-results",
    [int]$Iterations       = 10,
    [int]$CooldownSec      = 30
)

$dotnet = "C:/Program Files/dotnet/dotnet.exe"
$git    = "C:/Program Files/Git/bin/git.exe"
$refRoot = "C:\dev\ref-assemblies\"
$nodeDir = "C:/Users/ionut.babencu/bin/node-v22.14.0-win-x64"

# Add Node.js to PATH so npm ci works in UiPath.Studio.Shell build
if ($env:PATH -notlike "*$nodeDir*") {
    $env:PATH = "$nodeDir;$env:PATH"
}

# Run from repo dir so global.json is picked up (pins SDK to 8.x)
Set-Location $RepoPath

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }

$csvFile = "$OutputDir/build-results.csv"

"iteration,start_time,end_time,duration_sec,freq_mhz_start,freq_mhz_end,exit_code" | Out-File $csvFile -Encoding utf8

function Get-CpuFreq {
    (Get-CimInstance Win32_Processor | Select-Object -First 1).CurrentClockSpeed
}

# ---------------------------------------------------------------------------
# CPU name — auto-detect for portable report filename
# ---------------------------------------------------------------------------
$cpuName  = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
$safeName = ($cpuName -replace '[^a-zA-Z0-9]', '-').Trim('-') -replace '-+', '-'
$reportFile = "$OutputDir/report-$safeName.md"

Write-Host "=== CPU Throttling Benchmark ===" -ForegroundColor Cyan
Write-Host "CPU      : $cpuName"
Write-Host "Solution : $SolutionPath"
Write-Host "Iterations: $Iterations  |  Cooldown: ${CooldownSec}s"
Write-Host "Results  : $OutputDir"
Write-Host "Report   : $reportFile"
Write-Host ""

# ---------------------------------------------------------------------------
# DocGen pre-build — prevents 9009 / "is not recognized" errors
# Finds UiPath.Api.Package.DocGen.csproj anywhere in RepoPath and builds it
# once, then adds all its bin output dirs to PATH.
# ---------------------------------------------------------------------------
Write-Host "Looking for UiPath.Api.Package.DocGen..." -ForegroundColor DarkGray
$docGenProj = Get-ChildItem $RepoPath -Recurse -Filter "UiPath.Api.Package.DocGen.csproj" `
              -ErrorAction SilentlyContinue | Select-Object -First 1

if ($docGenProj) {
    Write-Host "Pre-building DocGen: $($docGenProj.FullName)" -ForegroundColor Cyan
    & $dotnet build $docGenProj.FullName --no-restore `
        /p:TargetFrameworkRootPath="$refRoot" /p:RunAnalyzers=false 2>&1 |
        Out-File "$OutputDir/docgen-prebuild.log" -Encoding utf8

    # DocGen outputs to Output\Api\Tools\DocGen\Debug\ (not bin\)
    # Add all subdirs of that output location to PATH so DocGen.exe is found
    $docGenOutDir = "$RepoPath\Output\Api\Tools\DocGen\Debug"
    $pathDirs = @()
    if (Test-Path $docGenOutDir) {
        $pathDirs += $docGenOutDir
        $pathDirs += Get-ChildItem $docGenOutDir -Directory | Select-Object -ExpandProperty FullName
    }
    foreach ($d in $pathDirs) {
        if ($env:PATH -notlike "*$d*") {
            $env:PATH = "$d;$env:PATH"
        }
    }
    Write-Host "DocGen pre-build done. Added $($pathDirs.Count) output dirs to PATH." -ForegroundColor Green
} else {
    Write-Host "DocGen project not found - skipping pre-build." -ForegroundColor DarkGray
}

Write-Host ""

# ---------------------------------------------------------------------------
# Main build loop
# ---------------------------------------------------------------------------
for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "--- Iteration $i / $Iterations ---" -ForegroundColor Yellow

    # Touch all .cs files to mark them as modified → forces full recompile on incremental build
    # This avoids the --no-incremental MSB3030 copy failures caused by UseAppHost=false
    Write-Host "  Touching .cs files..." -NoNewline
    $now = Get-Date
    Get-ChildItem $RepoPath -Recurse -Include "*.cs" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '\\(obj|bin|Legacy)\\' } |
        ForEach-Object { $_.LastWriteTime = $now }
    Write-Host " done"

    $freqStart = Get-CpuFreq
    $startTime = Get-Date
    Write-Host "  Build start: $($startTime.ToString('HH:mm:ss'))  CPU: ${freqStart} MHz"

    # Incremental build (all .cs are newer than outputs → full recompile, no copy-related failures)
    & $dotnet build $SolutionPath --no-restore -m `
        /p:TargetFrameworkRootPath="$refRoot" /p:RunAnalyzers=false `
        2>&1 | Tee-Object -FilePath "$OutputDir/iter-$i.log"
    $exitCode = $LASTEXITCODE

    $endTime  = Get-Date
    $freqEnd  = Get-CpuFreq
    $duration = [math]::Round(($endTime - $startTime).TotalSeconds, 1)

    $status = if ($exitCode -eq 0) { "OK" } else { "FAIL($exitCode)" }
    $color  = if ($exitCode -eq 0) { "Green" } else { "Red" }
    Write-Host "  Build end  : $($endTime.ToString('HH:mm:ss'))  CPU: ${freqEnd} MHz  Duration: ${duration}s  [$status]" -ForegroundColor $color

    # append CSV
    "$i,$($startTime.ToString('yyyy-MM-dd HH:mm:ss')),$($endTime.ToString('yyyy-MM-dd HH:mm:ss')),$duration,$freqStart,$freqEnd,$exitCode" | Add-Content $csvFile

    if ($i -lt $Iterations) {
        Write-Host "  Cooldown ${CooldownSec}s..." -NoNewline
        Start-Sleep $CooldownSec
        Write-Host " done"
    }
    Write-Host ""
}

# ---------------------------------------------------------------------------
# Report generation
# ---------------------------------------------------------------------------
Write-Host "=== Generating report ===" -ForegroundColor Cyan

$rows      = Import-Csv $csvFile
$durations = $rows | ForEach-Object { [double]$_.duration_sec }
$freqsStart = $rows | ForEach-Object { [int]$_.freq_mhz_start }

$minDur  = ($durations | Measure-Object -Minimum).Minimum
$maxDur  = ($durations | Measure-Object -Maximum).Maximum
$avgDur  = [math]::Round(($durations | Measure-Object -Average).Average, 1)
$drift   = [math]::Round($durations[-1] - $durations[0], 1)
$minFreq = ($freqsStart | Measure-Object -Minimum).Minimum
$maxFreq = ($freqsStart | Measure-Object -Maximum).Maximum
$throttleRatio = if ($durations[0] -gt 0) { [math]::Round($maxDur / $durations[0], 2) } else { "N/A" }

$maxTempC = "N/A"
$metricsCsv = "$OutputDir/cpu-metrics.csv"
if (Test-Path $metricsCsv) {
    $temps = Import-Csv $metricsCsv |
             Where-Object { $_.temp_c -and [double]$_.temp_c -gt 0 } |
             ForEach-Object { [double]$_.temp_c }
    if ($temps) {
        $maxTempC = "$([math]::Round(($temps | Measure-Object -Maximum).Maximum, 1)) C"
    }
}

$report = @"
# CPU Throttling Benchmark Report

**CPU:** $cpuName
**Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')
**Iterations:** $Iterations  |  **Cooldown:** ${CooldownSec}s

## Build Results

| Iteration | Start | Duration (s) | CPU Start (MHz) | CPU End (MHz) | Status |
|-----------|-------|-------------|----------------|--------------|--------|
"@

foreach ($row in $rows) {
    $st = $row.start_time.Substring(11,8)
    $ok = if ($row.exit_code -eq "0") { "OK" } else { "FAIL" }
    $report += "`n| $($row.iteration) | $st | $($row.duration_sec) | $($row.freq_mhz_start) | $($row.freq_mhz_end) | $ok |"
}

$report += @"


## Summary

| Metric | Value |
|--------|-------|
| Min build time | ${minDur}s |
| Max build time | ${maxDur}s |
| Avg build time | ${avgDur}s |
| **Drift (iter 1 vs 10)** | **${drift}s** |
| **Throttle ratio (max/min)** | **${throttleRatio}x** |
| Min CPU freq seen | ${minFreq} MHz |
| Max CPU freq seen | ${maxFreq} MHz |
| **Max temp observed** | **${maxTempC}** |

## ASCII Frequency Chart (start of each build)

``````
"@

$maxF = ($freqsStart | Measure-Object -Maximum).Maximum
foreach ($row in $rows) {
    $f    = [int]$row.freq_mhz_start
    $bars = [math]::Round($f / $maxF * 40)
    $bar  = "#" * $bars
    $report += "`nIter $($row.iteration.PadLeft(2)): $($f.ToString().PadLeft(5)) MHz |$bar"
}

$report += @"

``````

## Conclusion

$(if ([math]::Abs($drift) -lt 5) {
    "Minimal throttling: drift of only ${drift}s between iteration 1 and 10."
} elseif ($drift -gt 0) {
    "Throttling detected: build time increased by ${drift}s ($(([math]::Round($drift / $durations[0] * 100, 1)))%) from iteration 1 to 10. Throttle ratio: ${throttleRatio}x."
} else {
    "CPU warmed up and stabilized - build time stable or faster after warm-up."
})

CPU frequency: min ${minFreq} MHz / max ${maxFreq} MHz (delta $($maxFreq - $minFreq) MHz).

> **To compare AMD vs Intel:** run `compare-results.ps1` after collecting results from both machines.
"@

$report | Out-File $reportFile -Encoding utf8
Write-Host "Report saved: $reportFile" -ForegroundColor Green
Write-Host ""
Write-Host "Summary: min=${minDur}s  max=${maxDur}s  avg=${avgDur}s  drift=${drift}s  throttleRatio=${throttleRatio}x  freqRange=${minFreq}-${maxFreq}MHz"
