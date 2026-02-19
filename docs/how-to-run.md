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

### One-time: .NET Framework reference assemblies

The solution targets `net461`, `net472`, and `net481`. If `v4.6.1` is not installed system-wide
(it rarely is — only `v4.7.2`+ ships with Windows dev tools), run once:

```powershell
powershell -ExecutionPolicy Bypass -File setup-refassemblies.ps1
```

This creates `C:\dev\ref-assemblies\.NETFramework\` with junction points to:
- `v4.6.1` — NuGet package `microsoft.netframework.referenceassemblies.net461` (already in NuGet cache)
- `v4.7.2` — system path
- `v4.8.1` — system path

`benchmark-build.ps1` already passes `/p:TargetFrameworkRootPath=C:\dev\ref-assemblies\` automatically.

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
#   Benchmark has finished.                            #
#   You can now close the CPU monitor window.          #
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
| `MSB3644: reference assemblies for .NETFramework,Version=v4.6.1 not found` | Run `setup-refassemblies.ps1` once (see Prerequisites above) |
| `MSB3073: UiPath.Api.Package.DocGen.exe exited with code 9009` | Handled automatically — the script pre-builds DocGen and adds its output dirs to `PATH`. If it still fails, check the DocGen pre-build output at the top of `benchmark-live.log` |
| Build fails with `'UiPath.Api.Package.DocGen.exe' is not recognized` | Your machine has `NoDefaultCurrentDirectoryInExePath=1` (Windows security policy). The script adds DocGen dirs to PATH to work around this — if still failing, verify `benchmark-build.ps1` has the PATH fix (lines after `$docGenBase`) |
