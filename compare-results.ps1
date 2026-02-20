# =============================================================================
# compare-results.ps1
# Compares AMD vs Intel benchmark results and generates comparison-amd-vs-intel.md
# =============================================================================

param(
    [string]$AmdDir   = "C:/dev/benchmark-results",
    [string]$IntelDir = "C:/dev/benchmark-results-intel",
    [string]$OutDir   = "C:/dev"
)

function Load-Results([string]$dir) {
    $csv = "$dir/build-results.csv"
    if (-not (Test-Path $csv)) {
        Write-Host "ERROR: Not found: $csv" -ForegroundColor Red
        return $null
    }
    return Import-Csv $csv
}

function Get-Stats([object[]]$rows) {
    $durations  = $rows | ForEach-Object { [double]$_.duration_sec }
    $freqsStart = $rows | ForEach-Object { [int]$_.freq_mhz_start }
    @{
        Durations   = $durations
        FreqsStart  = $freqsStart
        Min         = ($durations  | Measure-Object -Minimum).Minimum
        Max         = ($durations  | Measure-Object -Maximum).Maximum
        Avg         = [math]::Round(($durations | Measure-Object -Average).Average, 1)
        Drift       = [math]::Round($durations[-1] - $durations[0], 1)
        MinFreq     = ($freqsStart | Measure-Object -Minimum).Minimum
        MaxFreq     = ($freqsStart | Measure-Object -Maximum).Maximum
        ThrottleRatio = if ($durations[0] -gt 0) { [math]::Round(($durations | Measure-Object -Maximum).Maximum / $durations[0], 2) } else { 0 }
    }
}

function Get-CpuLabel([string]$dir) {
    $report = Get-ChildItem $dir -Filter "report-*.md" -ErrorAction SilentlyContinue |
              Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($report) {
        $content = Get-Content $report.FullName -Raw
        if ($content -match '\*\*CPU:\*\* (.+)') { return $matches[1].Trim() }
    }
    return (Split-Path $dir -Leaf)
}

function Make-AsciiChart([int[]]$freqs, [string]$label) {
    $maxF = ($freqs | Measure-Object -Maximum).Maximum
    $lines = @()
    $i = 1
    foreach ($f in $freqs) {
        $bars = [math]::Round($f / $maxF * 40)
        $bar  = "#" * $bars
        $lines += "Iter $($i.ToString().PadLeft(2)): $($f.ToString().PadLeft(5)) MHz |$bar"
        $i++
    }
    return $lines -join "`n"
}

# ---------------------------------------------------------------------------
Write-Host "=== AMD vs Intel Comparison ===" -ForegroundColor Cyan

$amdRows   = Load-Results $AmdDir
$intelRows = Load-Results $IntelDir

if (-not $amdRows)   { Write-Host "AMD results missing.   Run benchmark on AMD first."   -ForegroundColor Yellow }
if (-not $intelRows) { Write-Host "Intel results missing. Run benchmark on Intel first." -ForegroundColor Yellow }

if (-not $amdRows -and -not $intelRows) { exit 1 }

$amdLabel   = if ($amdRows)   { Get-CpuLabel $AmdDir }   else { "AMD (no data)" }
$intelLabel = if ($intelRows) { Get-CpuLabel $IntelDir } else { "Intel (no data)" }

$amdStats   = if ($amdRows)   { Get-Stats $amdRows }   else { $null }
$intelStats = if ($intelRows) { Get-Stats $intelRows } else { $null }

# ---------------------------------------------------------------------------
# Build comparison markdown
# ---------------------------------------------------------------------------
$out = @"
# CPU Throttle Benchmark N/A AMD vs Intel Comparison

**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')

| | AMD | Intel |
|---|---|---|
| **CPU** | $amdLabel | $intelLabel |

---

## Side-by-Side Build Times

| Iter | AMD Duration (s) | AMD Freq Start (MHz) | Intel Duration (s) | Intel Freq Start (MHz) |
|------|-----------------|---------------------|-------------------|----------------------|
"@

$maxIter = [math]::Max(
    $(if ($amdRows)   { $amdRows.Count }   else { 0 }),
    $(if ($intelRows) { $intelRows.Count } else { 0 })
)

for ($i = 0; $i -lt $maxIter; $i++) {
    $aRow = if ($amdRows   -and $i -lt $amdRows.Count)   { $amdRows[$i] }   else { $null }
    $iRow = if ($intelRows -and $i -lt $intelRows.Count) { $intelRows[$i] } else { $null }

    $aDur  = if ($aRow)  { $aRow.duration_sec }  else { "N/A" }
    $aFreq = if ($aRow)  { $aRow.freq_mhz_start } else { "N/A" }
    $iDur  = if ($iRow)  { $iRow.duration_sec }  else { "N/A" }
    $iFreq = if ($iRow)  { $iRow.freq_mhz_start } else { "N/A" }

    $out += "`n| $($i+1) | $aDur | $aFreq | $iDur | $iFreq |"
}

