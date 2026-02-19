# CPU Throttle Benchmark

Benchmark for comparing **thermal throttling** between CPUs, using the build of a real .NET project as the workload.

## Setup

Tested on:
- **AMD Ryzen AI 9 HX PRO 370** (12c/24t, TJmax 95°C, TDP 28–54W)
- **Intel** (TBD)

Workload: `dotnet build Studio.sln -m` × 10 iterations with `git clean -xdf` between each.

## Usage

```powershell
powershell -ExecutionPolicy Bypass -File run-benchmark.ps1
```

The script automatically:
1. **Preflight** — checks that dotnet, git, VSCodium, and the solution exist
2. **dotnet restore** — once at the start
3. **CPU monitor** — opens a separate window that logs frequency + performance % every 5s
4. **Build loop** — 10 iterations with 30s cooldown between each
5. **Report** — generates `benchmark-results/report-amd-ryzen-hx370.md` and opens it in VSCodium

## Configuration

Edit the variables in `run-benchmark.ps1`:

```powershell
$sln     = "C:/dev/studio/Studio/Studio.sln"   # path to your solution
$repoDir = "C:/dev/studio/Studio"               # repo to clean
$outDir  = "C:/dev/benchmark-results"           # where results are saved
```

## Output

```
benchmark-results/
├── cpu-metrics.csv          # CPU frequency every 5s (from monitor)
├── build-results.csv        # duration per iteration
├── report-amd-ryzen-hx370.md  # final report with table + ASCII chart
└── iter-N.log               # build log per iteration
```

## Collected Metrics

| Metric | Source |
|--------|--------|
| Current frequency (MHz) | `Win32_Processor.CurrentClockSpeed` |
| % Processor Performance | Windows Perf Counter |
| % CPU Usage | Windows Perf Counter |
| Build duration per iteration | `Measure-Command` |

> No admin rights required.

## Scripts

| File | Role |
|------|------|
| `run-benchmark.ps1` | **Launcher** — starts everything with a single command |
| `benchmark-build.ps1` | Build loop with git clean + final report |
| `monitor-cpu.ps1` | CPU monitor in a separate window |
| `cpu-throttle-benchmark-prompt.md` | AI prompt for running the benchmark via Claude |
