# CPU Throttling Benchmark — AMD vs Intel
## Prompt de utilizat în sesiunea de benchmark

---

## Context

Vrem să comparăm comportamentul de **thermal throttling** între:
- **AMD Ryzen AI 9 HX PRO 370** (12 cores/24 threads, TJmax ~95°C, TDP configurabil 28–54W)
- **Intel** (TBD — va fi rulat pe o altă mașină)

Workload-ul de test este **build-ul proiectului Studio** (`/c/dev/studio/Studio/Studio.sln`), rulat în buclă de 10 ori cu reset complet între iterații.

---

## Prompt AMD — copiază-l direct pe mașina AMD

```
Rulează benchmarkul de CPU throttling pe AMD Ryzen AI 9 HX PRO 370 astfel:

1. SETUP MONITORIZARE: Pornește colectarea de metrici CPU (frecvență, % performanță, clock speed)
   la fiecare 5 secunde într-un fișier CSV de background.

2. LOOP DE 10 ITERAȚII — pentru fiecare iterație i (1..10):
   a. git -C /c/dev/studio clean -xdf
   b. Înregistrează timestamp start + metrici CPU snapshot
   c. dotnet build /c/dev/studio/Studio/Studio.sln --no-restore -m (sau echivalent)
   d. Înregistrează timestamp end, durata build-ului, metrici CPU snapshot
   e. Pauză 30s (cooldown termic)

3. COLECTARE METRICI (fără admin, via PowerShell):
   - Frecvența curentă: (Get-CimInstance Win32_Processor).CurrentClockSpeed
   - % Processor Performance: Get-Counter '\Processor Information(_Total)\% Processor Performance'
   - CPU Usage: Get-Counter '\Processor(_Total)\% Processor Time'
   - Thermal throttle events: Get-WinEvent -LogName System | Where source -eq 'Microsoft-Windows-Kernel-Power'

4. OUTPUT CSV format:
   iteration, timestamp, phase, build_duration_sec, cpu_freq_mhz, cpu_perf_pct, cpu_usage_pct, throttle_events

5. RAPORT FINAL (Markdown):
   - Tabel cu toate iterațiile
   - Grafic ASCII al frecvenței în timp
   - Identifică dacă throttling-ul a crescut după iterația N
   - Build time drift (iterația 1 vs 10)
   - Concluzie: cât de mult se degradează performanța din cauza temperaturii
```

---

## Prompt Intel — copiază-l direct pe laptopul Intel

```
Rulează benchmarkul de CPU throttling pe Intel astfel:

1. SETUP MONITORIZARE: Pornește colectarea de metrici CPU (frecvență, % performanță, clock speed)
   la fiecare 5 secunde într-un fișier CSV de background.

2. LOOP DE 10 ITERAȚII — pentru fiecare iterație i (1..10):
   a. git -C /c/dev/studio clean -xdf
   b. Înregistrează timestamp start + metrici CPU snapshot
   c. dotnet build /c/dev/studio/Studio/Studio.sln --no-restore -m (sau echivalent)
   d. Înregistrează timestamp end, durata build-ului, metrici CPU snapshot
   e. Pauză 30s (cooldown termic)

3. COLECTARE METRICI (fără admin, via PowerShell):
   - Frecvența curentă: (Get-CimInstance Win32_Processor).CurrentClockSpeed
   - % Processor Performance: Get-Counter '\Processor Information(_Total)\% Processor Performance'
   - CPU Usage: Get-Counter '\Processor(_Total)\% Processor Time'
   - Thermal throttle events: Get-WinEvent -LogName System | Where source -eq 'Microsoft-Windows-Kernel-Power'
   - MaxClockSpeed (TDP ref): (Get-CimInstance Win32_Processor).MaxClockSpeed

4. OUTPUT CSV format:
   iteration, timestamp, phase, build_duration_sec, cpu_freq_mhz, cpu_perf_pct, cpu_usage_pct, throttle_events

5. RAPORT FINAL (salvează ca report-intel-[CPU_MODEL].md):
   - Identifică modelul Intel exact: (Get-CimInstance Win32_Processor).Name
   - Tabel cu toate iterațiile
   - Grafic ASCII al frecvenței în timp
   - Identifică dacă throttling-ul a crescut după iterația N
   - Build time drift (iterația 1 vs 10)
   - Concluzie: cât de mult se degradează performanța din cauza temperaturii
   - Salvează CSV ca intel-cpu-metrics.csv și raportul ca report-intel-[CPU_MODEL].md
```

