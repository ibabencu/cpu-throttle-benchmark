param(
    [string]$SolutionPath  = "C:/dev/studio/Studio/Studio.sln",
    [string]$RepoPath      = "C:/dev/studio/Studio",
    [string]$OutputDir     = "C:/dev/benchmark-results",
    [int]$Iterations       = 10,
    [int]$CooldownSec      = 30
)

$dotnet = "C:/Program Files/dotnet/dotnet.exe"
$git    = "C:/Program Files/Git/bin/git.exe"

if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir | Out-Null }

$csvFile = "$OutputDir/build-results.csv"
$logFile = "$OutputDir/build-log.txt"

"iteration,start_time,end_time,duration_sec,freq_mhz_start,freq_mhz_end,exit_code" | Out-File $csvFile -Encoding utf8

function Get-CpuFreq {
    (Get-CimInstance Win32_Processor | Select-Object -First 1).CurrentClockSpeed
}

Write-Host "=== CPU Throttling Benchmark ===" -ForegroundColor Cyan
Write-Host "Solution : $SolutionPath"
Write-Host "Iterations: $Iterations  |  Cooldown: ${CooldownSec}s"
Write-Host "Results  : $OutputDir"
Write-Host ""

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host "--- Iteration $i / $Iterations ---" -ForegroundColor Yellow

    # git clean
    Write-Host "  git clean -xdf..." -NoNewline
    & $git -C $RepoPath clean -xdf -q 2>&1 | Out-Null
    Write-Host " done"

    $freqStart = Get-CpuFreq
    $startTime = Get-Date
    Write-Host "  Build start: $($startTime.ToString('HH:mm:ss'))  CPU: ${freqStart} MHz"

    # dotnet build
    & $dotnet build $SolutionPath --no-restore -m 2>&1 | Tee-Object -FilePath "$OutputDir/iter-$i.log"
    $exitCode = $LASTEXITCODE

    $endTime  = Get-Date
    $freqEnd  = Get-CpuFreq
    $duration = [math]::Round(($endTime - $startTime).TotalSeconds, 1)

    $status = if ($exitCode -eq 0) { "OK" } else { "FAIL($exitCode)" }
    Write-Host "  Build end  : $($endTime.ToString('HH:mm:ss'))  CPU: ${freqEnd} MHz  Duration: ${duration}s  [$status]" -ForegroundColor $(if ($exitCode -eq 0) { "Green" } else { "Red" })

    # append CSV
    "$i,$($startTime.ToString('yyyy-MM-dd HH:mm:ss')),$($endTime.ToString('yyyy-MM-dd HH:mm:ss')),$duration,$freqStart,$freqEnd,$exitCode" | Add-Content $csvFile

    if ($i -lt $Iterations) {
        Write-Host "  Cooldown ${CooldownSec}s..." -NoNewline
        Start-Sleep $CooldownSec
        Write-Host " done"
    }
    Write-Host ""
}

# --- Report ---
Write-Host "=== Generating report ===" -ForegroundColor Cyan

$rows = Import-Csv $csvFile
$durations = $rows | ForEach-Object { [double]$_.duration_sec }
$freqsStart = $rows | ForEach-Object { [int]$_.freq_mhz_start }

$minDur  = ($durations | Measure-Object -Minimum).Minimum
$maxDur  = ($durations | Measure-Object -Maximum).Maximum
$avgDur  = [math]::Round(($durations | Measure-Object -Average).Average, 1)
$drift   = [math]::Round($durations[-1] - $durations[0], 1)
$minFreq = ($freqsStart | Measure-Object -Minimum).Minimum
$maxFreq = ($freqsStart | Measure-Object -Maximum).Maximum

$cpuName = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
$reportFile = "$OutputDir/report-amd-ryzen-hx370.md"

$report = @"
# CPU Throttling Benchmark Report — AMD

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
| Min CPU freq seen | ${minFreq} MHz |
| Max CPU freq seen | ${maxFreq} MHz |

## ASCII Frequency Chart (start of each build)

``````
"@

$maxF = ($freqsStart | Measure-Object -Maximum).Maximum
foreach ($row in $rows) {
    $f = [int]$row.freq_mhz_start
    $bars = [math]::Round($f / $maxF * 40)
    $bar = "#" * $bars
    $report += "`nIter $($row.iteration.PadLeft(2)): $($f.ToString().PadLeft(5)) MHz |$bar"
}

$report += @"

``````

## Conclusion

$(if ([math]::Abs($drift) -lt 5) {
    "Throttling minimal: build time drift de doar ${drift}s intre iteratia 1 si 10."
} elseif ($drift -gt 0) {
    "Throttling detectat: build time a crescut cu ${drift}s ($(([math]::Round($drift / $durations[0] * 100, 1)))%) de la iteratia 1 la 10."
} else {
    "CPU s-a incalzit si s-a stabilizat — build time stabil."
})

Frecventa CPU: min ${minFreq} MHz / max ${maxFreq} MHz (delta $($maxFreq - $minFreq) MHz).

> **Pentru comparatie:** ruleaza acelasi script pe laptopul Intel si compara `drift` si `freq delta`.
"@

$report | Out-File $reportFile -Encoding utf8
Write-Host "Report saved: $reportFile" -ForegroundColor Green
Write-Host ""
Write-Host "Summary: min=${minDur}s  max=${maxDur}s  avg=${avgDur}s  drift=${drift}s  freqRange=${minFreq}-${maxFreq}MHz"
