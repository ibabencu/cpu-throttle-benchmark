# CPU Throttle Benchmark

Benchmark pentru compararea **thermal throttling** între CPU-uri, folosind build-ul unui proiect .NET real ca workload.

## Setup

Testat pe:
- **AMD Ryzen AI 9 HX PRO 370** (12c/24t, TJmax 95°C, TDP 28–54W)
- **Intel** (TBD)

Workload: `dotnet build Studio.sln -m` × 10 iterații cu `git clean -xdf` între ele.

## Utilizare

```powershell
powershell -ExecutionPolicy Bypass -File run-benchmark.ps1
```

Scriptul face automat:
1. **Preflight** — verifică că dotnet, git, VSCodium și soluția există
2. **dotnet restore** — o singură dată la început
3. **Monitor CPU** — deschide o fereastră separată care scrie frecvența + % performanță la fiecare 5s
4. **Build loop** — 10 iterații cu 30s cooldown între ele
5. **Raport** — generează `benchmark-results/report-amd-ryzen-hx370.md` și îl deschide în VSCodium

## Configurare

Editează variabilele din `run-benchmark.ps1`:

```powershell
$sln     = "C:/dev/studio/Studio/Studio.sln"   # calea spre soluția ta
$repoDir = "C:/dev/studio/Studio"               # repo-ul de curățat
$outDir  = "C:/dev/benchmark-results"           # unde se salvează rezultatele
```

## Output

```
benchmark-results/
├── cpu-metrics.csv          # frecvență CPU la fiecare 5s (din monitor)
├── build-results.csv        # durată per iterație
├── report-amd-ryzen-hx370.md  # raport final cu tabel + grafic ASCII
└── iter-N.log               # build log per iterație
```

## Metrici colectate

| Metrică | Sursă |
|---------|-------|
| Frecvență curentă (MHz) | `Win32_Processor.CurrentClockSpeed` |
| % Processor Performance | Windows Perf Counter |
| % CPU Usage | Windows Perf Counter |
| Build duration per iterație | `Measure-Command` |

> Fără drepturi de admin necesare.

## Scripturi

| Fișier | Rol |
|--------|-----|
| `run-benchmark.ps1` | **Launcher** — pornește totul cu o singură comandă |
| `benchmark-build.ps1` | Build loop cu git clean + raport final |
| `monitor-cpu.ps1` | Monitor CPU în fereastră separată |
| `cpu-throttle-benchmark-prompt.md` | Prompt AI pentru a rula benchmark-ul via Claude |
