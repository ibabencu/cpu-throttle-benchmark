# Running on the Intel Machine

This guide covers running the same benchmark on a second machine (Intel) so you can compare results.

## Prerequisites

Same as AMD — see [how-to-run.md](how-to-run.md). Additionally:

- The Studio repo must be cloned on the Intel machine
- .NET SDK 8.0 must be installed (`winget install Microsoft.DotNet.SDK.8`)
- NuGet auth / VPN same as AMD machine

---

## Step 1 — Copy the scripts

Either clone the repo or copy the 3 scripts manually:

```powershell
# Option A: clone
git clone https://github.com/ibabencu/cpu-throttle-benchmark C:/dev/cpu-throttle-benchmark

# Option B: copy from a USB / network share
# run-benchmark.ps1
# benchmark-build.ps1
# monitor-cpu.ps1
```

---

## Step 2 — Update paths in run-benchmark.ps1

Same variables as AMD, adjust to match the Intel machine's paths:

```powershell
$sln     = "C:/dev/studio/Studio/Studio.sln"
$repoDir = "C:/dev/studio/Studio"
$outDir  = "C:/dev/benchmark-results-intel"     # use a different outDir!
$codium  = "C:/Users/<intel-username>/AppData/Local/Programs/VSCodium/bin/codium.cmd"
```

> Use a different `$outDir` (e.g. `benchmark-results-intel`) so results don't overwrite AMD data if you're sharing a drive.

---

## Step 3 — Update report filename in benchmark-build.ps1

The report is currently hardcoded to `report-amd-ryzen-hx370.md`. On Intel, change line 78:

```powershell
# Old (AMD):
$reportFile = "$OutputDir/report-amd-ryzen-hx370.md"

# New (Intel) — the script auto-detects CPU name:
$cpuName = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
$safeName = $cpuName -replace '[^a-zA-Z0-9]', '-' -replace '-+', '-'
$reportFile = "$OutputDir/report-intel-$safeName.md"
```

---

## Step 4 — Run

```powershell
powershell -ExecutionPolicy Bypass -File run-benchmark.ps1
```

Same flow as AMD. Estimated time: 60–90 minutes.

---

## Step 5 — Compare results

After both benchmarks are done, copy both `benchmark-results*/` folders to the same machine and compare:

- `report-amd-ryzen-hx370.md` vs `report-intel-*.md`
- Open both side by side in VSCodium: `codium report-amd.md report-intel.md`
- Key metrics: **drift**, **freq range**, **avg build time**

See [interpreting-results.md](interpreting-results.md) for what to look for.