$out += @"


---

## Summary Comparison

| Metric | AMD | Intel | Winner |
|--------|-----|-------|--------|
"@

function Fmt([object]$v, [string]$unit) { if ($null -eq $v) { "N/A" } else { "$v$unit" } }
function Winner([object]$aVal, [object]$iVal, [bool]$lowerIsBetter = $true) {
    if ($null -eq $aVal -or $null -eq $iVal) { return "N/A" }
    if ($lowerIsBetter) {
        if ($aVal -lt $iVal) { return "AMD" } elseif ($iVal -lt $aVal) { return "Intel" } else { return "Tie" }
    } else {
        if ($aVal -gt $iVal) { return "AMD" } elseif ($iVal -gt $aVal) { return "Intel" } else { return "Tie" }
    }
}

$metrics = @(
    @{ Name="Min build time";     Afn={ $amdStats.Min };   Ifn={ $intelStats.Min };   Unit="s";   Lower=$true  }
    @{ Name="Max build time";     Afn={ $amdStats.Max };   Ifn={ $intelStats.Max };   Unit="s";   Lower=$true  }
    @{ Name="Avg build time";     Afn={ $amdStats.Avg };   Ifn={ $intelStats.Avg };   Unit="s";   Lower=$true  }
    @{ Name="Drift (iter1 vs 10)";Afn={ $amdStats.Drift }; Ifn={ $intelStats.Drift }; Unit="s";   Lower=$true  }
    @{ Name="Throttle ratio";     Afn={ $amdStats.ThrottleRatio }; Ifn={ $intelStats.ThrottleRatio }; Unit="x"; Lower=$true }
    @{ Name="Min CPU freq";       Afn={ $amdStats.MinFreq };Ifn={ $intelStats.MinFreq }; Unit=" MHz"; Lower=$false }
    @{ Name="Max CPU freq";       Afn={ $amdStats.MaxFreq };Ifn={ $intelStats.MaxFreq }; Unit=" MHz"; Lower=$false }
)

foreach ($m in $metrics) {
    $aVal = if ($amdStats)   { & $m.Afn }   else { $null }
    $iVal = if ($intelStats) { & $m.Ifn } else { $null }
    $w    = Winner $aVal $iVal $m.Lower
    $out += "`n| $($m.Name) | $(Fmt $aVal $m.Unit) | $(Fmt $iVal $m.Unit) | $w |"
}

# ASCII charts
$out += @"


---

## ASCII Frequency Charts

### AMD N/A $amdLabel

``````
"@
if ($amdStats) {
    $out += "`n" + (Make-AsciiChart $amdStats.FreqsStart "AMD")
} else { $out += "`n(no data)" }

$out += @"

``````

### Intel N/A $intelLabel

``````
"@
if ($intelStats) {
    $out += "`n" + (Make-AsciiChart $intelStats.FreqsStart "Intel")
} else { $out += "`n(no data)" }

$out += @"

``````

---

## Conclusion

"@

if ($amdStats -and $intelStats) {
    $driftWinner  = if ($amdStats.Drift -lt $intelStats.Drift) { "AMD throttles less" } `
                    elseif ($intelStats.Drift -lt $amdStats.Drift) { "Intel throttles less" } `
                    else { "Both throttle equally" }
    $ratioWinner  = if ($amdStats.ThrottleRatio -lt $intelStats.ThrottleRatio) { "AMD" } `
                    elseif ($intelStats.ThrottleRatio -lt $amdStats.ThrottleRatio) { "Intel" } `
                    else { "tie" }

    $out += @"
- **Drift:** AMD=$($amdStats.Drift)s vs Intel=$($intelStats.Drift)s N/A **$driftWinner**
- **Throttle ratio:** AMD=$($amdStats.ThrottleRatio)x vs Intel=$($intelStats.ThrottleRatio)x N/A **$ratioWinner has less throttling**
- **Freq drop:** AMD $($amdStats.MaxFreq - $amdStats.MinFreq) MHz delta vs Intel $($intelStats.MaxFreq - $intelStats.MinFreq) MHz delta
- **Avg build time:** AMD=$($amdStats.Avg)s vs Intel=$($intelStats.Avg)s
"@
} elseif ($amdStats) {
    $out += "AMD results only. Run benchmark on Intel to compare.`n"
    $out += "AMD: drift=$($amdStats.Drift)s  throttle-ratio=$($amdStats.ThrottleRatio)x  avg=$($amdStats.Avg)s"
} else {
    $out += "Intel results only. AMD baseline from repo docs: drift~1800s, throttle-ratio~13.5x, avg~600s."
    $out += "`nIntel: drift=$($intelStats.Drift)s  throttle-ratio=$($intelStats.ThrottleRatio)x  avg=$($intelStats.Avg)s"
}

$outFile = "$OutDir/comparison-amd-vs-intel.md"
$out | Out-File $outFile -Encoding utf8
Write-Host "Comparison saved: $outFile" -ForegroundColor Green