---

## Plan de execuție

### Faza 1: Setup (această mașină — AMD)
- [ ] Verifică dacă `dotnet` e disponibil: `dotnet --version`
- [ ] Verifică dacă `git clean -xdf` merge pe repo (test dry-run: `git -C /c/dev/studio clean -xdf --dry-run | head -5`)
- [ ] Creează scriptul de monitoring background (`monitor-cpu.ps1`)
- [ ] Creează scriptul de build loop (`benchmark-build.sh`)
- [ ] Rulează benchmark-ul (estimat ~60-90 min pentru 10 iterații)
- [ ] Generează raportul AMD (`report-amd-ryzen-hx370.md`)

### Faza 2: Intel (laptopul Intel)
- [ ] Copiază/clonează repo-ul de studio pe mașina Intel: `git clone <url> /c/dev/studio`
- [ ] Verifică `dotnet --version` și `git -C /c/dev/studio clean -xdf --dry-run`
- [ ] Copiază scripturile `monitor-cpu.ps1` și `benchmark-build.sh` pe mașina Intel
- [ ] Rulează benchmark-ul cu promptul Intel de mai sus
- [ ] Generează raportul Intel (`report-intel-[CPU_MODEL].md`)

### Faza 3: Comparație
- [ ] Combină rapoartele într-un `comparison-amd-vs-intel.md`
- [ ] Concluzii: care se throttle-ează mai agresiv? Care recuperează mai repede?

---

## Metrici de urmărit

| Metrică | Semnificație | Sursă |
|---------|-------------|-------|
| `CurrentClockSpeed` | Frecvența reală a CPU | Win32_Processor WMI |
| `% Processor Performance` | Cât % din frecvența max rulează | Perf Counter |
| Build duration per iterație | Degradare în timp = throttling | time() |
| Thermal throttle events | Evenimente kernel de throttle | Windows Event Log |
| Delta timp iterația 1 vs 10 | Overhead cumulativ de căldură | calcul |

---

## Note tehnice

- **TJmax AMD Ryzen AI HX 370**: 95°C
- **fără admin**: `MSAcpi_ThermalZoneTemperature` este deny → folosim frecvență ca proxy
- **alternativă cu admin**: LibreHardwareMonitor CLI, HWiNFO64 cu CSV logging
- **build command**: `dotnet build Studio.sln -m` (max parallelism)
- **git clean -xdf** șterge tot ce nu e tracked, inclusiv build artifacts

---

## Script PowerShell de monitoring (salvează ca `monitor-cpu.ps1`)

```powershell
param([string]$OutputFile = "cpu-metrics.csv", [int]$IntervalSec = 5)

"timestamp,freq_mhz,perf_pct,usage_pct" | Out-File $OutputFile

while ($true) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $proc = Get-CimInstance Win32_Processor | Select-Object -First 1
    $freq = $proc.CurrentClockSpeed

    try {
        $perf = (Get-Counter '\Processor Information(_Total)\% Processor Performance' -ErrorAction Stop).CounterSamples[0].CookedValue
        $usage = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction Stop).CounterSamples[0].CookedValue
    } catch {
        $perf = -1; $usage = -1
    }

    "$ts,$freq,$([math]::Round($perf,1)),$([math]::Round($usage,1))" | Add-Content $OutputFile
    Start-Sleep $IntervalSec
}
```

---

*Generat: 2026-02-19 | Mașină AMD: ryzen8000 (AMD Ryzen AI 9 HX PRO 370) | Mașină Intel: TBD*
