param(
    [string]$OutputFile = "C:/dev/benchmark-results/cpu-metrics.csv",
    [int]$IntervalSec = 5
)

$dir = Split-Path $OutputFile
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

"timestamp,freq_mhz,perf_pct,usage_pct" | Out-File $OutputFile -Encoding utf8

Write-Host "CPU monitor started -> $OutputFile (every ${IntervalSec}s). Ctrl+C to stop."

while ($true) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $freq = (Get-CimInstance Win32_Processor | Select-Object -First 1).CurrentClockSpeed

    try {
        $perf  = (Get-Counter '\Processor Information(_Total)\% Processor Performance' -ErrorAction Stop).CounterSamples[0].CookedValue
        $usage = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop).CounterSamples[0].CookedValue
    } catch {
        $perf = -1; $usage = -1
    }

    "$ts,$freq,$([math]::Round($perf,1)),$([math]::Round($usage,1))" | Add-Content $OutputFile
    Start-Sleep $IntervalSec
}
