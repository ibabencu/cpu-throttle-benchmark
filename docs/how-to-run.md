# How to Run the Benchmark

## Prerequisites

| Tool | Min Version | Check |
|------|-------------|-------|
| .NET SDK | 8.0 | `dotnet --version` |
| Git | any | `git --version` |
| VSCodium or VS Code | any | `codium --version` |
| PowerShell | 5.1+ | `$PSVersionTable.PSVersion` |

> **NuGet auth:** The Studio solution uses an internal UiPath feed (`uipath.pkgs.visualstudio.com`).
> Make sure you're on VPN or have the feed credentials configured before running.

---

## Step 1 — Clone & configure

```powershell
git clone https://github.com/ibabencu/cpu-throttle-benchmark
cd cpu-throttle-benchmark
```

Open `run-benchmark.ps1` and update the path variables at the top to match your machine:

```powershell
$sln     = "C:/dev/studio/Studio/Studio.sln"   # path to your .sln
$repoDir = "C:/dev/studio/Studio"               # repo root for git clean
$outDir  = "C:/dev/benchmark-results"           # where results are saved
$dotnet  = "C:/Program Files/dotnet/dotnet.exe"
$git     = "C:/Program Files/Git/bin/git.exe"
$codium  = "C:/Users/<you>/AppData/Local/Programs/VSCodium/bin/codium.cmd"
```

---

## Step 2 — Run

Open PowerShell and run:

```powershell
powershell -ExecutionPolicy Bypass -File run-benchmark.ps1
```

The script will:

1. **Preflight** — check all paths exist, abort with clear error if not
2. **dotnet restore** — restore NuGet packages once
3. **CPU monitor** — open a separate visible PowerShell window sampling CPU every 5s
4. **Build loop** — 10 iterations of `git clean -xdf` + `dotnet build -m`, 30s cooldown between each
5. **Report** — generate Markdown report and open it in VSCodium

**Estimated duration:** 60–90 minutes for 10 iterations depending on machine speed.

---

## Step 3 — After it finishes

When you see the magenta box:

```
########################################################
#   Benchmarkul s-a terminat.                          #
#   Poti inchide acum fereastra de monitor CPU.        #
########################################################
```

Close the monitor window manually (Ctrl+C in that window).

VSCodium will open the report automatically.

---

## Customizing iterations / cooldown

```powershell
# Edit benchmark-build.ps1 call in run-benchmark.ps1:
-Iterations 5       # fewer iterations for a quick test
-CooldownSec 60     # longer cooldown if the CPU runs very hot
```

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| `NU1301: Unable to load service index` | Not on VPN / NuGet feed not authenticated |
| `Preflight FAILED: dotnet not found` | Update `$dotnet` path in `run-benchmark.ps1` |
| `Preflight FAILED: solution not found` | Update `$sln` path |
| `git clean` removes too much | Run `git -C $repoDir clean -xdf --dry-run` first to preview |
| Report not generated | Check `benchmark-results/iter-N.log` for build errors |
