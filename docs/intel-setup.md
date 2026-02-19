# Running on the Intel Machine

This guide covers running the same benchmark on an Intel machine so you can compare against the AMD Ryzen AI HX PRO 370 results.

**AMD baseline results are in `amd-results/` for comparison.**

---

## Prerequisites

### Software (install via winget in PowerShell as admin)

```powershell
winget install Microsoft.DotNet.SDK.8
winget install Git.Git
winget install Microsoft.DotNet.Framework.DeveloperPack_4   # .NET 4.8.1 for net472 projects
```

### .NET Framework 4.7.2 targeting pack (required)

The build targets net472. The winget pack above installs 4.8.1 but NOT 4.7.2.
Download and install 4.7.2 manually:

```powershell
$url = "https://go.microsoft.com/fwlink/?linkid=874338"
$tmp = "$env:TEMP\ndp472-devpack.exe"
(New-Object System.Net.WebClient).DownloadFile($url, $tmp)
Start-Process -FilePath $tmp -ArgumentList '/q /norestart' -Wait
```

> After install, a **machine restart may be needed** before MSBuild finds the assemblies.
> If you see `MSB3644: reference assemblies for .NETFramework,Version=v4.7.2 were not found`,
> the scripts already pass `/p:TargetFrameworkRootPath=...` to work around this without restart.

### NuGet authentication (UiPath internal feed)

```powershell
# 1. Install the Azure Artifacts Credential Provider
iex ((New-Object System.Net.WebClient).DownloadString('https://aka.ms/install-artifacts-credprovider.ps1'))

# 2. Login to Azure
az login   # or use: az login --use-device-code

# 3. Cache credentials interactively (one-time only)
dotnet restore C:/dev/studio/Studio/Studio.sln --interactive
# -> opens browser, sign in with your @uipath.com account
# -> subsequent restores work non-interactively from cache
```

### Studio repo

```powershell
git clone <studio-repo-url> C:/dev/studio/Studio
```

---

## Step 1 — Get the benchmark scripts

```powershell
# Clone this repo
git clone https://github.com/ibabencu/cpu-throttle-benchmark C:/dev/cpu-throttle-benchmark
```

Or copy these 3 files manually:
- `benchmark-build.ps1`
- `run-benchmark.ps1`
- `monitor-cpu.ps1`

---

## Step 2 — Configure paths for Intel

Edit `run-benchmark.ps1` — update these variables at the top:

```powershell
$SolutionPath = "C:/dev/studio/Studio/Studio.sln"     # adjust if cloned elsewhere
$RepoPath     = "C:/dev/studio/Studio"
$OutputDir    = "C:/dev/benchmark-results-intel"       # keep different from AMD!
$CodiumPath   = "C:/Users/<username>/AppData/Local/Programs/VSCodium/bin/codium.cmd"
```

> **Important:** Use a different `$OutputDir` than the AMD run so you don't overwrite the AMD data.

---

## Step 3 — Update the report name in benchmark-build.ps1

Find line ~83 (the `$reportFile` variable) and change it to auto-detect the CPU name:

```powershell
# Old (hardcoded AMD name):
$reportFile = "$OutputDir/report-amd-ryzen-hx370.md"

# New (auto-detect, works on any CPU):
$cpuName    = (Get-CimInstance Win32_Processor | Select-Object -First 1).Name
$safeName   = ($cpuName -replace '[^a-zA-Z0-9]', '-').Trim('-') -replace '-+', '-'
$reportFile = "$OutputDir/report-$safeName.md"
```

---

## Step 4 — Run the benchmark

Open PowerShell (does NOT need to be admin) and run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
& C:/dev/benchmark-build.ps1 -Iterations 10 -CooldownSec 30
```

Or use the full launcher (opens monitor in a separate window):

```powershell
& C:/dev/run-benchmark.ps1
```

**Estimated time:** 30-120 minutes depending on Intel CPU throttling behavior.

---

## Step 5 — What to watch for during the run

Check `benchmark-results-intel/build-results.csv` while it runs:

```powershell
# Live tail (run in a second PowerShell window)
while ($true) { Get-Content C:/dev/benchmark-results-intel/build-results.csv; Start-Sleep 30 }
```

**AMD reference:**
- Iters 1-3: ~215-228s (baseline)
- Iter 4: **965s** (throttle kicks in)
- Iter 8: **2056s** (extreme throttle)
- Throttle ratio: **13.5x**

If Intel stays under 300s for all 10 iterations, that's a huge win.

---

## Step 6 — Compare results

Place both result folders side by side:

```
C:/dev/
  benchmark-results/          <- AMD results (already done)
  benchmark-results-intel/    <- Intel results (just ran)
```

Key comparison metrics:

| Metric                      | AMD Ryzen HX PRO 370 | Intel (your run) |
|-----------------------------|---------------------|------------------|
| Baseline build time (iter1) | 228s                | ?                |
| First throttle at iter #    | 4                   | ?                |
| Max build time              | 2056s               | ?                |
| Throttle ratio (max/min)    | **13.5x**           | ?                |
| Avg build time              | 601s                | ?                |
| Fastest build               | 152s                | ?                |

Open both reports in VSCodium:

```powershell
codium C:/dev/benchmark-results/report-amd-ryzen-hx370.md `
       C:/dev/benchmark-results-intel/report-*.md
```

See [interpreting-results.md](interpreting-results.md) for detailed analysis guidance.

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `NU1301: Unable to load service index` | Run `dotnet restore --interactive` first |
| `MSB3644: .NETFramework v4.7.2 not found` | Scripts pass `/p:TargetFrameworkRootPath=...` automatically — if still failing, restart machine |
| `NETSDK1004: project.assets.json not found` | Run `dotnet restore Studio.sln` manually once, then retry |
| `git clean` takes very long | Normal — it removes all build artifacts before each iteration |
| Build times wildly inconsistent on iter 1 | Machine was already warm — add 5min cooldown before starting |
