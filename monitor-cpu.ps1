param(
    [string]$OutputFile = "C:/dev/benchmark-results/cpu-metrics.csv",
    [int]$IntervalSec = 5
)

$dir = Split-Path $OutputFile
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

Add-Type -TypeDefinition @"
using System.IO.MemoryMappedFiles;
public class CoreTempReader {
    public static float[] GetTemps(out int coreCnt, out bool isDelta) {
        coreCnt = 0; isDelta = false;
        try {
            var mmf = MemoryMappedFile.OpenExisting("CoreTempMappingObject");
            using (var view = mmf.CreateViewAccessor(0, 2700, MemoryMappedFileAccess.Read)) {
                coreCnt = (int)view.ReadUInt32(1536);
                isDelta = view.ReadByte(2685) == 1;
                var temps = new float[coreCnt];
                for (int i = 0; i < coreCnt; i++)
                    temps[i] = view.ReadSingle(1544 + i * 4);
                return temps;
            }
        } catch { return new float[0]; }
    }
}
"@ -ErrorAction SilentlyContinue

"timestamp,freq_mhz,perf_pct,usage_pct,temp_c" | Out-File $OutputFile -Encoding utf8

$coreTempAvailable = $false
try {
    $dummy = 0; $dummyD = $false
    $t = [CoreTempReader]::GetTemps([ref]$dummy, [ref]$dummyD)
    $coreTempAvailable = $t.Length -gt 0
} catch {}

Write-Host "CPU monitor started -> $OutputFile (every ${IntervalSec}s). Ctrl+C to stop."
Write-Host "Core Temp: $(if ($coreTempAvailable) { 'available' } else { 'NOT available - temp_c will be -1' })"

while ($true) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $freq = (Get-CimInstance Win32_Processor | Select-Object -First 1).CurrentClockSpeed

    try {
        $perf  = (Get-Counter '\Processor Information(_Total)\% Processor Performance' -ErrorAction Stop).CounterSamples[0].CookedValue
        $usage = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop).CounterSamples[0].CookedValue
    } catch {
        $perf = -1; $usage = -1
    }

    $tempC = -1
    if ($coreTempAvailable) {
        try {
            $cCnt = 0; $isDelta = $false
            $temps = [CoreTempReader]::GetTemps([ref]$cCnt, [ref]$isDelta)
            if ($temps.Length -gt 0) {
                $maxT = ($temps | Measure-Object -Maximum).Maximum
                $tempC = if ($isDelta) { -1 } else { [math]::Round($maxT, 1) }
            }
        } catch { $tempC = -1 }
    }

    "$ts,$freq,$([math]::Round($perf,1)),$([math]::Round($usage,1)),$tempC" | Add-Content $OutputFile
    Start-Sleep $IntervalSec
}
